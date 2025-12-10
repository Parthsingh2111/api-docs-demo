#!/usr/bin/env node

/**
 * Local test script for API endpoint
 * Usage: node test-api-local.js
 */

const http = require('http');

const testPayload = {
  merchantTxnId: `test_${Date.now()}`,
  paymentData: {
    totalAmount: 1000,
    txnCurrency: 'INR'
  },
  merchantCallbackURL: 'https://example.com/callback'
};

const postData = JSON.stringify(testPayload);

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/pay/jwt',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('Testing API endpoint: POST /api/pay/jwt');
console.log('Payload:', testPayload);
console.log('');

const req = http.request(options, (res) => {
  console.log(`Status: ${res.statusCode}`);
  console.log(`Headers:`, res.headers);
  console.log('');

  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      console.log('Response:', JSON.stringify(json, null, 2));
    } catch (e) {
      console.log('Response (raw):', data);
    }
  });
});

req.on('error', (e) => {
  console.error(`Problem with request: ${e.message}`);
  console.error('\nMake sure Vercel dev server is running:');
  console.error('  vercel dev');
});

req.write(postData);
req.end();

