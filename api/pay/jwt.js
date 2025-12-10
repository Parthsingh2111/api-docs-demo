// Load environment variables from .env files (for local development)
if (process.env.NODE_ENV !== 'production' || !process.env.VERCEL) {
  try {
    require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env.local') });
  } catch (e) {
    // Fallback to .env
    try {
      require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });
    } catch (e2) {
      // dotenv not available or no .env file, continue without it
    }
  }
}

const PayGlocalClient = require('../../backend/pg-client-sdk/lib/index.js');
const PayPdGlocalClient = require('../../backend/pgpd-client-sdk/lib/index.js');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

function normalizePemKey(key) {
  return key
    .trim()
    .replace(/\r\n|\r/g, '\n') // Normalize line endings to \n
    .replace(/\n\s*\n/g, '\n') // Remove empty lines
    .replace(/[^\x00-\x7F]/g, ''); // Remove non-ASCII characters
}

// Initialize clients (will be cached across invocations)
let client, pdclient;
let clientsInitialized = false;

function initializeClients() {
  if (clientsInitialized) return;

  try {
    console.log('Initializing PayGlocal clients...');
    console.log('__dirname:', __dirname);
    console.log('Environment variables check:', {
      hasApiKey: !!process.env.PAYGLOCAL_API_KEY,
      hasMerchantId: !!process.env.PAYGLOCAL_MERCHANT_ID,
      hasPublicKeyId: !!process.env.PAYGLOCAL_PUBLIC_KEY_ID,
      hasPrivateKeyId: !!process.env.PAYGLOCAL_PRIVATE_KEY_ID,
      hasPublicKeyContent: !!process.env.PAYGLOCAL_PUBLIC_KEY_CONTENT,
      hasPrivateKeyContent: !!process.env.PAYGLOCAL_PRIVATE_KEY_CONTENT,
      hasPublicKeyPath: !!process.env.PAYGLOCAL_PUBLIC_KEY,
      hasPrivateKeyPath: !!process.env.PAYGLOCAL_PRIVATE_KEY
    });

    // Read keys from environment variables or file paths
    const privateKeyPath = process.env.PAYGLOCAL_PRIVATE_KEY || path.resolve(__dirname, '../../backend/keys/payglocal_private_key');
    const publicKeyPath = process.env.PAYGLOCAL_PUBLIC_KEY || path.resolve(__dirname, '../../backend/keys/payglocal_public_key');
    
    console.log('Key paths:', { privateKeyPath, publicKeyPath });
    
    // Check if files exist if not using content from env
    if (!process.env.PAYGLOCAL_PUBLIC_KEY_CONTENT && !fs.existsSync(publicKeyPath)) {
      throw new Error(`Public key file not found at: ${publicKeyPath}`);
    }
    if (!process.env.PAYGLOCAL_PRIVATE_KEY_CONTENT && !fs.existsSync(privateKeyPath)) {
      throw new Error(`Private key file not found at: ${privateKeyPath}`);
    }
    
    const payglocalPublicKey = process.env.PAYGLOCAL_PUBLIC_KEY_CONTENT 
      ? normalizePemKey(process.env.PAYGLOCAL_PUBLIC_KEY_CONTENT)
      : normalizePemKey(fs.readFileSync(publicKeyPath, 'utf8'));
    
    const merchantPrivateKey = process.env.PAYGLOCAL_PRIVATE_KEY_CONTENT
      ? normalizePemKey(process.env.PAYGLOCAL_PRIVATE_KEY_CONTENT)
      : normalizePemKey(fs.readFileSync(privateKeyPath, 'utf8'));

    if (!payglocalPublicKey || !merchantPrivateKey) {
      throw new Error('Failed to read or parse keys');
    }

    const config = {
      apiKey: process.env.PAYGLOCAL_API_KEY,
      merchantId: process.env.PAYGLOCAL_MERCHANT_ID,
      publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID,
      privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
      payglocalPublicKey,
      merchantPrivateKey,
      payglocalEnv: process.env.PAYGLOCAL_Env_VAR || 'uat',
      logLevel: process.env.PAYGLOCAL_LOG_LEVEL || 'debug'
    };

    if (!config.apiKey || !config.merchantId || !config.publicKeyId || !config.privateKeyId) {
      throw new Error('Missing required configuration. Please set PAYGLOCAL_API_KEY, PAYGLOCAL_MERCHANT_ID, PAYGLOCAL_PUBLIC_KEY_ID, and PAYGLOCAL_PRIVATE_KEY_ID environment variables.');
    }

    console.log('Creating PayGlocal clients...');
    client = new PayGlocalClient(config);
    pdclient = new PayPdGlocalClient(config);
    clientsInitialized = true;
    console.log('PayGlocal clients initialized successfully');
  } catch (error) {
    console.error('Failed to initialize PayGlocal clients:', error);
    console.error('Error stack:', error.stack);
    throw error;
  }
}

module.exports = async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle OPTIONS request
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Only allow POST
  if (req.method !== 'POST') {
    return res.status(405).json({
      status: 'error',
      message: 'Method not allowed',
      code: 'METHOD_NOT_ALLOWED'
    });
  }

  try {
    // Parse request body if it's a string
    let body = req.body;
    if (typeof body === 'string') {
      try {
        body = JSON.parse(body);
      } catch (e) {
        return res.status(400).json({
          status: 'error',
          message: 'Invalid JSON in request body',
          code: 'INVALID_JSON'
        });
      }
    }

    // Initialize clients on first request
    initializeClients();

    const { merchantTxnId, paymentData, merchantCallbackURL } = body;

    if (!merchantTxnId || !paymentData || !merchantCallbackURL) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing required fields',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['merchantTxnId', 'paymentData', 'merchantCallbackURL'] }
      });
    }

    const payload = {
      merchantTxnId,
      paymentData,
      merchantCallbackURL
    };

    console.log('Initiating JWT payment with payload:', JSON.stringify(payload, null, 2));

    let payment;
    if (payload.paymentData.cardData) {
      payment = await pdclient.initiateJwtPayment(payload);
    } else {
      payment = await client.initiateJwtPayment(payload);
    }

    console.log('Raw SDK Response:', JSON.stringify(payment, null, 2));

    // Check if the SDK response indicates an error
    if (payment?.status === 'REQUEST_ERROR' || payment?.status === 'ERROR' || payment?.error) {
      throw new Error(`PayGlocal SDK Error: ${payment.message || payment.error || 'Unknown error'}`);
    }

    // Extract payment link and gid from the actual PayGlocal response structure
    const paymentLink = payment?.data?.redirectUrl ||
      payment?.data?.redirect_url ||
      payment?.data?.payment_link ||
      payment?.redirectUrl ||
      payment?.redirect_url ||
      payment?.payment_link ||
      payment?.data?.paymentLink ||
      payment?.paymentLink;

    const gid = payment?.gid ||
      payment?.data?.gid ||
      payment?.transactionId ||
      payment?.data?.transactionId;

    // Format response to match frontend expectations
    const formattedResponse = {
      status: 'SUCCESS',
      message: 'Payment initiated successfully',
      payment_link: paymentLink,
      gid: gid,
      raw_response: payment
    };

    return res.status(200).json(formattedResponse);
  } catch (error) {
    console.error('Payment error:', error);
    console.error('Error stack:', error.stack);
    
    // Return detailed error information for debugging
    return res.status(500).json({
      status: 'ERROR',
      message: 'Payment failed',
      error: error.message || 'Unknown error occurred',
      code: 'PAYMENT_ERROR',
      details: process.env.NODE_ENV === 'development' ? {
        stack: error.stack,
        name: error.name
      } : undefined
    });
  }
};

