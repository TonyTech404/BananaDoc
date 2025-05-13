import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
from tensorflow.keras.preprocessing.image import ImageDataGenerator

def create_simple_model():
    """Create a simple CNN model that can be more easily converted to TFLite"""
    print("Creating a simple CNN model for easier TFLite conversion...")
    
    # Set parameters
    img_size = 224
    num_classes = 8
    
    # Create a simple CNN model
    model = Sequential([
        # Input layer
        Conv2D(32, (3, 3), activation='relu', input_shape=(img_size, img_size, 3), padding='same'),
        MaxPooling2D(2, 2),
        
        # Second layer
        Conv2D(64, (3, 3), activation='relu', padding='same'),
        MaxPooling2D(2, 2),
        
        # Third layer
        Conv2D(128, (3, 3), activation='relu', padding='same'),
        MaxPooling2D(2, 2),
        
        # Flatten and dense layers
        Flatten(),
        Dense(256, activation='relu'),
        Dropout(0.5),
        Dense(num_classes, activation='softmax')
    ])
    
    # Compile the model
    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    model.summary()
    
    return model

def train_simple_model(batch_size=32, epochs=10):
    """Train the simple model on our dataset"""
    print("Training simple model...")
    
    # Set up paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))
    
    # Dataset directory
    dataset_dir = os.path.join(project_root, "Images of Nutrient Deficient Banana Plant Leaves/Version-2- Augmented Images of Banana leaves deficient in Nutrients")
    
    # Create model
    model = create_simple_model()
    
    # Data augmentation for training
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        validation_split=0.2,
        rotation_range=20,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest'
    )
    
    # Load training data
    train_generator = train_datagen.flow_from_directory(
        dataset_dir,
        target_size=(224, 224),
        batch_size=batch_size,
        class_mode='categorical',
        subset='training',
        shuffle=True
    )
    
    # Load validation data
    validation_generator = train_datagen.flow_from_directory(
        dataset_dir,
        target_size=(224, 224),
        batch_size=batch_size,
        class_mode='categorical',
        subset='validation',
        shuffle=False
    )
    
    # Save class mapping
    class_indices = train_generator.class_indices
    class_mapping_path = os.path.join(script_dir, "class_mapping.txt")
    with open(class_mapping_path, 'w') as f:
        for class_name, index in class_indices.items():
            f.write(f"{index}: {class_name}\n")
    print(f"Class mapping saved to: {class_mapping_path}")
    
    # Train the model
    history = model.fit(
        train_generator,
        steps_per_epoch=train_generator.samples // batch_size,
        validation_data=validation_generator,
        validation_steps=validation_generator.samples // batch_size,
        epochs=epochs,
        verbose=1
    )
    
    # Save the trained model
    model_path = os.path.join(script_dir, "simple_banana_model.keras")
    model.save(model_path)
    print(f"Model saved to: {model_path}")
    
    # Convert to TFLite
    tflite_model_path = os.path.join(script_dir, "banana_mobile_model.tflite")
    convert_to_tflite(model, tflite_model_path)
    
    return model, history

def convert_to_tflite(model, tflite_path):
    """Convert the model to TFLite format"""
    print(f"Converting model to TFLite: {tflite_path}")
    
    # Convert the model
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    
    # Save the TFLite model
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"TFLite model saved to: {tflite_path}")
    model_size = os.path.getsize(tflite_path) / (1024 * 1024)
    print(f"TFLite model size: {model_size:.2f} MB")
    
    # Also save a TXT version of the labels for Flutter
    class_mapping_path = os.path.join(os.path.dirname(tflite_path), "class_mapping.txt")
    labels_path = os.path.join(os.path.dirname(tflite_path), "labels.txt")
    
    if os.path.exists(class_mapping_path):
        # Read the mapping file
        class_names = []
        with open(class_mapping_path, 'r') as f:
            for line in f:
                parts = line.strip().split(': ')
                if len(parts) == 2:
                    index = int(parts[0])
                    class_name = parts[1]
                    class_names.append((index, class_name))
        
        # Sort by index and save just the class names
        class_names.sort(key=lambda x: x[0])
        with open(labels_path, 'w') as f:
            for _, class_name in class_names:
                f.write(f"{class_name}\n")
        
        print(f"Labels file saved to: {labels_path}")

if __name__ == "__main__":
    train_simple_model(epochs=15) 