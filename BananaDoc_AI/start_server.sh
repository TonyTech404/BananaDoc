#!/bin/bash
# Script to start the BananaDoc AI backend server

cd "$(dirname "$0")"

echo "🚀 Starting BananaDoc AI Backend Server..."
echo ""

# Check if virtual environment exists
if [ -d "venv" ]; then
    echo "✓ Activating virtual environment..."
    source venv/bin/activate
else
    echo "⚠ No virtual environment found. Using system Python."
fi

# Check if dependencies are installed
echo "✓ Checking dependencies..."
python -c "import flask" 2>/dev/null || {
    echo "⚠ Installing dependencies..."
    pip install -q -r requirements.txt
}

# Check if .env file exists
if [ -f "../.env" ]; then
    echo "✓ Found .env file in project root"
elif [ -f ".env" ]; then
    echo "✓ Found .env file in BananaDoc_AI directory"
else
    echo "⚠ WARNING: No .env file found!"
    echo "  Please create a .env file with GEMINI_API_KEY=your_key"
fi

echo ""
echo "=" * 60
echo "Starting server on http://localhost:5002"
echo "Press Ctrl+C to stop"
echo "=" * 60
echo ""

# Start the server
python api/banana_deficiency_api.py

