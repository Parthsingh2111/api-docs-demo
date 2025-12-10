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
    // Read keys from environment variables or file paths
    const privateKeyPath = process.env.PAYGLOCAL_PRIVATE_KEY || path.resolve(__dirname, '../../backend/keys/payglocal_private_key');
    const publicKeyPath = process.env.PAYGLOCAL_PUBLIC_KEY || path.resolve(__dirname, '../../backend/keys/payglocal_public_key');
    
    const payglocalPublicKey = process.env.PAYGLOCAL_PUBLIC_KEY_CONTENT 
      ? normalizePemKey(process.env.PAYGLOCAL_PUBLIC_KEY_CONTENT)
      : normalizePemKey(fs.readFileSync(publicKeyPath, 'utf8'));
    
    const merchantPrivateKey = process.env.PAYGLOCAL_PRIVATE_KEY_CONTENT
      ? normalizePemKey(process.env.PAYGLOCAL_PRIVATE_KEY_CONTENT)
      : normalizePemKey(fs.readFileSync(privateKeyPath, 'utf8'));

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

    client = new PayGlocalClient(config);
    pdclient = new PayPdGlocalClient(config);
    clientsInitialized = true;
  } catch (error) {
    console.error('Failed to initialize PayGlocal clients:', error);
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
    return res.status(500).json({
      status: 'ERROR',
      message: 'Payment failed',
      error: error.message || 'Unknown error occurred',
      code: 'PAYMENT_ERROR'
    });
  }
};

