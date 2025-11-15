import os
import sys
import base64
import re
from functools import wraps
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

# Load environment variables from .env file if it exists
try:
    from dotenv import load_dotenv
    # Try multiple locations for .env file:
    # 1. Root directory (project root)
    # 2. BananaDoc_AI directory (fallback)
    
    # Get the root directory (3 levels up from api/banana_deficiency_api.py)
    root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    root_env_path = os.path.join(root_dir, '.env')
    
    # Get BananaDoc_AI directory (2 levels up from api/banana_deficiency_api.py)
    banana_doc_ai_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    banana_doc_ai_env_path = os.path.join(banana_doc_ai_dir, '.env')
    
    # Try root directory first, then BananaDoc_AI directory
    if os.path.exists(root_env_path):
        load_dotenv(root_env_path)
        print(f"Loaded environment variables from: {root_env_path}")
    elif os.path.exists(banana_doc_ai_env_path):
        load_dotenv(banana_doc_ai_env_path)
        print(f"Loaded environment variables from: {banana_doc_ai_env_path}")
    else:
        # Try loading from current directory as last resort
        load_dotenv()
        print("Attempted to load .env from current directory")
        
    # Also explicitly load GEMINI_API_KEY from environment to verify
    gemini_key = os.environ.get('GEMINI_API_KEY', '')
    if gemini_key:
        print(f"GEMINI_API_KEY found (length: {len(gemini_key)})")
    else:
        print("WARNING: GEMINI_API_KEY not found in environment variables!")
        
except ImportError:
    print("Warning: python-dotenv not installed. Install it to use .env files.")
except Exception as e:
    print(f"Warning: Could not load .env file: {e}")

# Add parent directory to path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.image_preprocessor import decode_and_load_base64_image
from utils.model_loader import ModelLoader
from utils.deficiency_info import DeficiencyInfoProvider
from utils.gemini_handler import GeminiHandler

app = Flask(__name__)

# Security: Restrict CORS to specific origins
allowed_origins = os.environ.get('ALLOWED_ORIGINS', 'http://localhost:3000,http://127.0.0.1:3000').split(',')
CORS(app, origins=allowed_origins, supports_credentials=True)

# Security: Rate limiting
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"
)

# Initialize components
model_loader = ModelLoader(model_dir='../models_runtime')
deficiency_info_provider = DeficiencyInfoProvider()

# Initialize Gemini handler with explicit API key check
print("=" * 60)
print("Initializing Gemini Handler...")
gemini_api_key = os.environ.get('GEMINI_API_KEY', '')
if gemini_api_key:
    print(f"GEMINI_API_KEY found: {gemini_api_key[:10]}...{gemini_api_key[-4:] if len(gemini_api_key) > 14 else '***'}")
    gemini_handler = GeminiHandler(api_key=gemini_api_key)
else:
    print("WARNING: GEMINI_API_KEY not found! Using default initialization (will try to read from env)")
    gemini_handler = GeminiHandler()
    
# Verify Gemini handler initialization
if gemini_handler.model is not None:
    print("✓ Gemini API initialized successfully!")
else:
    print("✗ WARNING: Gemini API not initialized. Chat will use fallback responses.")
    print("  Check that:")
    print("  1. GEMINI_API_KEY is set in .env file")
    print("  2. google-generativeai package is installed (pip install google-generativeai)")
print("=" * 60)

# Security: API Key Authentication
BACKEND_API_KEY = os.environ.get('BACKEND_API_KEY', '')
REQUIRE_AUTH = os.environ.get('REQUIRE_AUTH', 'true').lower() == 'true'

def require_api_key(f):
    """Decorator to require API key authentication"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if REQUIRE_AUTH and BACKEND_API_KEY:
            api_key = request.headers.get('X-API-Key') or request.headers.get('Authorization', '').replace('Bearer ', '')
            if not api_key or api_key != BACKEND_API_KEY:
                return jsonify({'error': 'Unauthorized. Invalid or missing API key.'}), 401
        return f(*args, **kwargs)
    return decorated_function

def validate_base64_image(image_data: str):
    """Validate base64 encoded image - returns (is_valid: bool, error_msg: str)"""
    if not image_data:
        return False, "Image data is empty"
    
    # Check if it's valid base64
    try:
        # Remove data URL prefix if present
        if ',' in image_data:
            image_data = image_data.split(',')[1]
        
        decoded = base64.b64decode(image_data, validate=True)
        
        # Check size (max 10MB)
        max_size = 10 * 1024 * 1024  # 10MB
        if len(decoded) > max_size:
            return False, f"Image size exceeds maximum allowed size of {max_size / (1024*1024)}MB"
        
        # Check if it's a valid image format
        if not decoded.startswith(b'\xff\xd8') and not decoded.startswith(b'\x89PNG'):
            return False, "Invalid image format. Only JPEG and PNG are supported."
        
        return True, ""
    except Exception as e:
        return False, f"Invalid base64 encoding: {str(e)}"

def validate_query(query: str):
    """Validate user query input - returns (is_valid: bool, error_msg: str)"""
    if not query:
        return False, "Query is empty"
    
    if len(query) > 1000:
        return False, "Query exceeds maximum length of 1000 characters"
    
    # Basic sanitization - remove potential script tags
    if re.search(r'<script|javascript:|onerror=|onload=', query, re.IGNORECASE):
        return False, "Query contains potentially unsafe content"
    
    return True, ""

@app.errorhandler(Exception)
def handle_error(e):
    """Generic error handler - don't expose internal errors"""
    is_dev = os.environ.get('FLASK_ENV', 'production') == 'development'
    
    if is_dev:
        return jsonify({
            'error': 'An error occurred',
            'message': str(e),
            'type': type(e).__name__
        }), 500
    else:
        return jsonify({'error': 'An internal error occurred. Please try again later.'}), 500

@app.route('/predict', methods=['POST'])
@require_api_key
@limiter.limit("10 per minute")
def predict_api():
    """Predict nutrient deficiency from image"""
    if not request.json or 'image' not in request.json:
        return jsonify({'error': 'No image provided'}), 400
    
    # Get the base64 encoded image
    image_data = request.json['image']
    
    # Validate image
    is_valid, error_msg = validate_base64_image(image_data)
    if not is_valid:
        return jsonify({'error': error_msg}), 400
    
    try:
        # Process the image
        processed_img = decode_and_load_base64_image(image_data)
        
        # Make prediction
        predictions = model_loader.predict(processed_img)
        
        # Get the predicted class
        deficiency_type, confidence = model_loader.get_prediction_label(predictions)
        
        # Get detailed information
        info = deficiency_info_provider.get_deficiency_info(deficiency_type)
        
        # Get all class probabilities as a dictionary
        probabilities = {
            model_loader.class_mapping.get(i, f"Class {i}"): float(prob) 
            for i, prob in enumerate(predictions)
        }
        
        # Prepare the result
        result = {
            'deficiency': deficiency_type,
            'confidence': confidence,
            'symptoms': info['symptoms'],
            'treatment': info['treatment'],
            'prevention': info['prevention'],
            'probabilities': probabilities
        }
        
        # Update Gemini handler with this prediction
        gemini_handler.update_with_prediction(result)
        
        return jsonify(result)
    
    except Exception as e:
        app.logger.error(f"Error in predict_api: {str(e)}", exc_info=True)
        raise  # Let the error handler deal with it

@app.route('/chat', methods=['POST'])
@require_api_key
@limiter.limit("20 per minute")
def chat_api():
    """Handle a chat query using the Gemini API with context awareness"""
    if not request.json or 'query' not in request.json:
        return jsonify({'error': 'No query provided'}), 400
    
    # Get and validate user query
    user_query = request.json['query']
    is_valid, error_msg = validate_query(user_query)
    if not is_valid:
        return jsonify({'error': error_msg}), 400
    
    try:
        # Process the query
        response = gemini_handler.process_query(user_query)
        
        return jsonify({
            'response': response
        })
    
    except Exception as e:
        app.logger.error(f"Error in chat_api: {str(e)}", exc_info=True)
        raise

@app.route('/clear-context', methods=['POST'])
@require_api_key
@limiter.limit("10 per minute")
def clear_context():
    """Clear the conversation context"""
    try:
        gemini_handler.context_manager.clear_context()
        return jsonify({'message': 'Context cleared successfully'})
    except Exception as e:
        app.logger.error(f"Error in clear_context: {str(e)}", exc_info=True)
        raise

@app.route('/context', methods=['GET'])
@require_api_key
def get_context():
    """Get the current context for debugging - SECURED"""
    # Only allow in development mode
    if os.environ.get('FLASK_ENV', 'production') != 'development':
        return jsonify({'error': 'This endpoint is not available in production'}), 403
    
    try:
        return jsonify(gemini_handler.context_manager.get_context_for_llm())
    except Exception as e:
        app.logger.error(f"Error in get_context: {str(e)}", exc_info=True)
        raise

@app.route('/health', methods=['GET'])
def health_check():
    """Check if the API is healthy and the model is loaded - Public endpoint"""
    model_loaded = (model_loader.model is not None or model_loader.interpreter is not None)
    return jsonify({
        'status': 'healthy', 
        'model_loaded': model_loaded,
        'version': '1.0.0'
    })

@app.route('/deficiencies', methods=['GET'])
@require_api_key
def get_deficiencies():
    """Get a list of all possible deficiencies"""
    return jsonify({
        'deficiencies': deficiency_info_provider.get_all_deficiencies()
    })

@app.route('/deficiency/<deficiency_type>', methods=['GET'])
@require_api_key
def get_deficiency_details(deficiency_type):
    """Get detailed information about a specific deficiency"""
    # Validate deficiency_type to prevent injection
    if not re.match(r'^[A-Za-z\s]+$', deficiency_type):
        return jsonify({'error': 'Invalid deficiency type'}), 400
    
    info = deficiency_info_provider.get_deficiency_info(deficiency_type)
    return jsonify(info)

if __name__ == '__main__':
    # Load the model
    model_loaded = model_loader.load_model()
    if not model_loaded:
        print("Warning: No model loaded. Server will start but predictions will fail.")
    
    # Security: Use 127.0.0.1 by default, allow override via env var
    host = os.environ.get('HOST', '127.0.0.1')
    port = int(os.environ.get('PORT', 5002))
    
    # Warn if using 0.0.0.0 in production
    if host == '0.0.0.0' and os.environ.get('FLASK_ENV') != 'development':
        print("WARNING: Server is binding to 0.0.0.0. Ensure proper firewall rules are in place.")
    
    app.run(host=host, port=port, debug=(os.environ.get('FLASK_ENV') == 'development'))
