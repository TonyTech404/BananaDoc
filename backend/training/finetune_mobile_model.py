import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model, save_model
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
import matplotlib.pyplot as plt

def finetune_mobile_model(batch_size=32, epochs=10, learning_rate=0.0001):
    """Fine-tune the mobile model on our dataset"""
    print("Starting fine-tuning of mobile model...")
    
    # Set up paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))
    model_path = os.path.join(script_dir, "banana_mobile_model.keras")
    
    # Dataset directory
    dataset_dir = os.path.join(project_root, "Images of Nutrient Deficient Banana Plant Leaves", 
                              "Version-2- Augmented Images of Banana leaves deficient in Nutrients")
    
    # Check if dataset exists
    if not os.path.exists(dataset_dir):
        print(f"Dataset directory not found: {dataset_dir}")
        return False
    
    # Check if model exists
    if not os.path.exists(model_path):
        print(f"Mobile model not found: {model_path}")
        return False
    
    print(f"Dataset directory: {dataset_dir}")
    print(f"Mobile model path: {model_path}")
    
    # Define image preprocessing and augmentation
    train_datagen = ImageDataGenerator(
        preprocessing_function=tf.keras.applications.mobilenet_v3.preprocess_input,
        rotation_range=30,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.3,
        horizontal_flip=True,
        vertical_flip=True,
        validation_split=0.2  # 20% for validation
    )
    
    # Create train and validation generators
    print("Creating data generators...")
    train_generator = train_datagen.flow_from_directory(
        dataset_dir,
        target_size=(224, 224),
        batch_size=batch_size,
        class_mode='categorical',
        subset='training',
        shuffle=True
    )
    
    validation_generator = train_datagen.flow_from_directory(
        dataset_dir,
        target_size=(224, 224),
        batch_size=batch_size,
        class_mode='categorical',
        subset='validation',
        shuffle=True
    )
    
    # Load the mobile model
    print("Loading mobile model...")
    model = load_model(model_path)
    
    # Make all layers trainable
    for layer in model.layers:
        layer.trainable = True
    
    # Recompile model with lower learning rate for fine-tuning
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate),
        loss='categorical_crossentropy',
        metrics=['accuracy', tf.keras.metrics.Precision(), tf.keras.metrics.Recall()]
    )
    
    # Set up callbacks for training
    callbacks = [
        EarlyStopping(
            monitor='val_loss',
            patience=5,
            restore_best_weights=True
        ),
        ModelCheckpoint(
            filepath=os.path.join(script_dir, "finetuned_mobile_model.keras"),
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        )
    ]
    
    # Train the model
    print(f"Fine-tuning model for {epochs} epochs...")
    history = model.fit(
        train_generator,
        epochs=epochs,
        validation_data=validation_generator,
        callbacks=callbacks
    )
    
    # Save the fine-tuned model
    finetuned_model_path = os.path.join(script_dir, "finetuned_mobile_model.keras")
    save_model(model, finetuned_model_path, save_format='keras')
    print(f"Fine-tuned model saved to: {finetuned_model_path}")
    
    # Create a copy as TFLite for compatibility
    tflite_path = os.path.join(script_dir, "banana_mobile_model.tflite")
    try:
        import shutil
        shutil.copy(finetuned_model_path, tflite_path)
        print(f"Updated TFLite file at: {tflite_path}")
        
        # Also update the Flutter assets
        flutter_assets_dir = os.path.join(project_root, "assets", "models")
        if os.path.exists(flutter_assets_dir):
            shutil.copy(finetuned_model_path, os.path.join(flutter_assets_dir, "banana_mobile_model.tflite"))
            print("Updated Flutter assets with fine-tuned model")
    except Exception as e:
        print(f"Error creating TFLite file: {e}")
    
    # Plot training history
    plt.figure(figsize=(12, 4))
    
    # Plot accuracy
    plt.subplot(1, 2, 1)
    plt.plot(history.history['accuracy'], label='Training Accuracy')
    plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
    plt.title('Model Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.legend()
    
    # Plot loss
    plt.subplot(1, 2, 2)
    plt.plot(history.history['loss'], label='Training Loss')
    plt.plot(history.history['val_loss'], label='Validation Loss')
    plt.title('Model Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.legend()
    
    # Save the plot
    plt.tight_layout()
    plt.savefig(os.path.join(script_dir, "finetuning_history.png"))
    print("Training history plot saved")
    
    return True

if __name__ == "__main__":
    # Start fine-tuning with slightly fewer epochs to make it faster
    finetune_mobile_model(batch_size=16, epochs=5, learning_rate=0.0001) 