import React from 'react';

function App() {
  return (
    <div style={{ padding: '40px', fontFamily: 'Arial' }}>
      <h1>Welcome to CoBank Cloud Platform</h1>
      <p>Secure. Scalable. Observable.</p>
      <button onClick={() => fetch('/api/health').then(r => r.json()).then(console.log)}>
        Test Backend
      </button>
    </div>
  );
}

export default App;
