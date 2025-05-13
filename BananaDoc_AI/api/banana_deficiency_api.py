import os
import sys
import base64
from io import BytesIO
from flask import Flask, request, jsonify
from flask_cors import CORS

# Add parent directory to path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.image_preprocessor import decode_and_load_base64_image
from utils.model_loader import ModelLoader
from utils.deficiency_info import DeficiencyInfoProvider
from utils.gemini_handler import GeminiHandler

app = Flask(__name__)
CORS(app)

# Initialize components
model_loader = ModelLoader(model_dir='../model')
deficiency_info_provider = DeficiencyInfoProvider()
gemini_handler = GeminiHandler()

@app.route('/predict', methods=['POST'])
def predict_api():
    if not request.json or 'image' not in request.json:
        return jsonify({'error': 'No image provided'}), 400
    
    # Get the base64 encoded image
    image_data = request.json['image']
    
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
        return jsonify({'error': str(e)}), 500

@app.route('/chat', methods=['POST'])
def chat_api():
    """Handle a chat query using the Gemini API with context awareness"""
    if not request.json or 'query' not in request.json:
        return jsonify({'error': 'No query provided'}), 400
    
    try:
        # Get the user query
        user_query = request.json['query']
        
        # Process the query
        response = gemini_handler.process_query(user_query)
        
        return jsonify({
            'response': response
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/clear-context', methods=['POST'])
def clear_context():
    """Clear the conversation context"""
    try:
        gemini_handler.context_manager.clear_context()
        return jsonify({'message': 'Context cleared successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/context', methods=['GET'])
def get_context():
    """Get the current context for debugging"""
    try:
        return jsonify(gemini_handler.context_manager.get_context_for_llm())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Check if the API is healthy and the model is loaded"""
    model_loaded = (model_loader.model is not None or model_loader.interpreter is not None)
    return jsonify({
        'status': 'healthy', 
        'model_loaded': model_loaded
    })

@app.route('/deficiencies', methods=['GET'])
def get_deficiencies():
    """Get a list of all possible deficiencies"""
    return jsonify({
        'deficiencies': deficiency_info_provider.get_all_deficiencies()
    })

@app.route('/deficiency/<deficiency_type>', methods=['GET'])
def get_deficiency_details(deficiency_type):
    """Get detailed information about a specific deficiency"""
    info = deficiency_info_provider.get_deficiency_info(deficiency_type)
    return jsonify(info)

if __name__ == '__main__':
    # Load the model
    model_loaded = model_loader.load_model()
    if not model_loaded:
        print("Warning: No model loaded. Server will start but predictions will fail.")
    
    # Start the Flask server
    port = int(os.environ.get('PORT', 5002))
    app.run(host='0.0.0.0', port=port) 