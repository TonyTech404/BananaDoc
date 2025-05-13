import os
import json
import time
from typing import List, Dict, Any, Optional

class ConversationContext:
    """Class for managing conversation context and storing prediction results"""
    
    def __init__(self, max_history: int = 10):
        """
        Initialize the conversation context
        
        Args:
            max_history: Maximum number of conversation turns to store
        """
        self.current_prediction: Dict[str, Any] = {}
        self.conversation_history: List[Dict[str, Any]] = []
        self.max_history = max_history
        self.context_file = os.path.join(os.path.dirname(os.path.dirname(__file__)), 
                                         'data', 'conversation_context.json')
        
        # Create the data directory if it doesn't exist
        os.makedirs(os.path.dirname(self.context_file), exist_ok=True)
        
        # Load any existing context
        self._load_context()
    
    def _load_context(self) -> None:
        """Load context from file if it exists"""
        try:
            if os.path.exists(self.context_file):
                with open(self.context_file, 'r') as f:
                    data = json.load(f)
                    self.current_prediction = data.get('current_prediction', {})
                    self.conversation_history = data.get('conversation_history', [])
        except Exception as e:
            print(f"Error loading context: {e}")
            self.current_prediction = {}
            self.conversation_history = []
    
    def _save_context(self) -> None:
        """Save context to file"""
        try:
            with open(self.context_file, 'w') as f:
                json.dump({
                    'current_prediction': self.current_prediction,
                    'conversation_history': self.conversation_history
                }, f, indent=2)
        except Exception as e:
            print(f"Error saving context: {e}")
    
    def update_prediction(self, prediction_data: Dict[str, Any]) -> None:
        """
        Update the current prediction data
        
        Args:
            prediction_data: Prediction data from the model
        """
        self.current_prediction = {
            'timestamp': time.time(),
            'data': prediction_data
        }
        self._save_context()
    
    def add_conversation_turn(self, user_query: str, llm_response: str) -> None:
        """
        Add a turn to the conversation history
        
        Args:
            user_query: The user's query
            llm_response: The LLM's response
        """
        self.conversation_history.append({
            'timestamp': time.time(),
            'user_query': user_query,
            'llm_response': llm_response
        })
        
        # Limit the history to max_history
        if len(self.conversation_history) > self.max_history:
            self.conversation_history = self.conversation_history[-self.max_history:]
        
        self._save_context()
    
    def get_context_for_llm(self) -> Dict[str, Any]:
        """
        Get the full context formatted for the LLM
        
        Returns:
            Dictionary with prediction data and conversation history
        """
        return {
            'current_prediction': self.current_prediction,
            'conversation_history': self.conversation_history
        }
    
    def clear_context(self) -> None:
        """Clear all context data"""
        self.current_prediction = {}
        self.conversation_history = []
        self._save_context()


class GeminiHandler:
    """Handler for interactions with Gemini LLM API"""
    
    def __init__(self, api_key: Optional[str] = None):
        """
        Initialize the Gemini handler
        
        Args:
            api_key: API key for Google's Gemini API (can be set via env var GEMINI_API_KEY)
        """
        self.api_key = api_key or os.environ.get('GEMINI_API_KEY', '')
        self.context_manager = ConversationContext()
        
        # Check if API key is available
        if not self.api_key:
            print("Warning: No Gemini API key provided. Set GEMINI_API_KEY environment variable.")
    
    def update_with_prediction(self, prediction_data: Dict[str, Any]) -> None:
        """
        Update the context with a new prediction
        
        Args:
            prediction_data: The prediction data from the model
        """
        self.context_manager.update_prediction(prediction_data)
    
    def format_system_prompt(self) -> str:
        """
        Format the system prompt with prediction context
        
        Returns:
            Formatted system prompt string
        """
        current_prediction = self.context_manager.current_prediction.get('data', {})
        
        # If no prediction is available, provide a generic system prompt
        if not current_prediction:
            return (
                "You are BananaDoc Assistant, a professional AI that provides agricultural information about "
                "banana plant nutrient deficiencies. Respond to queries in a direct, straightforward manner "
                "with accurate and clear information."
            )
        
        # Format the prompt with the current prediction context
        deficiency = current_prediction.get('deficiency', 'unknown')
        confidence = current_prediction.get('confidence', 0) * 100
        symptoms = current_prediction.get('symptoms', '')
        treatment = current_prediction.get('treatment', '')
        prevention = current_prediction.get('prevention', '')
        
        return (
            f"You are BananaDoc Assistant, a professional AI that provides agricultural information about "
            f"banana plant nutrient deficiencies. The leaf analysis results are as follows:\n\n"
            f"DEFICIENCY: {deficiency}\n"
            f"CONFIDENCE: {confidence:.2f}%\n"
            f"SYMPTOMS: {symptoms}\n"
            f"TREATMENT: {treatment}\n"
            f"PREVENTION: {prevention}\n\n"
            f"Respond to user queries in a direct, professional tone. Provide clear and accurate information "
            f"without unnecessary elaboration or casual language. Be precise and factual when discussing "
            f"the identified deficiency and treatment options."
        )
    
    def process_query(self, user_query: str) -> str:
        """
        Process a user query with context awareness
        
        Args:
            user_query: The user's query
            
        Returns:
            The LLM's response
        """
        try:
            # Import here to avoid dependencies if not using Gemini
            # In a real implementation, this would use the Gemini API client
            # For now, we'll implement a simple mock response
            
            # This would be replaced with actual Gemini API call:
            # from google.generativeai import GenerativeModel
            # model = GenerativeModel("gemini-pro")
            # response = model.generate_content(
            #     system_prompt=self.format_system_prompt(),
            #     contents=self._format_chat_history() + [{"role": "user", "parts": [user_query]}]
            # )
            # llm_response = response.text
            
            # For now, mock the response with more professional tone:
            prediction = self.context_manager.current_prediction.get('data', {})
            deficiency = prediction.get('deficiency', 'unknown')
            
            if "symptom" in user_query.lower():
                llm_response = f"The {deficiency} deficiency symptoms include {prediction.get('symptoms', 'not available')}."
            elif "treat" in user_query.lower():
                llm_response = f"For treating {deficiency} deficiency: {prediction.get('treatment', 'not available')}."
            elif "prevent" in user_query.lower():
                llm_response = f"To prevent {deficiency} deficiency: {prediction.get('prevention', 'not available')}."
            else:
                llm_response = f"The analysis indicates a {deficiency} deficiency in your banana plant. What specific information do you need about this condition?"
            
            # Save this conversation turn
            self.context_manager.add_conversation_turn(user_query, llm_response)
            
            return llm_response
            
        except Exception as e:
            print(f"Error processing query: {e}")
            return "I'm sorry, I encountered an error processing your query. Please try again."
    
    def _format_chat_history(self) -> List[Dict[str, Any]]:
        """
        Format the conversation history for the LLM API
        
        Returns:
            List of message dictionaries formatted for the API
        """
        formatted_history = []
        
        for turn in self.context_manager.conversation_history:
            formatted_history.append({
                "role": "user",
                "parts": [turn["user_query"]]
            })
            formatted_history.append({
                "role": "model",
                "parts": [turn["llm_response"]]
            })
        
        return formatted_history 