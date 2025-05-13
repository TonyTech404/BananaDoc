import tensorflow as tf
import os
import numpy as np

class ModelLoader:
    def __init__(self, model_dir='../model'):
        """
        Initialize the model loader
        
        Args:
            model_dir: Directory where model files are stored
        """
        # Convert to absolute path if relative
        if not os.path.isabs(model_dir):
            current_dir = os.path.dirname(os.path.abspath(__file__))
            self.model_dir = os.path.abspath(os.path.join(current_dir, model_dir))
        else:
            self.model_dir = model_dir
            
        print(f"Using model directory: {self.model_dir}")
        self.model = None
        self.interpreter = None
        self.input_details = None
        self.output_details = None
        self.class_mapping = {}
        
        # Load class mapping
        self._load_class_mapping()
        
    def _load_class_mapping(self):
        """Load class mapping from file or use default mapping"""
        mapping_file = os.path.join(self.model_dir, 'class_mapping.txt')
        
        try:
            with open(mapping_file, 'r') as f:
                for line in f:
                    idx, class_name = line.strip().split(': ')
                    self.class_mapping[int(idx)] = class_name
            print(f"Loaded class mapping: {self.class_mapping}")
        except FileNotFoundError:
            # Default mappings in case the file doesn't exist yet
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
            print("Used default class mapping without Sulphur class")
    
    def load_model(self):
        """
        Load the trained model
        
        Returns:
            True if model loaded successfully, False otherwise
        """
        h5_model_path = os.path.join(self.model_dir, 'banana_nutrient_model.h5')
        tflite_model_path = os.path.join(self.model_dir, 'banana_nutrient_model.tflite')
        
        try:
            # Try to load the h5 model
            self.model = tf.keras.models.load_model(h5_model_path)
            print("Model loaded successfully (h5 format)")
            return True
        except:
            try:
                # Try to load the TFLite model
                self.interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
                self.interpreter.allocate_tensors()
                
                # Get input and output tensors
                self.input_details = self.interpreter.get_input_details()
                self.output_details = self.interpreter.get_output_details()
                print("TFLite Model loaded successfully")
                return True
            except Exception as e:
                print(f"Error loading model: {e}")
                return False
    
    def predict(self, img_array):
        """
        Make prediction using the model
        
        Args:
            img_array: Preprocessed image array
            
        Returns:
            Array of prediction probabilities
        """
        if self.model is not None:
            # Using Keras model
            predictions = self.model.predict(img_array)
            return predictions[0]
        elif self.interpreter is not None:
            # Using TFLite interpreter
            self.interpreter.set_tensor(self.input_details[0]['index'], img_array)
            self.interpreter.invoke()
            output_data = self.interpreter.get_tensor(self.output_details[0]['index'])
            return output_data[0]
        else:
            raise Exception("No model loaded. Call load_model() first")
    
    def get_prediction_label(self, predictions):
        """
        Get the predicted class from prediction probabilities
        
        Args:
            predictions: Prediction probabilities array
            
        Returns:
            Tuple of (class_name, confidence)
        """
        predicted_class_idx = np.argmax(predictions)
        confidence = float(predictions[predicted_class_idx])
        
        # Get the deficiency type
        if predicted_class_idx in self.class_mapping:
            deficiency_type = self.class_mapping[predicted_class_idx]
        else:
            deficiency_type = f"Unknown class {predicted_class_idx}"
            
        return deficiency_type, confidence 