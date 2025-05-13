#!/usr/bin/env python3
import os
import sys
import json

# Add parent directory to path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.model_loader import ModelLoader
from utils.deficiency_info import DeficiencyInfoProvider
from utils.gemini_handler import GeminiHandler

def test_gemini_integration():
    """Test the integration of Gemini with prediction data"""
    print("=== Testing Gemini Integration ===")
    
    # Initialize components
    model_loader = ModelLoader(model_dir=os.path.dirname(__file__))
    deficiency_info_provider = DeficiencyInfoProvider()
    gemini_handler = GeminiHandler()
    
    # Create sample prediction data for each deficiency
    for deficiency in deficiency_info_provider.get_all_deficiencies():
        # Get deficiency info
        info = deficiency_info_provider.get_deficiency_info(deficiency)
        
        # Create prediction data
        prediction_data = {
            'deficiency': deficiency,
            'confidence': 0.92,  # Sample confidence
            'symptoms': info['symptoms'],
            'treatment': info['treatment'],
            'prevention': info['prevention'],
            'probabilities': {
                deficiency: 0.92,
                'Other': 0.08
            }
        }
        
        # Update Gemini handler with this prediction
        gemini_handler.update_with_prediction(prediction_data)
        
        # Test a few sample queries
        queries = [
            "What's wrong with my banana plant?",
            "How do I treat this deficiency?",
            "What are the symptoms?",
            "How can I prevent this issue in the future?"
        ]
        
        print(f"\n=== Testing Deficiency: {deficiency} ===")
        
        for query in queries:
            response = gemini_handler.process_query(query)
            print(f"\nQuery: {query}")
            print(f"Response: {response}\n")
        
        # Display the context for this deficiency
        context = gemini_handler.context_manager.get_context_for_llm()
        print(f"Context length: {len(context['conversation_history'])} items")
        
        # Clear context before testing the next deficiency
        gemini_handler.context_manager.clear_context()
        
    print("\n=== Gemini Integration Test Completed ===")

if __name__ == "__main__":
    test_gemini_integration() 