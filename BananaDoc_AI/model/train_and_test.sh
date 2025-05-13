#!/bin/bash

echo "Starting the banana leaf deficiency detection model training and testing pipeline..."

# Set Python path to include parent directory
export PYTHONPATH=$PYTHONPATH:$(dirname $(pwd))

# Step 1: Training the model
echo -e "\n==== Training the model ===="
python train_model.py

# Check if training was successful
if [ $? -ne 0 ]; then
    echo "Error: Training failed. Exiting."
    exit 1
fi

# Step 2: Run the diagnostics
echo -e "\n==== Running diagnostic tests on all classes ===="
python test_all_classes.py

# Check if testing was successful
if [ $? -ne 0 ]; then
    echo "Error: Testing failed. Exiting."
    exit 1
fi

echo -e "\n==== All steps completed successfully ===="
echo "You can view the training history and prediction distribution plots in the model directory." 