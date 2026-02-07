#!/usr/bin/env python3
"""
Minimal chat server that only handles Gemini chat functionality
Doesn't require TensorFlow, so it can run even if TensorFlow has issues
"""
import os
import sys
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    # Try root directory first
    root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    root_env_path = os.path.join(root_dir, '.env')
    
    # Try BananaDoc_AI directory
    banana_doc_ai_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    banana_doc_ai_env_path = os.path.join(banana_doc_ai_dir, '.env')
    
    if os.path.exists(root_env_path):
        load_dotenv(root_env_path)
        print(f"✓ Loaded .env from: {root_env_path}")
    elif os.path.exists(banana_doc_ai_env_path):
        load_dotenv(banana_doc_ai_env_path)
        print(f"✓ Loaded .env from: {banana_doc_ai_env_path}")
    else:
        load_dotenv()
        print("✓ Attempted to load .env from current directory")
except ImportError:
    print("Warning: python-dotenv not installed")
except Exception as e:
    print(f"Warning: Could not load .env file: {e}")

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import GeminiHandler directly to avoid TensorFlow dependencies
import importlib.util
gemini_handler_path = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    'utils', 'gemini_handler.py'
)
spec = importlib.util.spec_from_file_location("gemini_handler", gemini_handler_path)
gemini_handler_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gemini_handler_module)
GeminiHandler = gemini_handler_module.GeminiHandler

app = Flask(__name__)

# CORS configuration
allowed_origins = os.environ.get('ALLOWED_ORIGINS', 'http://localhost:3000,http://127.0.0.1:3000').split(',')
CORS(app, origins=allowed_origins, supports_credentials=True)

# Rate limiting
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"
)

# Initialize Gemini handler
print("=" * 60)
print("Initializing Gemini Handler...")
gemini_api_key = os.environ.get('GEMINI_API_KEY', '')
if gemini_api_key:
    print(f"GEMINI_API_KEY found: {gemini_api_key[:10]}...{gemini_api_key[-4:] if len(gemini_api_key) > 14 else '***'}")
    gemini_handler = GeminiHandler(api_key=gemini_api_key)
else:
    print("WARNING: GEMINI_API_KEY not found!")
    gemini_handler = GeminiHandler()

# Verify Gemini handler initialization
if gemini_handler.model is not None:
    print("✓ Gemini API initialized successfully!")
else:
    print("✗ WARNING: Gemini API not initialized. Chat will use fallback responses.")
print("=" * 60)

# API Key Authentication (optional)
BACKEND_API_KEY = os.environ.get('BACKEND_API_KEY', '')
REQUIRE_AUTH = os.environ.get('REQUIRE_AUTH', 'false').lower() == 'true'

def require_api_key(f):
    """Decorator to require API key authentication"""
    from functools import wraps
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if REQUIRE_AUTH and BACKEND_API_KEY:
            api_key = request.headers.get('X-API-Key') or request.headers.get('Authorization', '').replace('Bearer ', '')
            if not api_key or api_key != BACKEND_API_KEY:
                return jsonify({'error': 'Unauthorized. Invalid or missing API key.'}), 401
        return f(*args, **kwargs)
    return decorated_function

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    gemini_status = "initialized" if gemini_handler.model is not None else "not_initialized"
    return jsonify({
        'status': 'healthy',
        'gemini_api': gemini_status,
        'version': '1.0.0-chat-only'
    })

@app.route('/chat', methods=['POST'])
@require_api_key
@limiter.limit("20 per minute")
def chat_api():
    """Handle a chat query using the Gemini API with context awareness"""
    if not request.json or 'query' not in request.json:
        return jsonify({'error': 'No query provided'}), 400
    
    user_query = request.json['query']
    
    if not user_query or len(user_query.strip()) == 0:
        return jsonify({'error': 'Query is empty'}), 400
    
    # Increased limit to 32000 characters to allow for full conversation context
    # Gemini 2.5-flash can handle up to 1M tokens, so 32K chars is safe
    # This allows for rich context including conversation history
    if len(user_query) > 32000:
        return jsonify({'error': 'Query exceeds maximum length of 32000 characters'}), 400
    
    try:
        # Process the query
        response = gemini_handler.process_query(user_query)
        
        return jsonify({
            'response': response
        })
    
    except Exception as e:
        app.logger.error(f"Error in chat_api: {str(e)}", exc_info=True)
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500

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
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    host = os.environ.get('HOST', '127.0.0.1')
    port = int(os.environ.get('PORT', 5002))
    
    print("\n" + "=" * 60)
    print("🚀 Starting Chat-Only Server")
    print(f"📍 Server: http://{host}:{port}")
    print(f"💬 Chat endpoint: http://{host}:{port}/chat")
    print(f"❤️  Health check: http://{host}:{port}/health")
    print("=" * 60 + "\n")
    
    app.run(host=host, port=port, debug=(os.environ.get('FLASK_ENV') == 'development'))

