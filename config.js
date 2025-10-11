// Environment configuration
// Use environment variables for sensitive data
// Create a .env file based on .env.example
require('dotenv').config();

module.exports = {
  GEMINI_API_KEY: process.env.GEMINI_API_KEY || '' // Load from environment variable
}; 