import numpy as np
import tensorflow as tf

def create_minimal_tflite_model():
    """
    Create a minimal valid TFLite model that can be loaded by Flutter app.
    This model will just return mock predictions but has a valid TFLite structure.
    """
    print("Creating a minimal valid TFLite model...")
    
    # Create a very simple model
    # Input shape: [1, 224, 224, 3] - standard image input
    # Output shape: [1, 8] - 8 classes for different deficiencies
    
    # Define a simple TF model
    model = tf.keras.Sequential([
        tf.keras.layers.InputLayer(input_shape=(224, 224, 3)),
        tf.keras.layers.Conv2D(8, kernel_size=(3, 3), activation='relu'),
        tf.keras.layers.MaxPooling2D(pool_size=(2, 2)),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(8, activation='softmax')
    ])
    
    # Build and compile the model
    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    
    # Save the TFLite model
    model_path = "banana_mobile_model.tflite"
    with open(model_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Minimal TFLite model saved to: {model_path}")
    print(f"Model size: {len(tflite_model) / 1024:.2f} KB")
    
    # Create a labels file
    labels = [
        "Healthy",
        "Nitrogen",
        "Phosphorus",
        "Potassium",
        "Calcium",
        "Magnesium",
        "Sulphur",
        "Iron"
    ]
    
    # Save labels to a file (one class per line)
    labels_path = "labels.txt"
    with open(labels_path, 'w') as f:
        for label in labels:
            f.write(f"{label}\n")
    
    print(f"Labels saved to: {labels_path}")
    
    return True

if __name__ == "__main__":
    create_minimal_tflite_model() 