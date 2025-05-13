#!/bin/bash

# Exit on error
set -e

echo "========================================================"
echo "  Banana Leaf Deficiency Model Training and Verification"
echo "========================================================"

# Directory setup
cd "$(dirname "$0")"
MODEL_DIR="model"
BASE_DIR="$(pwd)"
DATASET_PARENT_DIR="$(dirname "$BASE_DIR")"
DATASET_DIR="$DATASET_PARENT_DIR/Images of Nutrient Deficient Banana Plant Leaves"

echo "Working directory: $BASE_DIR"
echo "Model directory: $BASE_DIR/$MODEL_DIR"
echo "Looking for dataset in: $DATASET_DIR"

# Check if dataset exists
if [ -d "$DATASET_DIR" ]; then
    echo "Dataset found!"
    # Count how many images in the dataset
    image_count=$(find "$DATASET_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | wc -l)
    echo "Found approximately $image_count images in the dataset"
else
    echo "Dataset not found. Will use mock data for training."
    echo "If you want to use real data, please place it in:"
    echo "$DATASET_DIR"
fi

# Run model training
echo -e "\n=== Step 1: Training the model ==="
cd "$MODEL_DIR"
python train_model.py

# Verify file existence
echo -e "\n=== Step 2: Verifying model files ==="
if [ -f "banana_nutrient_model.h5" ]; then
    echo "✅ Found H5 model file: banana_nutrient_model.h5 ($(du -h banana_nutrient_model.h5 | cut -f1))"
else
    echo "❌ Error: H5 model file not found"
    exit 1
fi

if [ -f "banana_nutrient_model.keras" ]; then
    echo "✅ Found Keras model file: banana_nutrient_model.keras ($(du -h banana_nutrient_model.keras | cut -f1))"
fi

if [ -f "banana_nutrient_model.tflite" ]; then
    # Check if the file is just a placeholder due to conversion failure
    if grep -q "CONVERSION_FAILED" "banana_nutrient_model.tflite"; then
        echo "⚠️  TFLite conversion failed, but a placeholder file was created"
    else
        echo "✅ Found TFLite model file: banana_nutrient_model.tflite ($(du -h banana_nutrient_model.tflite | cut -f1))"
    fi
else
    echo "⚠️  Warning: TFLite model file not found"
fi

if [ -f "training_history.png" ]; then
    echo "✅ Found training history plot: training_history.png"
else
    echo "❌ Error: Training history plot not found"
    exit 1
fi

if [ -f "class_mapping.txt" ]; then
    echo "✅ Found class mapping file: class_mapping.txt"
    echo "Contents of class mapping:"
    cat class_mapping.txt
else
    echo "❌ Error: Class mapping file not found"
    exit 1
fi

# Check if model file is tracked by git
echo -e "\n=== Step 3: Checking git tracking status ==="
cd "$BASE_DIR"
git_status=$(git status --porcelain "$MODEL_DIR/banana_nutrient_model.h5" 2>/dev/null || echo "Not in a git repository")

if [[ $git_status == *"??"* ]]; then
    echo "⚠️  Warning: Model file is untracked by git"
    echo "You can stage it with: git add -f $MODEL_DIR/banana_nutrient_model.h5"
    
    # Ask if user wants to force add the files
    read -p "Would you like to force add the model files to git now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Force adding model files to git..."
        git add -f "$MODEL_DIR/banana_nutrient_model.h5" "$MODEL_DIR/banana_nutrient_model.tflite" \
               "$MODEL_DIR/training_history.png" "$MODEL_DIR/class_mapping.txt"
        echo "Files added. You can now commit them with:"
        echo "git commit -m \"Add trained model files\""
    fi
elif [[ $git_status == "" && -f "$MODEL_DIR/banana_nutrient_model.h5" ]]; then
    echo "⚠️  Warning: Model file exists but may be ignored by git"
    echo "You can force add it with: git add -f $MODEL_DIR/banana_nutrient_model.h5"
    
    # Ask if user wants to force add the files
    read -p "Would you like to force add the model files to git now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Force adding model files to git..."
        git add -f "$MODEL_DIR/banana_nutrient_model.h5" "$MODEL_DIR/banana_nutrient_model.tflite" \
               "$MODEL_DIR/training_history.png" "$MODEL_DIR/class_mapping.txt"
        echo "Files added. You can now commit them with:"
        echo "git commit -m \"Add trained model files\""
    fi
else
    echo "Status: $git_status"
fi

# Run test with sample image if available
echo -e "\n=== Step 4: Testing the model (if sample image available) ==="
sample_image=""

# Try to find a sample image to test with
if [ -d "$DATASET_DIR" ]; then
    # Find first jpg file in subdirectories
    sample_image=$(find "$DATASET_DIR" -name "*.jpg" -type f | head -1)
fi

# If we couldn't find a real sample, use one from our mock data
if [ -z "$sample_image" ]; then
    mock_data_dir="$BASE_DIR/temp_mock_data"
    if [ -d "$mock_data_dir" ]; then
        sample_image=$(find "$mock_data_dir" -name "*.jpg" -type f | head -1)
    fi
fi

if [ -n "$sample_image" ]; then
    echo "Found sample image: $sample_image"
    cd "$MODEL_DIR"
    python test_model.py "$sample_image" 
else
    echo "No sample image found for testing"
fi

# Run Gemini integration test
echo -e "\n=== Step 5: Testing Gemini integration ==="
cd "$MODEL_DIR"
python test_gemini_integration.py

echo -e "\n=== Training and verification completed ==="
echo "Your model is now ready to use!" 