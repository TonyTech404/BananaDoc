#!/usr/bin/env python3
"""
Run the BananaDoc AI API server
"""

import os
import sys
import subprocess
import argparse

def check_model_exists():
    """Check if the model files exist"""
    model_h5_path = os.path.join('model', 'banana_nutrient_model.h5')
    model_tflite_path = os.path.join('model', 'banana_nutrient_model.tflite')
    class_mapping_path = os.path.join('model', 'class_mapping.txt')
    
    if not (os.path.exists(model_h5_path) or os.path.exists(model_tflite_path)):
        print("Warning: No model file found. You may need to train the model first.")
        return False
    
    if not os.path.exists(class_mapping_path):
        print("Warning: Class mapping file not found. You may need to train the model first.")
        return False
    
    return True

def run_api_server(host='127.0.0.1', port=5002):
    """Run the API server"""
    api_script_path = os.path.join('api', 'banana_deficiency_api.py')
    
    if not os.path.exists(api_script_path):
        print(f"Error: API script not found at {api_script_path}")
        return False
    
    try:
        # Load environment variables from .env if it exists
        try:
            from dotenv import load_dotenv
            load_dotenv()
        except ImportError:
            print("Warning: python-dotenv not installed. Install it to use .env files.")
        
        # Set environment variables
        env = os.environ.copy()
        env['FLASK_APP'] = api_script_path
        env['FLASK_ENV'] = env.get('FLASK_ENV', 'development')
        env['PORT'] = str(port)
        env['HOST'] = host
        
        # Security: Warn if using 0.0.0.0
        if host == '0.0.0.0':
            print("WARNING: Server is binding to 0.0.0.0 (all interfaces).")
            print("Ensure proper firewall rules are in place.")
        
        # Run the API server
        cmd = [sys.executable, api_script_path]
        print(f"Starting API server at http://{host}:{port}")
        print(f"Environment: {env.get('FLASK_ENV', 'development')}")
        subprocess.run(cmd, env=env)
        return True
    except Exception as e:
        print(f"Error starting API server: {e}")
        return False

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Run the BananaDoc AI API server')
    parser.add_argument('--host', type=str, default='127.0.0.1', help='Host to bind to (default: 127.0.0.1)')
    parser.add_argument('--port', type=int, default=5002, help='Port to bind to (default: 5002)')
    parser.add_argument('--skip-checks', action='store_true', help='Skip model file checks')
    
    args = parser.parse_args()
    
    if not args.skip_checks:
        # Check if the model exists
        if not check_model_exists():
            response = input("Model files not found. Do you want to train the model first? (y/n): ")
            if response.lower() == 'y':
                print("Running model training script...")
                train_script_path = os.path.join('model', 'train_model.py')
                subprocess.run([sys.executable, train_script_path])
            else:
                print("Continuing without training...")
    
    # Run the API server
    run_api_server(args.host, args.port)

if __name__ == '__main__':
    main() 