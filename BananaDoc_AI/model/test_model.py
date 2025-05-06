import os
import sys
import numpy as np
import matplotlib.pyplot as plt

# Add parent directory to path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.image_preprocessor import load_and_preprocess_image
from utils.model_loader import ModelLoader
from utils.deficiency_info import DeficiencyInfoProvider

# Initialize model loader and deficiency info provider
model_dir = os.path.abspath(os.path.dirname(__file__))  # Use absolute path
model_loader = ModelLoader(model_dir=model_dir)
deficiency_info_provider = DeficiencyInfoProvider()

def test_on_image(img_path):
    """
    Test the model on a single image
    
    Args:
        img_path: Path to the image file
        
    Returns:
        Tuple of (deficiency_type, confidence)
    """
    # Load and preprocess the image
    preprocessed_img = load_and_preprocess_image(img_path)
    
    # Make a prediction
    predictions = model_loader.predict(preprocessed_img)
    
    # Get the predicted deficiency type and confidence
    deficiency_type, confidence = model_loader.get_prediction_label(predictions)
    
    # Get deficiency information
    deficiency_info = deficiency_info_provider.get_deficiency_info(deficiency_type)
    
    # Display the image with the prediction
    _display_image_with_prediction(img_path, deficiency_type, confidence, predictions)
    
    # Print detailed information
    _print_deficiency_details(deficiency_type, confidence, deficiency_info, predictions)
    
    return deficiency_type, confidence

def _display_image_with_prediction(img_path, deficiency_type, confidence, all_probs):
    """Display the image with the prediction"""
    from tensorflow.keras.preprocessing import image
    
    # Load the image
    original_img = image.load_img(img_path)
    
    # Create a figure
    plt.figure(figsize=(8, 8))
    
    # Display original image
    plt.imshow(original_img)
    plt.axis('off')
    
    # Display prediction as title
    plt.title(f"Predicted: {deficiency_type} ({confidence*100:.2f}%)")
    
    plt.tight_layout()
    plt.show()

def _print_deficiency_details(deficiency_type, confidence, deficiency_info, all_probs):
    """Print detailed information about the prediction"""
    print(f"\n=== PREDICTION RESULT ===")
    print(f"Deficiency: {deficiency_type}")
    print(f"Confidence: {confidence*100:.2f}%")
    print("\n=== DEFICIENCY DETAILS ===")
    print(f"Symptoms: {deficiency_info['symptoms']}")
    print(f"Treatment: {deficiency_info['treatment']}")
    print(f"Prevention: {deficiency_info['prevention']}")
    
    print("\n=== PROBABILITY FOR EACH CLASS ===")
    for i, prob in enumerate(all_probs):
        if i in model_loader.class_mapping:
            print(f"{model_loader.class_mapping[i]}: {prob*100:.2f}%")

if __name__ == "__main__":
    import sys
    
    # Load the model
    if not model_loader.load_model():
        print("Error: Could not load model.")
        sys.exit(1)
    
    if len(sys.argv) > 1:
        img_path = sys.argv[1]
        if os.path.exists(img_path):
            deficiency_type, confidence = test_on_image(img_path)
            print(f"\nSummary: The banana leaf shows {deficiency_type} {'deficiency' if deficiency_type != 'Healthy' else 'leaves'} with {confidence*100:.2f}% confidence.")
        else:
            print(f"Error: Image path '{img_path}' does not exist.")
    else:
        print("Usage: python test_model.py <path_to_image>")
        print("Please provide a path to a banana leaf image.") 