#!/usr/bin/env python3
"""
Test script to verify Gemini API key is working correctly
"""
import os
import sys

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Try to load .env file
try:
    from dotenv import load_dotenv
    # Try root directory first
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    root_env_path = os.path.join(root_dir, '.env')
    
    # Try BananaDoc_AI directory
    banana_doc_ai_dir = os.path.dirname(os.path.abspath(__file__))
    banana_doc_ai_env_path = os.path.join(banana_doc_ai_dir, '.env')
    
    if os.path.exists(root_env_path):
        load_dotenv(root_env_path)
        print(f"✓ Loaded .env from: {root_env_path}")
    elif os.path.exists(banana_doc_ai_env_path):
        load_dotenv(banana_doc_ai_env_path)
        print(f"✓ Loaded .env from: {banana_doc_ai_env_path}")
    else:
        load_dotenv()
        print("✓ Attempted to load .env from current directory")
except ImportError:
    print("Warning: python-dotenv not installed")
except Exception as e:
    print(f"Warning: Could not load .env file: {e}")

# Get API key
api_key = os.environ.get('GEMINI_API_KEY', '')
if not api_key:
    print("\n❌ ERROR: GEMINI_API_KEY not found in environment!")
    print("Please set it in your .env file:")
    print("GEMINI_API_KEY=your_api_key_here")
    sys.exit(1)

print(f"\n✓ GEMINI_API_KEY found: {api_key[:10]}...{api_key[-4:] if len(api_key) > 14 else '***'}")
print(f"  Key length: {len(api_key)} characters")

# Test Gemini API
try:
    import google.generativeai as genai
    print("\n✓ google-generativeai package is installed")
    
    print("\n🔧 Configuring Gemini API...")
    genai.configure(api_key=api_key)
    
    print("✓ API configured successfully")
    
    print("\n🤖 Checking available models...")
    try:
        models = list(genai.list_models())
        print(f"✓ Found {len(models)} available models")
        print("\nAvailable models:")
        for m in models[:10]:  # Show first 10
            if 'generateContent' in m.supported_generation_methods:
                print(f"  - {m.name}")
    except Exception as e:
        print(f"Could not list models: {e}")
    
    print("\n🤖 Initializing model...")
    # Try different model names (with and without models/ prefix)
    model_names = [
        'models/gemini-2.5-flash',  # Latest flash model
        'models/gemini-2.0-flash',  # Alternative flash
        'models/gemini-2.5-pro',    # Pro model
        'gemini-pro',               # Legacy name
        'gemini-1.5-flash',         # Older version
        'gemini-1.5-pro',           # Older pro version
    ]
    model = None
    working_model_name = None
    for model_name in model_names:
        try:
            print(f"  Trying {model_name}...")
            model = genai.GenerativeModel(model_name)
            # Test if it actually works by generating content
            test_response = model.generate_content("test", generation_config={'max_output_tokens': 10})
            print(f"✓ Model {model_name} initialized and working!")
            working_model_name = model_name
            break
        except Exception as e:
            print(f"  ✗ {model_name} failed: {str(e)[:100]}")
            continue
    
    if model is None:
        raise Exception("Could not initialize any model")
    
    print(f"\n✅ Using model: {working_model_name}")
    
    print("\n📤 Sending test query to Gemini API...")
    test_query = "Hello! Can you respond with just 'API is working' if you can read this?"
    
    response = model.generate_content(
        test_query,
        generation_config={
            'temperature': 0.7,
            'top_p': 0.9,
            'top_k': 40,
            'max_output_tokens': 1024,
        }
    )
    
    print("\n✅ SUCCESS! Gemini API is working!")
    print(f"\n📥 Response from Gemini:")
    print("-" * 60)
    print(response.text)
    print("-" * 60)
    
    print("\n✅ Your Gemini API key is valid and working correctly!")
    
except ImportError:
    print("\n❌ ERROR: google-generativeai package is not installed!")
    print("Install it with: pip install google-generativeai")
    sys.exit(1)
except Exception as e:
    print(f"\n❌ ERROR: Failed to test Gemini API")
    print(f"Error details: {e}")
    print("\nPossible issues:")
    print("1. Invalid API key")
    print("2. API key doesn't have proper permissions")
    print("3. Network connectivity issues")
    print("4. API quota exceeded")
    sys.exit(1)

