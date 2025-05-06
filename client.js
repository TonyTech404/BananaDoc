const fetch = require('node-fetch');

async function queryBananaDoc(question) {
  try {
    const response = await fetch('http://localhost:3000/api/query', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query: question }),
    });

    const data = await response.json();
    
    if (response.ok) {
      console.log('BananaDoc Answer:');
      console.log(data.answer);
    } else {
      console.error('Error:', data.error);
    }
  } catch (error) {
    console.error('Failed to connect to the API:', error.message);
  }
}

// Example usage
const question = process.argv[2] || 'What is BananaDoc?';
console.log(`Question: ${question}`);
queryBananaDoc(question); 