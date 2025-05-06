const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const config = require('./config');

const app = express();
app.use(express.json());

// Initialize the Gemini API
const genAI = new GoogleGenerativeAI(config.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-pro" });

// Middleware to parse JSON requests
app.use(express.json());

// Route to handle BananaDoc queries
app.post('/api/query', async (req, res) => {
  try {
    const { query } = req.body;
    
    if (!query) {
      return res.status(400).json({ error: 'Query is required' });
    }

    // Add BananaDoc context to improve responses
    const prompt = `You are a helpful assistant for BananaDoc. 
    Please answer the following query about BananaDoc: ${query}`;
    
    const result = await model.generateContent(prompt);
    const response = result.response.text();
    
    res.json({ answer: response });
  } catch (error) {
    console.error('Error processing query:', error);
    res.status(500).json({ error: 'Failed to process query' });
  }
});

// Simple health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK' });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`BananaDoc Gemini API server running on port ${PORT}`);
}); 