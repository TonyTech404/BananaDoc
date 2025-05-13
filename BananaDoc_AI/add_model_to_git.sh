#!/bin/bash

# Exit on error
set -e

echo "=== Adding Trained Model Files to Git ==="

MODEL_DIR="model"
FILES_TO_ADD=(
    "$MODEL_DIR/banana_nutrient_model.h5"
    "$MODEL_DIR/banana_nutrient_model.keras"
    "$MODEL_DIR/class_mapping.txt"
    "$MODEL_DIR/training_history.png"
)

# Check if files exist
for file in "${FILES_TO_ADD[@]}"; do
    if [ -f "$file" ]; then
        echo "Found $file ($(du -h "$file" | cut -f1))"
    else
        echo "Warning: $file not found"
    fi
done

# Ask for confirmation
read -p "Add these files to git? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Adding files to git..."
    for file in "${FILES_TO_ADD[@]}"; do
        if [ -f "$file" ]; then
            git add -f "$file"
            echo "Added $file"
        fi
    done
    
    echo "Files added. You can now commit them with:"
    echo "git commit -m \"Add trained model files\""
else
    echo "Operation cancelled"
fi 