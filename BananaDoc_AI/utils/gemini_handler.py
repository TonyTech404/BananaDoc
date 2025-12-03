import os
import json
import time
from typing import List, Dict, Any, Optional

# Try to import google.generativeai, but handle gracefully if not installed
try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False
    print("Warning: google-generativeai not installed. Install it with: pip install google-generativeai")

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
        self.model = None
        
        # Check if API key is available
        if not self.api_key:
            print("Warning: No Gemini API key provided. Set GEMINI_API_KEY environment variable.")
        elif GEMINI_AVAILABLE:
            try:
                # Configure the API key
                genai.configure(api_key=self.api_key)
                # Initialize the model - prioritize free-tier models
                model_names = [
                    'models/gemini-2.0-flash-lite',  # Best for free tier (30 RPM, 1M TPM)
                    'models/gemini-2.0-flash',       # Alternative flash
                    'models/gemini-2.5-flash',       # Latest flash model
                    'models/gemini-2.5-pro',         # Pro model
                    'gemini-pro',                    # Legacy name
                    'gemini-1.5-flash',              # Older version
                ]
                self.model = None
                for model_name in model_names:
                    try:
                        self.model = genai.GenerativeModel(model_name)
                        print(f"Gemini API initialized successfully with model: {model_name}")
                        break
                    except Exception as e:
                        continue
                
                if self.model is None:
                    raise Exception("Could not initialize any Gemini model")
            except Exception as e:
                print(f"Warning: Failed to initialize Gemini API: {e}")
                self.model = None
        else:
            print("Warning: google-generativeai package not installed. Chat functionality will use fallback responses.")
    
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
        
        # Base system prompt with Philippines-specific context
        base_prompt = (
            "You are BananaDoc Assistant, a professional AI agricultural expert specializing in banana plant "
            "nutrient deficiencies. Your role is to help farmers in the Philippines understand and address nutrient problems "
            "in their banana plants.\n\n"
            "CRITICAL CONTEXT - PHILIPPINES-SPECIFIC:\n"
            "- You are assisting Filipino farmers, primarily in the Philippines\n"
            "- Provide recommendations that are practical and available in the Philippines\n"
            "- Mention specific Filipino brands, products, and suppliers when relevant (e.g., Atlas, PhilAgri, local agricultural stores)\n"
            "- Use Philippine Peso (₱) for cost estimates\n"
            "- Reference Philippine agricultural practices, climate conditions, and soil types common in the Philippines\n"
            "- Consider common banana varieties grown in the Philippines (Lakatan, Latundan, Saba, etc.)\n"
            "- Account for tropical climate, monsoon seasons, and typical Philippine growing conditions\n"
            "- Suggest locally available fertilizers, amendments, and agricultural inputs\n"
            "- Reference Philippine Department of Agriculture (DA) guidelines when appropriate\n"
            "- Consider small-scale farming practices common in the Philippines\n\n"
            "IMPORTANT GUIDELINES:\n"
            "- Provide accurate, science-based information about banana plant nutrition\n"
            "- Use clear, direct language that Filipino farmers can understand\n"
            "- Base your responses on the provided diagnosis and context\n"
            "- If specific information is provided (deficiency type, symptoms, treatment), use that information "
            "to guide your responses\n"
            "- Be helpful, professional, and empathetic\n"
            "- Always consider the Philippine context in your recommendations\n"
            "- If asked about something not related to banana plants or nutrition, politely redirect to your expertise\n\n"
        )
        
        # If no prediction is available, provide a generic system prompt
        if not current_prediction:
            return (
                base_prompt +
                "You can answer general questions about banana plant nutrition, common deficiencies, "
                "and best practices. If the user asks about a specific plant issue, encourage them to "
                "upload a leaf image for analysis."
            )
        
        # Format the prompt with the current prediction context
        deficiency = current_prediction.get('deficiency', 'unknown')
        confidence = current_prediction.get('confidence', 0) * 100
        symptoms = current_prediction.get('symptoms', '')
        treatment = current_prediction.get('treatment', '')
        prevention = current_prediction.get('prevention', '')
        
        # Get probabilities if available
        probabilities = current_prediction.get('probabilities', {})
        prob_text = ""
        if probabilities:
            prob_items = [f"{k}: {v*100:.1f}%" for k, v in sorted(probabilities.items(), key=lambda x: x[1], reverse=True)[:3]]
            prob_text = f"\n\nOTHER POSSIBILITIES CONSIDERED:\n" + "\n".join(prob_items)
        
        return (
            base_prompt +
            f"CURRENT DIAGNOSIS CONTEXT:\n\n"
            f"DEFICIENCY DETECTED: {deficiency}\n"
            f"CONFIDENCE LEVEL: {confidence:.2f}%\n"
            f"SYMPTOMS: {symptoms}\n"
            f"RECOMMENDED TREATMENT: {treatment}\n"
            f"PREVENTION MEASURES: {prevention}"
            f"{prob_text}\n\n"
            f"Use this diagnosis information to provide contextually relevant answers. When the user asks "
            f"questions, reference this specific diagnosis and provide detailed, actionable guidance based "
            f"on the identified {deficiency} deficiency. If they ask follow-up questions, maintain context "
            f"about this specific case while providing comprehensive information."
        )
    
    def process_query(self, user_query: str) -> str:
        """
        Process a user query with context awareness using Gemini API
        
        Args:
            user_query: The user's query
            
        Returns:
            The LLM's response
        """
        try:
            # Check if Gemini is available and initialized
            if not GEMINI_AVAILABLE or not self.model:
                # Fallback to context-aware responses if Gemini is not available
                return self._fallback_response(user_query)
            
            # Build the full context prompt
            system_prompt = self.format_system_prompt()
            
            # Format conversation history as text for context
            conversation_context = self._format_conversation_context()
            
            # Build the complete prompt with system context and conversation history
            if conversation_context:
                full_prompt = f"{system_prompt}\n\n{conversation_context}\n\nUser's current question: {user_query}\n\nPlease provide a helpful, contextually-aware response based on the diagnosis information and conversation history above."
            else:
                full_prompt = f"{system_prompt}\n\nUser's question: {user_query}\n\nPlease provide a helpful response based on the diagnosis information above."
            
            # Generate response using the model
            # Configure generation parameters for consistent, context-aware responses
            # Increased max_output_tokens to allow for longer, more detailed responses
            # Gemini 2.5-flash supports up to 8192 output tokens
            # Using 8192 to allow for very detailed responses (cost estimates, treatments, etc.)
            generation_config = {
                'temperature': 0.7,
                'top_p': 0.9,
                'top_k': 40,
                'max_output_tokens': 8192,  # Increased from 1024 to 8192 (max for flash models) to prevent truncation
            }
            
            response = self.model.generate_content(
                full_prompt,
                generation_config=generation_config
            )
            
            # Extract the text response - handle potential truncation
            llm_response = response.text.strip()
            
            # Check if response was truncated due to token limit
            if hasattr(response, 'candidates') and response.candidates:
                finish_reason = response.candidates[0].finish_reason
                if finish_reason == 'MAX_TOKENS':
                    print(f"Warning: Response may have been truncated due to max_output_tokens limit")
                    # Could append a note, but for now just log it
                elif finish_reason:
                    print(f"Response finish reason: {finish_reason}")
            
            # Log response length for debugging
            print(f"Generated response length: {len(llm_response)} characters")
            
            # Save this conversation turn
            self.context_manager.add_conversation_turn(user_query, llm_response)
            
            return llm_response
            
        except Exception as e:
            print(f"Error processing query with Gemini API: {e}")
            import traceback
            traceback.print_exc()
            # Fallback to context-aware response on error
            return self._fallback_response(user_query)
    
    def _fallback_response(self, user_query: str) -> str:
        """
        Fallback response when Gemini API is not available
        Uses context-aware responses based on prediction data
        
        Args:
            user_query: The user's query
            
        Returns:
            A context-aware fallback response
        """
        prediction = self.context_manager.current_prediction.get('data', {})
        deficiency = prediction.get('deficiency', 'unknown')
        
        query_lower = user_query.lower()
        
        # Provide context-aware responses based on keywords and available data
        if "symptom" in query_lower or "sign" in query_lower or "look like" in query_lower:
            symptoms = prediction.get('symptoms', 'not available')
            return (
                f"Based on the analysis, the {deficiency} deficiency symptoms include: {symptoms}. "
                f"These symptoms typically appear on the leaves and can affect plant growth and fruit quality."
            )
        elif "treat" in query_lower or "fix" in query_lower or "remedy" in query_lower or "what should i do" in query_lower:
            treatment = prediction.get('treatment', 'not available')
            return (
                f"For treating {deficiency} deficiency in your banana plants: {treatment}. "
                f"It's important to follow the recommended application rates and timing for best results."
            )
        elif "prevent" in query_lower or "avoid" in query_lower or "future" in query_lower:
            prevention = prediction.get('prevention', 'not available')
            return (
                f"To prevent {deficiency} deficiency: {prevention}. "
                f"Regular soil testing and balanced fertilization are key to maintaining healthy banana plants."
            )
        elif deficiency != 'unknown':
            confidence = prediction.get('confidence', 0) * 100
            return (
                f"The analysis indicates a {deficiency} deficiency in your banana plant "
                f"(confidence: {confidence:.1f}%). "
                f"I can help you understand the symptoms, treatment options, and prevention measures. "
                f"What specific information would you like to know?"
            )
        else:
            return (
                "I'm here to help with banana plant nutrition questions. "
                "Please upload a leaf image for analysis, or ask me about common nutrient deficiencies, "
                "treatment methods, or prevention strategies."
            )
    
    def _format_conversation_context(self) -> str:
        """
        Format the conversation history as text context for the prompt
        
        Returns:
            Formatted conversation history as a string
        """
        if not self.context_manager.conversation_history:
            return ""
        
        # Get recent conversation history (last 10 turns)
        recent_history = self.context_manager.conversation_history[-10:]
        
        context_lines = ["CONVERSATION HISTORY:"]
        for turn in recent_history:
            context_lines.append(f"User: {turn['user_query']}")
            context_lines.append(f"Assistant: {turn['llm_response']}")
            context_lines.append("")  # Empty line between turns
        
        return "\n".join(context_lines) 