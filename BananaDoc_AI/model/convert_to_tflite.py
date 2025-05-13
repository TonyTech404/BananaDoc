import os
import tensorflow as tf
import numpy as np

def convert_keras_to_tflite(keras_model_path, tflite_model_path):
    """
    Convert a Keras model to TFLite format
    
    Args:
        keras_model_path: Path to the Keras model file
        tflite_model_path: Path to save the TFLite model
    """
    print(f"Loading Keras model from: {keras_model_path}")
    model = tf.keras.models.load_model(keras_model_path)
    
    print("Converting model to TFLite with minimal options...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Use basic conversion settings to avoid compatibility issues
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS]
    
    # Convert the model
    try:
        tflite_model = converter.convert()
        
        # Save the TFLite model
        with open(tflite_model_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"TFLite model saved to: {tflite_model_path}")
        
        # Get model size information
        keras_size = os.path.getsize(keras_model_path) / (1024 * 1024)
        tflite_size = os.path.getsize(tflite_model_path) / (1024 * 1024)
        reduction = (1 - tflite_size / keras_size) * 100
        
        print(f"Original model size: {keras_size:.2f} MB")
        print(f"TFLite model size: {tflite_size:.2f} MB")
        print(f"Size reduction: {reduction:.2f}%")
        
        # Create metadata file
        metadata_path = os.path.splitext(tflite_model_path)[0] + "_metadata.txt"
        with open(metadata_path, 'w') as f:
            f.write(f"Model: {os.path.basename(keras_model_path)}\n")
            f.write(f"Input shape: {model.input_shape}\n")
            f.write(f"Output shape: {model.output_shape}\n")
            f.write(f"Original size: {keras_size:.2f} MB\n")
            f.write(f"TFLite size: {tflite_size:.2f} MB\n")
            f.write(f"Size reduction: {reduction:.2f}%\n")
        
        print(f"Metadata saved to: {metadata_path}")
        return True
    except Exception as e:
        print(f"Error during conversion: {e}")
        
        # Try an even simpler conversion approach
        print("Trying alternative conversion approach...")
        try:
            # Create a simple SavedModel format as intermediary step
            export_dir = os.path.join(os.path.dirname(keras_model_path), 'saved_model_temp')
            tf.saved_model.save(model, export_dir)
            
            # Convert from SavedModel format
            converter = tf.lite.TFLiteConverter.from_saved_model(export_dir)
            tflite_model = converter.convert()
            
            # Save the model
            with open(tflite_model_path, 'wb') as f:
                f.write(tflite_model)
                
            print(f"TFLite model saved using alternative approach: {tflite_model_path}")
            
            # Cleanup temp directory
            try:
                import shutil
                shutil.rmtree(export_dir)
            except:
                pass
                
            return True
        except Exception as e2:
            print(f"Alternative conversion also failed: {e2}")
            return False

if __name__ == "__main__":
    # Set up paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Use the finetuned model
    keras_model_path = os.path.join(script_dir, "finetuned_mobile_model.keras")
    tflite_model_path = os.path.join(script_dir, "banana_mobile_model.tflite")
    
    # Check if Keras model exists
    if not os.path.exists(keras_model_path):
        print(f"Keras model not found: {keras_model_path}")
        exit(1)
    
    # Convert the model
    convert_keras_to_tflite(keras_model_path, tflite_model_path) 