require('dotenv').config();
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
// const PayGlocalClient = require('payglocal-client');
const PayGlocalClient = require('payglocal-client').default;

// Normalize PEM to avoid whitespace/encoding issues
function normalizePemKey(key) {
  return key
    .trim()
    .replace(/\r\n|\r/g, '\n')
    .replace(/\n\s*\n/g, '\n')
    .replace(/[^\x00-\x7F]/g, '');
}

// Load keys from file paths or from PEM text in env
function loadKeyFromEnvOrFile(envValue, isPrivate = false) {
  const looksLikePem = envValue && envValue.includes('-----BEGIN');
  const value = looksLikePem
    ? envValue
    : fs.readFileSync(path.resolve(__dirname, envValue), 'utf8');
  const normalized = normalizePemKey(value);

  // Basic validation
  try {
    if (isPrivate) crypto.createPrivateKey(normalized);
    else crypto.createPublicKey(normalized);
  } catch (e) {
    throw new Error(`Invalid ${isPrivate ? 'private' : 'public'} key: ${e.message}`);
  }
  return normalized;
}

const payglocalPublicKey = loadKeyFromEnvOrFile(process.env.PAYGLOCAL_PUBLIC_KEY, false);
const merchantPrivateKey = loadKeyFromEnvOrFile(process.env.PAYGLOCAL_PRIVATE_KEY, true);

// Initialize client
const client = new PayGlocalClient({
  apiKey: process.env.PAYGLOCAL_API_KEY,
  merchantId: process.env.PAYGLOCAL_MERCHANT_ID,
  publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID,
  privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
  payglocalPublicKey,
  merchantPrivateKey,
  payglocalEnv: process.env.PAYGLOCAL_Env_VAR,
  logLevel: process.env.PAYGLOCAL_LOG_LEVEL || 'debug',
});

async function main() {
  try {
    const resp = await client.initiateJwtPayment({
      merchantTxnId: 'TXN_' + Date.now(),
      paymentData: {
        totalAmount: '1000.00',
        txnCurrency: 'INR',
        billingData: { emailId: 'customer@example.com' }
      },
      merchantCallbackURL: 'https://your-domain.com/payment/callback'
    });

    // Try common fields for redirect/payment link
    const paymentLink =
      resp?.data?.redirectUrl ||
      resp?.data?.redirect_url ||
      resp?.data?.payment_link ||
      resp?.redirectUrl ||
      resp?.redirect_url ||
      resp?.payment_link ||
      resp?.data?.paymentLink ||
      resp?.paymentLink;

    console.log('Initiate Payment Response:', resp);
    if (paymentLink) {
      console.log('Payment Link:', paymentLink);
    } else {
      console.warn('No payment link returned. Full response above.');
    }
  } catch (err) {
    console.error('Payment initiation failed:', err?.message || err);
    process.exitCode = 1;
  }
}

main();