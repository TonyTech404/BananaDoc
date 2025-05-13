import os
import sys
import numpy as np
import matplotlib.pyplot as plt
from glob import glob
from collections import Counter

# Add parent directory to path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.image_preprocessor import load_and_preprocess_image
from utils.model_loader import ModelLoader
from utils.deficiency_info import DeficiencyInfoProvider

def test_model_on_all_classes(data_dir=None):
    """
    Test the model on sample images from each class
    
    Args:
        data_dir: Directory containing class-separated images
    """
    if data_dir is None:
        print("Using default data directory")
        data_dir = "../Images of Nutrient Deficient Banana Plant Leaves/Version-2-RAW Images of Banana leaves deficient in Nutrients"
    
    if not os.path.exists(data_dir):
        print(f"Error: Data directory '{data_dir}' does not exist.")
        return False
    
    # Initialize model loader
    model_dir = os.path.abspath(os.path.dirname(__file__))
    model_loader = ModelLoader(model_dir=model_dir)
    
    # Load the model
    if not model_loader.load_model():
        print("Error: Could not load model.")
        return False
    
    # Dictionary to store results
    class_results = {}
    all_predictions = []
    excluded_class = 'Sulphur'  # Explicitly exclude Sulphur
    
    # Iterate through each class directory
    for class_dir in os.listdir(data_dir):
        class_path = os.path.join(data_dir, class_dir)
        if not os.path.isdir(class_path) or class_dir == excluded_class:
            if class_dir == excluded_class:
                print(f"Skipping excluded class: {class_dir}")
            continue
            
        print(f"\n=== Testing on {class_dir} class ===")
        
        # Get image files
        image_files = glob(os.path.join(class_path, "*.jpg")) + glob(os.path.join(class_path, "*.png"))
        if not image_files:
            print(f"No images found in {class_path}")
            continue
            
        # Test on up to 5 images per class
        test_files = image_files[:5]
        predictions = []
        
        for img_path in test_files:
            # Preprocess the image
            preprocessed_img = load_and_preprocess_image(img_path)
            
            # Make a prediction
            prediction_probs = model_loader.predict(preprocessed_img)
            predicted_class, confidence = model_loader.get_prediction_label(prediction_probs)
            
            # Store the prediction
            predictions.append(predicted_class)
            all_predictions.append(predicted_class)
            
            # Print the prediction
            print(f"Image: {os.path.basename(img_path)}")
            print(f"Predicted: {predicted_class} ({confidence*100:.2f}%)")
            print(f"Top 3 probabilities:")
            top_indices = np.argsort(prediction_probs)[-3:][::-1]
            for idx in top_indices:
                if idx in model_loader.class_mapping:
                    class_name = model_loader.class_mapping[idx]
                    print(f"  {class_name}: {prediction_probs[idx]*100:.2f}%")
                    
        # Calculate accuracy for the class
        correct_predictions = [p for p in predictions if p == class_dir]
        class_accuracy = len(correct_predictions) / len(predictions) if predictions else 0
        class_count = Counter(predictions)
        
        # Store the results
        class_results[class_dir] = {
            'accuracy': class_accuracy,
            'predictions': predictions,
            'counts': dict(class_count)
        }
        
        # Print a summary
        print(f"\nSummary for {class_dir} class:")
        print(f"Tested on {len(predictions)} images")
        print(f"Accuracy: {class_accuracy * 100:.2f}%")
        print(f"Prediction distribution: {dict(class_count)}")
    
    # Overall summary
    print("\n=== OVERALL SUMMARY ===")
    overall_counts = Counter(all_predictions)
    print(f"Total images tested: {len(all_predictions)}")
    print(f"Overall prediction distribution: {dict(overall_counts)}")
    
    # Plot the results
    _plot_prediction_distribution(class_results, overall_counts)
    
    return True
    
def _plot_prediction_distribution(class_results, overall_counts):
    """
    Plot the distribution of predictions for each class
    
    Args:
        class_results: Dictionary of results for each class
        overall_counts: Counter of all predictions
    """
    # Create a figure with two subplots
    plt.figure(figsize=(15, 10))
    
    # Plot the overall prediction distribution
    plt.subplot(2, 1, 1)
    labels = list(overall_counts.keys())
    values = [overall_counts[label] for label in labels]
    plt.bar(labels, values)
    plt.title('Overall Prediction Distribution')
    plt.xlabel('Predicted Class')
    plt.ylabel('Count')
    plt.xticks(rotation=45)
    
    # Plot the class-wise accuracy
    plt.subplot(2, 1, 2)
    class_names = list(class_results.keys())
    accuracies = [class_results[name]['accuracy'] * 100 for name in class_names]
    plt.bar(class_names, accuracies)
    plt.title('Class-wise Accuracy')
    plt.xlabel('True Class')
    plt.ylabel('Accuracy (%)')
    plt.axhline(y=50, color='r', linestyle='--')  # 50% accuracy line
    plt.xticks(rotation=45)
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'prediction_distribution.png'))
    print("Prediction distribution plot saved.")
    plt.close()

if __name__ == "__main__":
    # Get the data directory from command line arguments or use default
    data_dir = sys.argv[1] if len(sys.argv) > 1 else None
    test_model_on_all_classes(data_dir) 