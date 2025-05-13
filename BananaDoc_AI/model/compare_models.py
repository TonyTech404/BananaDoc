import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import time
from PIL import Image
import tensorflow as tf

# Add parent directory to path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import model utilities
from utils.model_loader import ModelLoader
from utils.image_preprocessor import load_and_preprocess_image

# Load the MobileBananaLeafDetector
from test_mobile_model import MobileBananaLeafDetector

class ModelComparator:
    """
    Class to compare standard and mobile-optimized models
    """
    
    def __init__(self, standard_model_dir=None, mobile_model_path=None):
        """
        Initialize the comparator
        
        Args:
            standard_model_dir: Directory with standard model files
            mobile_model_path: Path to mobile TFLite model
        """
        # Set default paths
        if standard_model_dir is None:
            standard_model_dir = os.path.dirname(os.path.abspath(__file__))
        
        if mobile_model_path is None:
            mobile_model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'banana_mobile_model.tflite')
        
        # Initialize standard model loader
        self.standard_model_loader = ModelLoader(model_dir=standard_model_dir)
        
        # Initialize mobile model
        self.mobile_detector = MobileBananaLeafDetector(model_path=mobile_model_path)
        
        # Check if models are loaded
        self.standard_model_loaded = self.standard_model_loader.load_model()
        self.mobile_model_loaded = self.mobile_detector.interpreter is not None
        
        if not self.standard_model_loaded:
            print("Warning: Standard model could not be loaded")
        
        if not self.mobile_model_loaded:
            print("Warning: Mobile model could not be loaded")
    
    def run_comparison(self, image_paths, num_runs=10):
        """
        Run comparison on a list of images
        
        Args:
            image_paths: List of image paths to test
            num_runs: Number of runs for performance benchmarking
            
        Returns:
            Dictionary with comparison results
        """
        if not self.standard_model_loaded or not self.mobile_model_loaded:
            print("Error: One or both models could not be loaded.")
            return None
        
        results = {
            'standard_model': {
                'predictions': [],
                'inference_times': [],
                'model_size': 0,
            },
            'mobile_model': {
                'predictions': [],
                'inference_times': [],
                'model_size': 0,
            },
            'agreement': [],
            'model_sizes': {},
            'avg_inference_times': {},
        }
        
        # Get model sizes
        standard_model_path = os.path.join(self.standard_model_loader.model_dir, 'banana_nutrient_model.h5')
        if os.path.exists(standard_model_path):
            results['model_sizes']['standard'] = os.path.getsize(standard_model_path) / (1024 * 1024)  # MB
        
        if os.path.exists(self.mobile_detector.model_path):
            results['model_sizes']['mobile'] = os.path.getsize(self.mobile_detector.model_path) / (1024 * 1024)  # MB
        
        # Process each image
        for image_path in image_paths:
            print(f"\nProcessing image: {os.path.basename(image_path)}")
            
            # Run standard model prediction
            standard_time_start = time.time()
            for _ in range(num_runs):
                # Preprocess image
                img_array = load_and_preprocess_image(image_path)
                
                # Run prediction
                standard_predictions = self.standard_model_loader.predict(img_array)
                
                # Get labels
                standard_label, standard_confidence = self.standard_model_loader.get_prediction_label(standard_predictions)
            
            standard_time_end = time.time()
            standard_avg_time = ((standard_time_end - standard_time_start) / num_runs) * 1000  # ms
            
            # Store standard model results
            results['standard_model']['predictions'].append({
                'image': os.path.basename(image_path),
                'label': standard_label,
                'confidence': standard_confidence,
                'predictions': standard_predictions.tolist(),
            })
            results['standard_model']['inference_times'].append(standard_avg_time)
            
            # Run mobile model prediction
            mobile_avg_time = self.mobile_detector.benchmark(image_path, num_runs=num_runs)
            mobile_label, mobile_confidence, mobile_predictions = self.mobile_detector.predict(image_path)
            
            # Store mobile model results
            results['mobile_model']['predictions'].append({
                'image': os.path.basename(image_path),
                'label': mobile_label,
                'confidence': mobile_confidence,
                'predictions': mobile_predictions.tolist() if mobile_predictions is not None else None,
            })
            results['mobile_model']['inference_times'].append(mobile_avg_time)
            
            # Check agreement
            agreement = standard_label == mobile_label
            results['agreement'].append(agreement)
            
            # Print result
            print(f"  Standard model: {standard_label} ({standard_confidence:.2%})")
            print(f"  Mobile model: {mobile_label} ({mobile_confidence:.2%})")
            print(f"  Agreement: {agreement}")
            print(f"  Standard time: {standard_avg_time:.2f} ms, Mobile time: {mobile_avg_time:.2f} ms")
        
        # Calculate average inference times
        results['avg_inference_times'] = {
            'standard': sum(results['standard_model']['inference_times']) / len(results['standard_model']['inference_times']),
            'mobile': sum(results['mobile_model']['inference_times']) / len(results['mobile_model']['inference_times']),
        }
        
        # Calculate agreement percentage
        results['agreement_percentage'] = sum(results['agreement']) / len(results['agreement']) * 100
        
        # Return results
        return results
    
    def display_comparison_results(self, results):
        """
        Display comparison results with charts
        
        Args:
            results: Results dictionary from run_comparison
        """
        if results is None:
            print("No valid results to display")
            return
        
        # Print summary
        print("\n=== MODEL COMPARISON SUMMARY ===")
        print(f"Number of test images: {len(results['agreement'])}")
        print(f"Agreement rate: {results['agreement_percentage']:.2f}%")
        
        # Print model sizes
        print("\n=== MODEL SIZES ===")
        if 'standard' in results['model_sizes']:
            print(f"Standard model (H5): {results['model_sizes']['standard']:.2f} MB")
        
        if 'mobile' in results['model_sizes']:
            print(f"Mobile model (TFLite): {results['model_sizes']['mobile']:.2f} MB")
            
            # Calculate size reduction
            if 'standard' in results['model_sizes']:
                size_reduction = ((results['model_sizes']['standard'] - results['model_sizes']['mobile']) / 
                                 results['model_sizes']['standard']) * 100
                print(f"Size reduction: {size_reduction:.2f}%")
        
        # Print inference times
        print("\n=== INFERENCE SPEEDS ===")
        print(f"Standard model: {results['avg_inference_times']['standard']:.2f} ms")
        print(f"Mobile model: {results['avg_inference_times']['mobile']:.2f} ms")
        
        # Calculate speed improvement
        speed_improvement = ((results['avg_inference_times']['standard'] - results['avg_inference_times']['mobile']) / 
                             results['avg_inference_times']['standard']) * 100
        print(f"Speed improvement: {speed_improvement:.2f}%")
        
        # Create comparison plots
        plt.figure(figsize=(15, 10))
        
        # Plot 1: Model sizes
        plt.subplot(2, 2, 1)
        model_names = []
        model_sizes = []
        
        if 'standard' in results['model_sizes']:
            model_names.append('Standard (H5)')
            model_sizes.append(results['model_sizes']['standard'])
        
        if 'mobile' in results['model_sizes']:
            model_names.append('Mobile (TFLite)')
            model_sizes.append(results['model_sizes']['mobile'])
        
        plt.bar(model_names, model_sizes)
        plt.title('Model Size Comparison (MB)')
        plt.ylabel('Size (MB)')
        
        # Plot 2: Inference times
        plt.subplot(2, 2, 2)
        plt.bar(['Standard Model', 'Mobile Model'], 
                [results['avg_inference_times']['standard'], results['avg_inference_times']['mobile']])
        plt.title('Average Inference Time (ms)')
        plt.ylabel('Time (ms)')
        
        # Plot 3: Agreement per image
        plt.subplot(2, 2, 3)
        image_names = [pred['image'] for pred in results['standard_model']['predictions']]
        agreement_values = [1 if agree else 0 for agree in results['agreement']]
        
        plt.bar(range(len(image_names)), agreement_values)
        plt.xticks(range(len(image_names)), image_names, rotation=45)
        plt.title('Model Agreement by Image')
        plt.ylabel('Agreement (1=Yes, 0=No)')
        
        # Plot 4: Confidence comparison
        plt.subplot(2, 2, 4)
        standard_conf = [pred['confidence'] for pred in results['standard_model']['predictions']]
        mobile_conf = [pred['confidence'] for pred in results['mobile_model']['predictions']]
        
        x = range(len(image_names))
        plt.bar([i - 0.2 for i in x], standard_conf, width=0.4, label='Standard Model')
        plt.bar([i + 0.2 for i in x], mobile_conf, width=0.4, label='Mobile Model')
        plt.xticks(x, image_names, rotation=45)
        plt.title('Confidence Comparison')
        plt.ylabel('Confidence')
        plt.legend()
        
        plt.tight_layout()
        plt.savefig(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'model_comparison.png'))
        plt.show()

def find_sample_images(data_dir, num_per_class=1):
    """
    Find sample images for testing
    
    Args:
        data_dir: Data directory with class subdirectories
        num_per_class: Number of images to select per class
        
    Returns:
        List of image paths
    """
    image_paths = []
    
    if not os.path.exists(data_dir):
        print(f"Data directory not found: {data_dir}")
        return image_paths
    
    # Find class directories
    class_dirs = []
    for item in os.listdir(data_dir):
        item_path = os.path.join(data_dir, item)
        if os.path.isdir(item_path) and not item.startswith('.'):
            class_dirs.append(item_path)
    
    # Select images from each class
    for class_dir in class_dirs:
        class_name = os.path.basename(class_dir)
        
        # Skip Sulphur class (if we're still excluding it)
        if class_name == 'Sulphur':
            continue
        
        # Find all images
        candidate_images = []
        for file in os.listdir(class_dir):
            if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                candidate_images.append(os.path.join(class_dir, file))
        
        # Select random images
        if candidate_images:
            # Sort for deterministic selection or use random.sample for true randomness
            candidate_images.sort()
            selected = candidate_images[:num_per_class]
            image_paths.extend(selected)
            print(f"Selected {len(selected)} images from {class_name} class")
    
    return image_paths

if __name__ == "__main__":
    # Path to data directory
    data_dir = "/Users/antonio/Documents/development_folder/BananaDoc/Images of Nutrient Deficient Banana Plant Leaves"
    
    # Find sample images
    print("Finding sample images...")
    sample_images = find_sample_images(data_dir, num_per_class=1)
    
    if not sample_images:
        print("No sample images found. Please provide the correct data directory.")
        sys.exit(1)
    
    print(f"Found {len(sample_images)} sample images")
    
    # Initialize comparator
    print("\nInitializing model comparator...")
    comparator = ModelComparator()
    
    # Run comparison
    print("\nRunning model comparison...")
    results = comparator.run_comparison(sample_images, num_runs=10)
    
    # Display results
    if results:
        comparator.display_comparison_results(results)
        print("\nComparison completed! Results saved to 'model_comparison.png'")
    else:
        print("Error: Comparison failed. Please check if both models are available.") 