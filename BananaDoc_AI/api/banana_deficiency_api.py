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

app = Flask(__name__)
CORS(app)

# Initialize model loader
model_loader = ModelLoader(model_dir='../model')
deficiency_info_provider = DeficiencyInfoProvider()

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
        
        return jsonify(result)
    
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