import os
import numpy as np
import json

def create_mock_tflite():
    """
    Create a mock TFLite model file with metadata so the app can load it.
    This is a temporary solution until we can properly convert the real model.
    """
    print("Creating mock TFLite model file...")
    
    # Define paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    tflite_path = os.path.join(script_dir, "banana_mobile_model.tflite")
    labels_path = os.path.join(script_dir, "labels.txt")
    
    # Create a simple binary file with some model-like structure
    # This will not actually work for inference, but will allow the app to load it
    mock_model_data = np.zeros((1000, 1000), dtype=np.float32)
    mock_model_bytes = mock_model_data.tobytes()
    
    with open(tflite_path, 'wb') as f:
        f.write(mock_model_bytes)
    
    print(f"Mock TFLite model saved to: {tflite_path}")
    
    # Create labels file
    class_names = [
        "Healthy",
        "Nitrogen",
        "Phosphorus",
        "Potassium",
        "Calcium",
        "Magnesium",
        "Sulphur",
        "Iron"
    ]
    
    with open(labels_path, 'w') as f:
        for class_name in class_names:
            f.write(f"{class_name}\n")
    
    print(f"Labels file saved to: {labels_path}")
    
    # Also create a metadata json file that the app can use
    metadata = {
        "model_type": "classification",
        "input_shape": [1, 224, 224, 3],
        "output_shape": [1, 8],
        "labels": class_names,
        "is_mock": True,
        "creation_date": "2023-05-12"
    }
    
    metadata_path = os.path.join(script_dir, "model_metadata.json")
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"Model metadata saved to: {metadata_path}")
    
    print("\nNOTE: This is a mock TFLite model for testing app functionality.")
    print("It will allow the app to load the model, but actual inference will need the real model.")
    
    return True

if __name__ == "__main__":
    create_mock_tflite() 