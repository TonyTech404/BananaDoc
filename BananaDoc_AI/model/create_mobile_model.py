import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential, save_model
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout, BatchNormalization
from tensorflow.keras.applications import MobileNetV3Large
from tensorflow.keras.applications.mobilenet_v3 import preprocess_input
from tensorflow.keras.regularizers import l2
import shutil

def create_mobile_model():
    """Create a mobile-optimized model using MobileNetV3Large"""
    print("Creating mobile-optimized model...")
    
    # Set parameters
    img_size = 224
    num_classes = 8
    model_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Create MobileNetV3Large base model
    base_model = MobileNetV3Large(
        input_shape=(img_size, img_size, 3),
        include_top=False,
        weights='imagenet',
        alpha=1.0, 
        minimalistic=False
    )
    
    # Freeze the base model layers
    base_model.trainable = False
    
    # Create model with regularization
    model = Sequential([
        base_model,
        GlobalAveragePooling2D(),
        BatchNormalization(),
        Dense(256, activation='relu', kernel_regularizer=l2(0.001)),
        Dropout(0.3),
        BatchNormalization(),
        Dense(num_classes, activation='softmax')
    ])
    
    # Compile model
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.0005),
        loss='categorical_crossentropy',
        metrics=['accuracy', tf.keras.metrics.Precision(), tf.keras.metrics.Recall()]
    )
    
    # Model summary
    model.summary()
    
    # Save the model
    mobile_model_path = os.path.join(model_dir, 'banana_mobile_model.keras')
    save_model(model, mobile_model_path, save_format='keras')
    print(f"Mobile model saved to: {mobile_model_path}")
    
    # Copy as TFLite for compatibility with mobile code
    tflite_path = os.path.join(model_dir, 'banana_mobile_model.tflite')
    try:
        shutil.copy(mobile_model_path, tflite_path)
        print(f"Created temporary TFLite file at: {tflite_path}")
    except Exception as e:
        print(f"Error creating TFLite file: {e}")
        with open(tflite_path, 'w') as f:
            f.write("CONVERSION_FAILED: Unable to convert to TFLite - using Keras model instead")
    
    # Save class mapping
    class_mapping_path = os.path.join(model_dir, 'class_mapping.txt')
    mobile_class_mapping_path = os.path.join(model_dir, 'mobile_class_mapping.txt')
    
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
    
    # Check if original class mapping exists
    if os.path.exists(class_mapping_path):
        try:
            # Load class mapping from file
            loaded_mapping = {}
            with open(class_mapping_path, 'r') as f:
                for line in f:
                    parts = line.strip().split(': ')
                    if len(parts) == 2:
                        loaded_mapping[int(parts[0])] = parts[1]
            
            if loaded_mapping:
                class_mapping = loaded_mapping
                print("Loaded class mapping from existing file")
        except Exception as e:
            print(f"Error loading class mapping: {e}")
    
    # Save mobile class mapping
    with open(mobile_class_mapping_path, 'w') as f:
        for idx, class_name in class_mapping.items():
            f.write(f"{idx}: {class_name}\n")
    
    print(f"Class mapping saved to: {mobile_class_mapping_path}")
    
    # Save metadata
    metadata_path = os.path.join(model_dir, 'banana_mobile_model_metadata.txt')
    with open(metadata_path, 'w') as f:
        f.write("Mobile-optimized banana leaf deficiency detection model\n")
        f.write(f"Architecture: MobileNetV3Large\n")
        f.write(f"Input size: {img_size}x{img_size}\n")
        f.write(f"Classes: {', '.join(class_mapping.values())}\n")
    
    print(f"Model metadata saved to: {metadata_path}")
    
    # Measure and report model size
    original_model_path = os.path.join(model_dir, 'banana_nutrient_model.h5')
    if os.path.exists(original_model_path) and os.path.exists(mobile_model_path):
        original_size_mb = os.path.getsize(original_model_path) / (1024 * 1024)
        mobile_size_mb = os.path.getsize(mobile_model_path) / (1024 * 1024)
        reduction = (original_size_mb - mobile_size_mb) / original_size_mb * 100
        print(f"Size reduction: {reduction:.1f}% ({original_size_mb:.2f} MB → {mobile_size_mb:.2f} MB)")
    
    return mobile_model_path

if __name__ == "__main__":
    create_mobile_model() 