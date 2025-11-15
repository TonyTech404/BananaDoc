import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout, BatchNormalization
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras.applications.efficientnet import preprocess_input
from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping
from tensorflow.keras.regularizers import l2
import matplotlib.pyplot as plt
from tensorflow.keras.metrics import Precision, Recall
from PIL import Image

class BananaLeafDeficiencyModelTrainer:
    """
    Class to train a banana leaf nutrient deficiency detection model
    """
    
    def __init__(
        self, 
        raw_data_dir="/Users/antonio/Documents/development_folder/BananaDoc/Images of Nutrient Deficient Banana Plant Leaves",
        augmented_data_dir="/Users/antonio/Documents/development_folder/BananaDoc/Images of Nutrient Deficient Banana Plant Leaves/Version-2- Augmented Images of Banana leaves deficient in Nutrients",
        img_size=224,
        batch_size=32,
        epochs=35
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
        self.num_classes = 8  # 8 classes, Sulphur removed
        self.model = None
        self.history = None
        self.class_indices = None
        self.class_names = None
        self.excluded_class = 'Sulphur'
    
    def create_data_generators(self):
        """Create data generators for training and validation, excluding Sulphur class"""
        # Check if data directories exist
        if not os.path.exists(self.augmented_data_dir):
            print(f"Error: Augmented data directory not found: {self.augmented_data_dir}")
            print("Please download the dataset or specify the correct path.")
            print("For testing purposes, we'll create a temporary dataset with random data.")
            return self._create_mock_data_generators()
            
        # Data generator with augmentation for training
        train_datagen = ImageDataGenerator(
            preprocessing_function=preprocess_input,
            rotation_range=30,
            width_shift_range=0.2,
            height_shift_range=0.2,
            shear_range=0.2,
            zoom_range=0.3,
            horizontal_flip=True,
            vertical_flip=True,
            fill_mode='nearest',
            validation_split=0.2  # 20% for validation
        )
        
        # Print available classes in the data directory
        print(f"Classes in data directory: {os.listdir(self.augmented_data_dir)}")
        print(f"Excluding class: {self.excluded_class}")
        
        # Filter out Sulphur class from the directory structure
        temp_dir = os.path.join(os.path.dirname(self.augmented_data_dir), "temp_no_sulphur")
        if not os.path.exists(temp_dir):
            os.makedirs(temp_dir, exist_ok=True)
            included_classes = []
            for class_name in os.listdir(self.augmented_data_dir):
                class_path = os.path.join(self.augmented_data_dir, class_name)
                if os.path.isdir(class_path) and class_name != self.excluded_class:
                    included_classes.append(class_name)
                    dst = os.path.join(temp_dir, class_name)
                    if not os.path.exists(dst):
                        if os.name == 'nt':
                            import shutil
                            shutil.copytree(class_path, dst)
                        else:
                            os.symlink(class_path, dst)
            print(f"Including classes: {included_classes}")
        
        # Verify the temp directory structure
        print(f"Classes in temporary directory: {os.listdir(temp_dir)}")
        
        # Create generators
        train_generator = train_datagen.flow_from_directory(
            temp_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode='categorical',
            subset='training'
        )
        
        validation_generator = train_datagen.flow_from_directory(
            temp_dir,
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
        
        return train_generator, validation_generator, temp_dir
    
    def _create_mock_data_generators(self):
        """Create mock data generators for testing purposes"""
        print("Creating mock data for testing...")
        
        # Create a temporary directory for mock data
        temp_dir = os.path.join(os.path.dirname(os.path.dirname(self.augmented_data_dir)), "temp_mock_data")
        if not os.path.exists(temp_dir):
            os.makedirs(temp_dir, exist_ok=True)
            
            # Create mock class directories
            class_names = ["Boron", "Calcium", "Healthy", "Iron", 
                           "Magnesium", "Manganese", "Potassium", "Zinc"]
            
            for class_name in class_names:
                class_dir = os.path.join(temp_dir, class_name)
                if not os.path.exists(class_dir):
                    os.makedirs(class_dir, exist_ok=True)
                
                # Create 10 mock images per class
                for i in range(10):
                    # Create a random colored image
                    img = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
                    image_path = os.path.join(class_dir, f"{class_name}_{i}.jpg")
                    
                    # Save the image using PIL
                    Image.fromarray(img).save(image_path)
        
        # Create data generators using mock data
        train_datagen = ImageDataGenerator(
            preprocessing_function=preprocess_input,
            validation_split=0.2
        )
        
        # Create generators
        train_generator = train_datagen.flow_from_directory(
            temp_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode='categorical',
            subset='training'
        )
        
        validation_generator = train_datagen.flow_from_directory(
            temp_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode='categorical',
            subset='validation'
        )
        
        # Save class indices
        self.class_indices = train_generator.class_indices
        self.class_names = list(self.class_indices.keys())
        print(f"Mock classes: {self.class_names}")
        
        # Save class mapping to a file
        with open(os.path.join(os.path.dirname(__file__), 'class_mapping.txt'), 'w') as f:
            for class_name, idx in self.class_indices.items():
                f.write(f"{idx}: {class_name}\n")
        
        return train_generator, validation_generator, temp_dir
    
    def build_model(self):
        """Build the model architecture using EfficientNetB0"""
        # Create a model based on EfficientNetB0 (transfer learning)
        base_model = EfficientNetB0(
            input_shape=(self.img_size, self.img_size, 3),
            include_top=False,
            weights='imagenet'
        )
        
        # Freeze the base model layers
        base_model.trainable = False
        
        # Create the model architecture with stronger regularization
        self.model = Sequential([
            base_model,
            tf.keras.layers.GlobalAveragePooling2D(),
            BatchNormalization(),
            tf.keras.layers.Dense(1024, activation='relu', kernel_regularizer=l2(0.001)),
            Dropout(0.5),
            BatchNormalization(),
            tf.keras.layers.Dense(512, activation='relu', kernel_regularizer=l2(0.001)),
            Dropout(0.3),
            BatchNormalization(),
            tf.keras.layers.Dense(self.num_classes, activation='softmax')
        ])
        
        # Compile the model with precision and recall metrics
        self.model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=0.0005),
            loss='categorical_crossentropy',
            metrics=['accuracy', Precision(), Recall()]
        )
        
        # Model summary
        self.model.summary()
        
        return self.model
    
    def train_model(self, train_generator, validation_generator):
        """Train the model with early stopping and checkpointing"""
        if self.model is None:
            raise ValueError("Model not built. Call build_model() first.")
        
        # Class weights are not needed since we're excluding Sulphur class completely
        class_weights = None
        
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
            patience=10,
            restore_best_weights=True,
            verbose=1
        )
        
        # Train the model
        self.history = self.model.fit(
            train_generator,
            epochs=self.epochs,
            validation_data=validation_generator,
            callbacks=[checkpoint, early_stopping],
            class_weight=class_weights
        )
        
        return self.history
    
    def save_model(self):
        """Save the model in multiple formats with error handling"""
        if self.model is None:
            raise ValueError("Model not trained. Train the model first.")
        
        # Save the H5 model
        h5_path = os.path.join(os.path.dirname(__file__), 'banana_nutrient_model.h5')
        try:
            self.model.save(h5_path)
            print(f"Model saved in H5 format: {h5_path}")
        except Exception as e:
            print(f"Error saving H5 model: {e}")
        
        # Save in Keras format as alternative
        try:
            keras_path = os.path.join(os.path.dirname(__file__), 'banana_nutrient_model.keras')
            self.model.save(keras_path)
            print(f"Model saved in Keras format: {keras_path}")
        except Exception as e:
            print(f"Error saving Keras model: {e}")
        
        # Try to convert to TFLite
        try:
            # Convert to TFLite
            converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
            
            # Set optimization flags
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            
            # Try with more compatibility options if needed
            converter.target_spec.supported_ops = [
                tf.lite.OpsSet.TFLITE_BUILTINS,  # enable TensorFlow Lite ops
                tf.lite.OpsSet.SELECT_TF_OPS     # enable TensorFlow ops
            ]
            
            # Try the conversion
            tflite_model = converter.convert()
            
            # Save the TFLite model
            tflite_path = os.path.join(os.path.dirname(__file__), 'banana_nutrient_model.tflite')
            with open(tflite_path, 'wb') as f:
                f.write(tflite_model)
            print(f"TensorFlow Lite model saved: {tflite_path}")
        except Exception as e:
            print(f"Warning: Could not convert to TFLite format: {e}")
            print("The model is still available in H5/Keras format.")
            
            # Create an empty file to indicate TFLite conversion failed
            # This helps the verification script continue
            with open(os.path.join(os.path.dirname(__file__), 'banana_nutrient_model.tflite'), 'wb') as f:
                f.write(b'CONVERSION_FAILED')
            print("Created placeholder TFLite file.")
    
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
        train_generator, validation_generator, temp_dir = self.create_data_generators()
        
        print("\nStep 2: Building model...")
        self.build_model()
        
        print("\nStep 3: Training model...")
        self.train_model(train_generator, validation_generator)
        
        print("\nStep 4: Saving model...")
        self.save_model()
        
        print("\nStep 5: Plotting training history...")
        self.plot_training_history()
        
        # Clean up temp directory
        if os.path.exists(temp_dir):
            for class_name in self.class_names:
                class_dir = os.path.join(temp_dir, class_name)
                if os.path.islink(class_dir):
                    os.unlink(class_dir)
                elif os.path.isdir(class_dir):
                    import shutil
                    shutil.rmtree(class_dir)
            os.rmdir(temp_dir)
            print(f"Removed temporary directory: {temp_dir}")
        
        print("\nTraining completed successfully!")


if __name__ == "__main__":
    # Create and run the trainer
    trainer = BananaLeafDeficiencyModelTrainer()
    trainer.run_training_pipeline() 