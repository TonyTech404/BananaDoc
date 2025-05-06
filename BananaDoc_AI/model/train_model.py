import os
import numpy as np
import tensorflow as tf
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
from keras.preprocessing.image import ImageDataGenerator
from keras.applications import MobileNetV2
from keras.applications.mobilenet_v2 import preprocess_input
from keras.callbacks import ModelCheckpoint, EarlyStopping
import matplotlib.pyplot as plt

class BananaLeafDeficiencyModelTrainer:
    """
    Class to train a banana leaf nutrient deficiency detection model
    """
    
    def __init__(
        self, 
        raw_data_dir="../Images of Nutrient Deficient Banana Plant Leaves/Version-2-RAW Images of Banana leaves deficient in Nutrients",
        augmented_data_dir="../Images of Nutrient Deficient Banana Plant Leaves/Version-2- Augmented Images of Banana leaves deficient in Nutrients",
        img_size=224,
        batch_size=32,
        epochs=50
    ):
        """
        Initialize the model trainer
        
        Args:
            raw_data_dir: Directory with raw images
            augmented_data_dir: Directory with augmented images
            img_size: Size to resize images to
            batch_size: Batch size for training
            epochs: Number of training epochs
        """
        self.raw_data_dir = raw_data_dir
        self.augmented_data_dir = augmented_data_dir
        self.img_size = img_size
        self.batch_size = batch_size
        self.epochs = epochs
        self.num_classes = 9  # 8 nutrient deficiencies + healthy
        self.model = None
        self.history = None
        self.class_indices = None
        self.class_names = None
    
    def create_data_generators(self):
        """Create data generators for training and validation"""
        # Data generator with augmentation for training
        train_datagen = ImageDataGenerator(
            preprocessing_function=preprocess_input,
            rotation_range=20,
            width_shift_range=0.2,
            height_shift_range=0.2,
            shear_range=0.2,
            zoom_range=0.2,
            horizontal_flip=True,
            validation_split=0.2  # 20% for validation
        )
        
        # Create generators
        train_generator = train_datagen.flow_from_directory(
            self.augmented_data_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode='categorical',
            subset='training'
        )
        
        validation_generator = train_datagen.flow_from_directory(
            self.augmented_data_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode='categorical',
            subset='validation'
        )
        
        # Save class indices
        self.class_indices = train_generator.class_indices
        self.class_names = list(self.class_indices.keys())
        print(f"Classes: {self.class_names}")
        
        # Save class mapping to a file
        with open(os.path.join(os.path.dirname(__file__), 'class_mapping.txt'), 'w') as f:
            for class_name, idx in self.class_indices.items():
                f.write(f"{idx}: {class_name}\n")
        
        return train_generator, validation_generator
    
    def build_model(self):
        """Build the model architecture"""
        # Create a model based on MobileNetV2 (transfer learning)
        base_model = MobileNetV2(
            input_shape=(self.img_size, self.img_size, 3),
            include_top=False,
            weights='imagenet'
        )
        
        # Freeze the base model layers
        base_model.trainable = False
        
        # Create the model architecture
        self.model = Sequential([
            base_model,
            tf.keras.layers.GlobalAveragePooling2D(),
            tf.keras.layers.Dense(1024, activation='relu'),
            tf.keras.layers.Dropout(0.5),
            tf.keras.layers.Dense(512, activation='relu'),
            tf.keras.layers.Dropout(0.3),
            tf.keras.layers.Dense(self.num_classes, activation='softmax')
        ])
        
        # Compile the model
        self.model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        # Model summary
        self.model.summary()
        
        return self.model
    
    def train_model(self, train_generator, validation_generator):
        """Train the model"""
        if self.model is None:
            raise ValueError("Model not built. Call build_model() first.")
        
        # Callbacks
        checkpoint = ModelCheckpoint(
            os.path.join(os.path.dirname(__file__), 'banana_nutrient_model.h5'),
            monitor='val_accuracy',
            save_best_only=True,
            mode='max',
            verbose=1
        )
        
        early_stopping = EarlyStopping(
            monitor='val_loss',
            patience=5,
            restore_best_weights=True,
            verbose=1
        )
        
        # Train the model
        self.history = self.model.fit(
            train_generator,
            epochs=self.epochs,
            validation_data=validation_generator,
            callbacks=[checkpoint, early_stopping]
        )
        
        return self.history
    
    def save_model(self):
        """Save the model in TensorFlow Lite format"""
        if self.model is None:
            raise ValueError("Model not trained. Train the model first.")
        
        # Convert to TFLite
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        tflite_model = converter.convert()
        
        # Save the TFLite model
        with open(os.path.join(os.path.dirname(__file__), 'banana_nutrient_model.tflite'), 'wb') as f:
            f.write(tflite_model)
        print("TensorFlow Lite model saved.")
    
    def plot_training_history(self):
        """Plot and save the training history"""
        if self.history is None:
            raise ValueError("Model not trained. Train the model first.")
        
        plt.figure(figsize=(12, 4))
        
        # Plot accuracy
        plt.subplot(1, 2, 1)
        plt.plot(self.history.history['accuracy'])
        plt.plot(self.history.history['val_accuracy'])
        plt.title('Model Accuracy')
        plt.ylabel('Accuracy')
        plt.xlabel('Epoch')
        plt.legend(['Train', 'Validation'], loc='upper left')
        
        # Plot loss
        plt.subplot(1, 2, 2)
        plt.plot(self.history.history['loss'])
        plt.plot(self.history.history['val_loss'])
        plt.title('Model Loss')
        plt.ylabel('Loss')
        plt.xlabel('Epoch')
        plt.legend(['Train', 'Validation'], loc='upper left')
        
        # Save the plot
        plt.savefig(os.path.join(os.path.dirname(__file__), 'training_history.png'))
        plt.close()
        print("Training history plot saved.")
    
    def run_training_pipeline(self):
        """Run the entire training pipeline"""
        print("Step 1: Creating data generators...")
        train_generator, validation_generator = self.create_data_generators()
        
        print("\nStep 2: Building model...")
        self.build_model()
        
        print("\nStep 3: Training model...")
        self.train_model(train_generator, validation_generator)
        
        print("\nStep 4: Saving model...")
        self.save_model()
        
        print("\nStep 5: Plotting training history...")
        self.plot_training_history()
        
        print("\nTraining completed successfully!")


if __name__ == "__main__":
    # Create and run the trainer
    trainer = BananaLeafDeficiencyModelTrainer()
    trainer.run_training_pipeline() 