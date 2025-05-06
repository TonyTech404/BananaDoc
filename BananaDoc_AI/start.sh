#!/bin/bash

# Start script for BananaDoc AI

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Please install Python 3 and try again."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Check if model files exist
MODEL_H5="model/banana_nutrient_model.h5"
MODEL_TFLITE="model/banana_nutrient_model.tflite"
CLASS_MAPPING="model/class_mapping.txt"

if [ ! -f "$MODEL_H5" ] && [ ! -f "$MODEL_TFLITE" ]; then
    echo "Model files not found."
    read -p "Do you want to train the model now? (y/n): " TRAIN_MODEL
    if [[ $TRAIN_MODEL == "y" || $TRAIN_MODEL == "Y" ]]; then
        echo "Training model..."
        python model/train_model.py
    fi
fi

# Start the API server
echo "Starting API server..."
python run_api.py 