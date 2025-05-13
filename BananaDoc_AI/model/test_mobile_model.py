import os
import sys
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
import tensorflow as tf
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.mobilenet_v3 import preprocess_input

# Add parent directory to path so we can import utilities
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

class MobileBananaLeafDetector:
    """
    Class for mobile-optimized banana leaf deficiency detection using TFLite
    """
    
    def __init__(self, model_path=None, class_mapping_path=None):
        """
        Initialize the detector
        
        Args:
            model_path: Path to the TFLite model file
            class_mapping_path: Path to the class mapping file
        """
        # Set default paths
        if model_path is None:
            model_path = os.path.join(os.path.dirname(__file__), 'banana_mobile_model.tflite')
        
        if class_mapping_path is None:
            class_mapping_path = os.path.join(os.path.dirname(__file__), 'mobile_class_mapping.txt')
            # Fall back to original class mapping if mobile version doesn't exist
            if not os.path.exists(class_mapping_path):
                class_mapping_path = os.path.join(os.path.dirname(__file__), 'class_mapping.txt')
        
        self.model_path = model_path
        self.interpreter = None
        self.input_details = None
        self.output_details = None
        self.class_mapping = {}
        self.img_size = 224  # Default size for our model
        
        # Load the class mapping
        self._load_class_mapping(class_mapping_path)
        
        # Load the TFLite model
        self._load_model()
    
    def _load_class_mapping(self, mapping_path):
        """Load class mapping from file"""
        try:
            with open(mapping_path, 'r') as f:
                for line in f:
                    idx, class_name = line.strip().split(': ')
                    self.class_mapping[int(idx)] = class_name
            print(f"Loaded class mapping: {self.class_mapping}")
        except Exception as e:
            print(f"Error loading class mapping: {e}")
            # Default mappings
            self.class_mapping = {
                0: "Boron",
                1: "Calcium",
                2: "Healthy",
                3: "Iron",
                4: "Magnesium",
                5: "Manganese",
                6: "Potassium",
                7: "Zinc"
            }
            print("Using default class mapping")
    
    def _load_model(self):
        """Load the TFLite model"""
        try:
            # Load TFLite model and allocate tensors
            self.interpreter = tf.lite.Interpreter(model_path=self.model_path)
            self.interpreter.allocate_tensors()
            
            # Get input and output tensor details
            self.input_details = self.interpreter.get_input_details()
            self.output_details = self.interpreter.get_output_details()
            
            # Get actual input size from model
            input_shape = self.input_details[0]['shape']
            self.img_size = input_shape[1]  # Height should equal width
            
            # Check if model is quantized to int8
            self.is_quantized = self.input_details[0]['dtype'] == np.int8
            
            print(f"Model loaded: {self.model_path}")
            print(f"Input shape: {input_shape}")
            print(f"Quantized model: {self.is_quantized}")
            
            # Get input and output quantization parameters if needed
            if self.is_quantized:
                self.input_scale = self.input_details[0]['quantization_parameters']['scales'][0]
                self.input_zero_point = self.input_details[0]['quantization_parameters']['zero_points'][0]
                self.output_scale = self.output_details[0]['quantization_parameters']['scales'][0]
                self.output_zero_point = self.output_details[0]['quantization_parameters']['zero_points'][0]
                print(f"Input scale: {self.input_scale}, zero point: {self.input_zero_point}")
                print(f"Output scale: {self.output_scale}, zero point: {self.output_zero_point}")
            
            return True
        except Exception as e:
            print(f"Error loading TFLite model: {e}")
            return False
    
    def _preprocess_image(self, image_path):
        """
        Preprocess an image for inference
        
        Args:
            image_path: Path to the image file
            
        Returns:
            Preprocessed image array
        """
        try:
            # Open and resize image
            img = Image.open(image_path)
            if img.mode != 'RGB':
                img = img.convert('RGB')
            img = img.resize((self.img_size, self.img_size))
            
            # Convert to numpy array and normalize to [0, 1]
            img_array = np.array(img).astype(np.float32) / 255.0
            
            # Apply preprocessing (same as MobileNetV3)
            # Normalize to [-1, 1] with mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
            mean = [0.485, 0.456, 0.406]
            std = [0.229, 0.224, 0.225]
            for i in range(3):
                img_array[:, :, i] = (img_array[:, :, i] - mean[i]) / std[i]
            
            # Add batch dimension
            img_array = np.expand_dims(img_array, axis=0)
            
            # Quantize the input if the model is int8
            if self.is_quantized:
                img_array = img_array / self.input_scale + self.input_zero_point
                img_array = img_array.astype(np.int8)
            
            return img_array
        except Exception as e:
            print(f"Error preprocessing image: {e}")
            return None
    
    def predict(self, image_path):
        """
        Make a prediction on an image
        
        Args:
            image_path: Path to the image file
            
        Returns:
            Tuple of (predicted_class, confidence, all_probabilities)
        """
        if self.interpreter is None:
            print("Model not loaded. Please load the model first.")
            return None, None, None
        
        # Preprocess the image
        input_data = self._preprocess_image(image_path)
        if input_data is None:
            return None, None, None
        
        # Set input tensor
        self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
        
        # Run inference
        self.interpreter.invoke()
        
        # Get output tensor
        output_data = self.interpreter.get_tensor(self.output_details[0]['index'])
        
        # Dequantize output if needed
        if self.is_quantized:
            output_data = (output_data.astype(np.float32) - self.output_zero_point) * self.output_scale
        
        # Convert to probabilities with softmax
        probabilities = tf.nn.softmax(output_data).numpy()[0]
        
        # Get predicted class and confidence
        predicted_idx = np.argmax(probabilities)
        confidence = float(probabilities[predicted_idx])
        
        # Map class index to name
        if predicted_idx in self.class_mapping:
            predicted_class = self.class_mapping[predicted_idx]
        else:
            predicted_class = f"Unknown class {predicted_idx}"
        
        return predicted_class, confidence, probabilities
    
    def display_prediction(self, image_path, predicted_class, confidence, probabilities=None):
        """
        Display the image with prediction overlay
        
        Args:
            image_path: Path to the image file
            predicted_class: Predicted class name
            confidence: Prediction confidence
            probabilities: All class probabilities (optional)
        """
        # Open image
        img = Image.open(image_path)
        
        # Create plot
        plt.figure(figsize=(10, 8))
        
        # Display image
        plt.subplot(1, 2 if probabilities is not None else 1, 1)
        plt.imshow(img)
        plt.title(f"Predicted: {predicted_class}\nConfidence: {confidence:.2%}")
        plt.axis('off')
        
        # Display probability bar chart if available
        if probabilities is not None:
            plt.subplot(1, 2, 2)
            
            # Sort probabilities
            indices = np.argsort(probabilities)[::-1]
            sorted_classes = [self.class_mapping.get(idx, f"Class {idx}") for idx in indices]
            sorted_probs = probabilities[indices]
            
            # Plot horizontal bar chart
            plt.barh(range(len(sorted_classes)), sorted_probs)
            plt.yticks(range(len(sorted_classes)), sorted_classes)
            plt.title("Class Probabilities")
            plt.xlabel("Probability")
            plt.tight_layout()
        
        plt.tight_layout()
        plt.show()
        
    def get_memory_usage(self):
        """Get model memory usage in MB"""
        if self.interpreter is None:
            return 0
        
        # Get memory usage
        # This is an approximation based on model size
        try:
            size_bytes = os.path.getsize(self.model_path)
            size_mb = size_bytes / (1024 * 1024)
            
            # Include model in memory
            # TFLite interpreter typically uses about 1.2-1.5x the file size in memory
            memory_usage = size_mb * 1.3
            
            return memory_usage
        except:
            return 0
    
    def benchmark(self, image_path, num_runs=50):
        """
        Benchmark inference speed
        
        Args:
            image_path: Path to the test image
            num_runs: Number of inference runs to average
            
        Returns:
            Average inference time in milliseconds
        """
        if self.interpreter is None:
            print("Model not loaded.")
            return 0
        
        # Preprocess the image once
        input_data = self._preprocess_image(image_path)
        if input_data is None:
            return 0
        
        # Run warm-up inference
        self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
        self.interpreter.invoke()
        
        # Time inference runs
        import time
        total_time = 0
        
        for _ in range(num_runs):
            start_time = time.time()
            
            # Set input tensor
            self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
            
            # Run inference
            self.interpreter.invoke()
            
            # Get output tensor (include in timing)
            self.interpreter.get_tensor(self.output_details[0]['index'])
            
            # Update total time
            total_time += (time.time() - start_time)
        
        # Calculate average time in milliseconds
        avg_time_ms = (total_time / num_runs) * 1000
        return avg_time_ms

def load_and_preprocess_image(image_path, target_size=(224, 224)):
    """Load an image and preprocess it for inference"""
    img = image.load_img(image_path, target_size=target_size)
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)
    return img_array

def load_class_mapping(mapping_file):
    """Load class mapping from file"""
    class_mapping = {}
    try:
        with open(mapping_file, 'r') as f:
            for line in f:
                parts = line.strip().split(': ')
                if len(parts) == 2:
                    class_mapping[int(parts[0])] = parts[1]
    except Exception as e:
        print(f"Error loading class mapping: {e}")
        # Default mapping if file cannot be loaded
        class_mapping = {
            0: "Boron",
            1: "Calcium",
            2: "Healthy",
            3: "Iron",
            4: "Magnesium", 
            5: "Manganese",
            6: "Potassium",
            7: "Zinc"
        }
    return class_mapping

def test_image(model_path, image_path, mapping_file):
    """Test a single image with the model"""
    try:
        # Load the model
        print(f"Loading model from {model_path}...")
        model = load_model(model_path)
        print("Model loaded successfully!")
        
        # Load class mapping
        class_mapping = load_class_mapping(mapping_file)
        
        # Preprocess image
        print(f"Loading and preprocessing image: {image_path}")
        img_array = load_and_preprocess_image(image_path)
        
        # Run prediction
        print("Running prediction...")
        predictions = model.predict(img_array)
        
        # Get the predicted class
        predicted_class_idx = np.argmax(predictions[0])
        predicted_class = class_mapping.get(predicted_class_idx, f"Unknown (Class {predicted_class_idx})")
        confidence = predictions[0][predicted_class_idx] * 100
        
        # Display results
        print("\n=== Prediction Results ===")
        print(f"Predicted: {predicted_class} with {confidence:.2f}% confidence")
        
        # Show top 3 predictions
        top_3_indices = predictions[0].argsort()[-3:][::-1]
        print("\nTop 3 predictions:")
        for i, idx in enumerate(top_3_indices):
            class_name = class_mapping.get(idx, f"Unknown (Class {idx})")
            print(f"  {i+1}. {class_name}: {predictions[0][idx]*100:.2f}%")
            
        return True
    except Exception as e:
        print(f"Error testing image: {e}")
        return False

def find_sample_images(dataset_dir, num_samples=1):
    """Find sample images from the dataset directory"""
    sample_images = []
    
    if not os.path.exists(dataset_dir):
        print(f"Dataset directory not found: {dataset_dir}")
        return sample_images
        
    # Look for images in each class directory
    for class_name in os.listdir(dataset_dir):
        class_dir = os.path.join(dataset_dir, class_name)
        if os.path.isdir(class_dir):
            # Find image files in this class directory
            images = [os.path.join(class_dir, f) for f in os.listdir(class_dir) 
                      if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            
            # Take up to num_samples images from this class
            if images:
                sample_images.extend(images[:num_samples])
    
    return sample_images

def main():
    # Setup paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    model_path = os.path.join(script_dir, "finetuned_mobile_model.keras")  # Use finetuned model
    mapping_file = os.path.join(script_dir, "mobile_class_mapping.txt")
    
    # Check if a specific image path was provided
    if len(sys.argv) > 1:
        test_image(model_path, sys.argv[1], mapping_file)
        return
    
    # Otherwise, find sample images
    print("No image provided, finding sample images from the dataset...")
    
    # Get the dataset directory (adjusted path)
    project_root = os.path.dirname(os.path.dirname(script_dir))
    dataset_dir = os.path.join(project_root, "Images of Nutrient Deficient Banana Plant Leaves", 
                           "Version-2- Augmented Images of Banana leaves deficient in Nutrients")
    
    print(f"Looking for images in: {dataset_dir}")
    
    # Find sample images from each class
    sample_images = find_sample_images(dataset_dir, num_samples=1)
    
    if not sample_images:
        print("No sample images found. Please provide an image path as an argument.")
        return
    
    # Test each sample image
    for i, img_path in enumerate(sample_images):
        print(f"\n\n=== Testing Image {i+1}/{len(sample_images)} ===")
        print(f"Image: {img_path}")
        class_name = os.path.basename(os.path.dirname(img_path))
        print(f"Actual Class: {class_name}")
        
        test_image(model_path, img_path, mapping_file)

if __name__ == "__main__":
    main() 