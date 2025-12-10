const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const PayGlocalClient = require('./pg-client-sdk/lib/index.js');
const PayPdGlocalClient = require('./pgpd-client-sdk/lib/index.js');

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { start } = require('repl');
// Dynamic import for jose (ES Module)
let jose;
async function getJose() {
  if (!jose) {
    jose = await import('jose');
  }
  return jose;
}
const axios = require('axios');
// import multer from 'multer';
const multer = require('multer');
const upload = multer();
dotenv.config();
const port = process.env.PORT || 3000;

const app = express();

// CORS must be first
app.use(cors());

// Body parsers must come before routes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// app.use(express.text({ type: '*/*' }));


// Logging middleware
// app.use((req, res, next) => {
//   console.log(`${req.method} ${req.path}`);
//   next();
// });


app.use((req, res, next) => {
  console.log('------ incoming request ------');
  console.log('content-type:', req.headers['content-type']);
  console.log('query:', req.query);
  console.log('headers x-gl-token:', req.headers['x-gl-token']);
  // If you want to see body (may be empty without proper parser)
  console.log('body (may be parsed by express.json()):', req.body);
  next();
});


// Only start server if not in serverless environment (Vercel)
if (!process.env.VERCEL && !process.env.VERCEL_ENV) {
  app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
  });
}

// Export app for Vercel serverless function
module.exports = app;

function normalizePemKey(key) {
  if (!key || typeof key !== 'string') {
    throw new Error('Key must be a non-empty string');
  }
  
  let normalized = key.trim();
  
  // Log first 100 chars for debugging (without exposing full key)
  console.log(`[DEBUG] Key preview (first 100 chars): ${normalized.substring(0, 100)}`);
  console.log(`[DEBUG] Key contains \\n: ${normalized.includes('\\n')}`);
  console.log(`[DEBUG] Key contains actual newlines: ${normalized.includes('\n')}`);
  
  // Handle various escape patterns from Vercel env vars
  // Convert literal \n escape sequences to actual newlines
  normalized = normalized.replace(/\\n/g, '\n');
  
  // Handle double-escaped newlines (\\n -> \n -> actual newline)
  normalized = normalized.replace(/\\\\n/g, '\n');
  
  // Handle backslashes that appear where newlines should be (common in Vercel env vars)
  // Pattern: -----BEGIN...-----\M or -----END...-----\M should become -----BEGIN...-----\nM
  normalized = normalized.replace(/-----([A-Z\s]+)-----\\/g, '-----$1-----\n');
  
  // Handle backslashes before base64 content (where newlines should be in PEM format)
  // Pattern: backslash followed by base64 character (A-Z, a-z, 0-9, +, /, =)
  // This handles cases like: \MII... or \v1i... where \ should be \n
  // Only replace if it looks like a PEM line break (backslash before base64 content)
  normalized = normalized.replace(/\\([A-Za-z0-9+\/=])/g, '\n$1');
  
  // Normalize line endings
  normalized = normalized.replace(/\r\n|\r/g, '\n');
  
  // Remove empty lines
  normalized = normalized.replace(/\n\s*\n/g, '\n');
  
  // Ensure proper PEM format: BEGIN and END markers should be on their own lines
  normalized = normalized.replace(/-----BEGIN/g, '\n-----BEGIN');
  normalized = normalized.replace(/-----END/g, '\n-----END');
  
  // Clean up: remove leading/trailing whitespace and extra newlines
  normalized = normalized.trim();
  
  // Remove non-ASCII characters (but keep the key structure)
  normalized = normalized.replace(/[^\x00-\x7F]/g, '');
  
  // Final validation: ensure it looks like a PEM key
  if (!normalized.includes('-----BEGIN') || !normalized.includes('-----END')) {
    console.error('[ERROR] Key does not contain PEM markers after normalization');
    console.error(`[ERROR] Key preview: ${normalized.substring(0, 200)}`);
    throw new Error('Invalid PEM format: missing BEGIN or END markers');
  }
  
  console.log(`[DEBUG] Key normalized successfully, length: ${normalized.length}`);
  
  return normalized;
}

// Helper function to load key from env var or file
function loadKey(envVarName, filePathEnvVar) {
  // First try to load from environment variable (for Vercel)
  if (process.env[envVarName]) {
    console.log(`Loading ${envVarName} from environment variable`);
    return normalizePemKey(process.env[envVarName]);
  }

  // Fallback to file (for local development)
  if (process.env[filePathEnvVar]) {
    console.log(`Loading ${envVarName} from file: ${process.env[filePathEnvVar]}`);
    return normalizePemKey(fs.readFileSync(path.resolve(__dirname, process.env[filePathEnvVar]), 'utf8'));
  }

  throw new Error(`Neither ${envVarName} nor ${filePathEnvVar} is set`);
}

// Helper function to optionally load key (returns null if not set)
function loadKeyOptional(envVarName, filePathEnvVar) {
  // First try to load from environment variable (for Vercel)
  if (process.env[envVarName]) {
    console.log(`Loading ${envVarName} from environment variable`);
    return normalizePemKey(process.env[envVarName]);
  }

  // Fallback to file (for local development)
  if (process.env[filePathEnvVar]) {
    try {
      console.log(`Loading ${envVarName} from file: ${process.env[filePathEnvVar]}`);
      return normalizePemKey(fs.readFileSync(path.resolve(__dirname, process.env[filePathEnvVar]), 'utf8'));
    } catch (err) {
      console.log(`Optional key ${envVarName} not found, skipping`);
      return null;
    }
  }

  console.log(`Optional key ${envVarName} not set, skipping`);
  return null;
}

// Read and normalize PEM key content (supports both env vars and files)
// Configuration 1 is required
const payglocalPublicKey = loadKey('PAYGLOCAL_PUBLIC_KEY_CONTENT', 'PAYGLOCAL_PUBLIC_KEY');
const merchantPrivateKey = loadKey('PAYGLOCAL_PRIVATE_KEY_CONTENT', 'PAYGLOCAL_PRIVATE_KEY');

// Configuration 2 and 3 are optional
const payglocalPublicKey2 = loadKeyOptional('PAYGLOCAL_PUBLIC_KEY2_CONTENT', 'PAYGLOCAL_PUBLIC_KEY2');
const merchantPrivateKey2 = loadKeyOptional('PAYGLOCAL_PRIVATE_KEY2_CONTENT', 'PAYGLOCAL_PRIVATE_KEY2');

const merchantPrivateKey3 = loadKeyOptional('PAYGLOCAL_PRIVATE_KEY3_CONTENT', 'PAYGLOCAL_PRIVATE_KEY3');
// Validate keys
try {
  crypto.createPublicKey(payglocalPublicKey);
  console.log('Public key is valid');
} catch (e) {
  console.error('Invalid public key:', e.message);
}
try {
  crypto.createPrivateKey(merchantPrivateKey);
  console.log('Private key is valid');
} catch (e) {
  console.error('Invalid private key:', e.message);
}

const config = {
  apiKey: process.env.PAYGLOCAL_API_KEY,
  merchantId: process.env.PAYGLOCAL_MERCHANT_ID,
  publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID,
  privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
  payglocalPublicKey,
  merchantPrivateKey,
  payglocalEnv: process.env.PAYGLOCAL_Env_VAR,
  logLevel: process.env.PAYGLOCAL_LOG_LEVEL || 'debug'
};

// Secondary config/client for codedrop (separate MID/region) - optional
let config2 = null;
let client2 = null;
if (payglocalPublicKey2 && merchantPrivateKey2 && 
    process.env.PAYGLOCAL_API_KEY2 && process.env.PAYGLOCAL_MERCHANT_ID2) {
  config2 = {
    apiKey: process.env.PAYGLOCAL_API_KEY2,
    merchantId: process.env.PAYGLOCAL_MERCHANT_ID2,
    publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID2,
    privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID2,
    payglocalPublicKey: payglocalPublicKey2,
    merchantPrivateKey: merchantPrivateKey2,
    payglocalEnv: process.env.PAYGLOCAL_Env_VAR2 || process.env.PAYGLOCAL_Env_VAR,
    logLevel: process.env.PAYGLOCAL_LOG_LEVEL || 'debug'
  };
  client2 = new PayGlocalClient(config2);
  console.log('Configuration 2 (CodeDrop) initialized');
} else {
  console.log('Configuration 2 (CodeDrop) not available - skipping');
}

// Configuration 3 - optional
let config3 = null;
let client3 = null;
if (merchantPrivateKey3 && 
    process.env.PAYGLOCAL_API_KEY3 && process.env.PAYGLOCAL_MERCHANT_ID3) {
  config3 = {
    apiKey: process.env.PAYGLOCAL_API_KEY3,
    merchantId: process.env.PAYGLOCAL_MERCHANT_ID3,
    publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID3,
    privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID3,
    payglocalPublicKey,
    merchantPrivateKey: merchantPrivateKey3,
    payglocalEnv: process.env.PAYGLOCAL_Env_VAR3 || process.env.PAYGLOCAL_Env_VAR,
    logLevel: process.env.PAYGLOCAL_LOG_LEVEL || 'debug'
  };
  client3 = new PayGlocalClient(config3);
  console.log('Configuration 3 initialized');
} else {
  console.log('Configuration 3 not available - skipping');
}

// jwt based payment method
const client = new PayGlocalClient(config);

// PD client for card data processing
const pdclient = new PayPdGlocalClient(config); // or use config2/config3 if needed



// app.post('/api/pay/alt', async (req, res) => {
//   try {
//     const { merchantTxnId, merchantUniqueId, selectedPaymentMethod, paymentData, riskData, merchantCallbackURL } = req.body;

//     const payload = {
//       merchantTxnId,
//       merchantUniqueId,
//       selectedPaymentMethod,
//       paymentData,
//       riskData,
//       merchantCallbackURL,
//     };

//     console.log('Payload:', JSON.stringify(payload, null, 2));
//     console.log('Environment Variables:', {
//       MERCHANT_ID: process.env.PAYGLOCAL_MERCHANT_ID,
//       PUBLIC_KEY_ID: process.env.PAYGLOCAL_PUBLIC_KEY_ID,
//       PRIVATE_KEY_ID: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
//       API_KEY: process.env.PAYGLOCAL_API_KEY ? 'Set' : 'Not Set',
//     });

//     // Generate iat and exp
//     let iat = Date.now();
//     let exp = iat + 300000; // 5 minutes

//     // Encrypt payload into JWE
//     const payloadStr = JSON.stringify(payload);
//     const publicKey = await pemToKey(payglocalPublicKey, false);

//     const jwe = await new jose.CompactEncrypt(new TextEncoder().encode(payloadStr))
//       .setProtectedHeader({
//         alg: 'RSA-OAEP-256',
//         enc: 'A128CBC-HS256',
//         iat: iat.toString(), // String for consistency
//         exp: exp, // Number, not string
//         kid: process.env.PAYGLOCAL_PUBLIC_KEY_ID,
//         'issued-by': process.env.PAYGLOCAL_MERCHANT_ID,
//       })
//       .encrypt(publicKey);

//     console.log('JWE:', jwe);
//     console.log('JWE Header:', JSON.parse(Buffer.from(jwe.split('.')[0], 'base64').toString()));

//     // Sign JWE into JWS
//     const jwsIat = Date.now();
//     exp = 300000;

//     const privateKey = await pemToKey(merchantPrivateKey, true);
//     const digestObject = {
//       digest: crypto.createHash('sha256').update(jwe).digest('base64'),
//       digestAlgorithm: 'SHA-256',
//       exp: exp, // Number, not string
//       iat: iat.toString(), // String for consistency
//     };


//     const jws = await new jose.CompactSign(new TextEncoder().encode(JSON.stringify(digestObject)))
//       .setProtectedHeader({
//         alg: 'RS256',
//         kid: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
//         'x-gl-merchantId': process.env.PAYGLOCAL_MERCHANT_ID,
//         'issued-by': process.env.PAYGLOCAL_MERCHANT_ID,
//         'x-gl-enc': 'true',
//         'is-digested': 'true',
//       })
//       .sign(privateKey);

//     console.log('JWS:', jws);
//     console.log('JWS Header:', JSON.parse(Buffer.from(jws.split('.')[0], 'base64').toString()));

//     // Send to PayGlocal
//     const pgResponse = await axios.post(
//       'https://api.uat.payglocal.in/gl/v1/payments/initiate',
//       jwe, // Raw JWE string
//       {
//         headers: {
//           'Content-Type': 'text/plain',
//           'x-gl-token-external': jws,
//         },
//       }
//     );
//     console.log('PayGlocal Response:', pgResponse.data);

//     const redirect_url =
//       pgResponse.data?.data?.redirectUrl ||
//       pgResponse.data?.redirect_url ||
//       pgResponse.data?.payment_link;

//     const status_url =
//       pgResponse.data?.data?.statusUrl ||
//       pgResponse.data?.status_url ||
//       null;

//     if (!redirect_url) {
//       console.error('No redirect_url found in:', pgResponse.data);
//       return res.status(502).json({ error: 'No payment link received' });
//     }

//     res.status(200).json({
//       payment_link: redirect_url,
//       status_link: status_url,
//     });
//   } catch (error) {
//     if (axios.isAxiosError(error)) {
//       console.error('Payglocal Error Response:', JSON.stringify(error.response?.data, null, 2));
//       console.error('Status:', error.response?.status);
//       console.error('Headers:', error.response?.headers);
//       return res.status(error.response?.status || 500).json({
//         error: 'Payment initiation failed',
//         details: error.response?.data || error.message,
//       });
//     }

//     console.error('Error in /api/pay/alt:', error.message || error);
//     return res.status(500).json({
//       error: 'Internal server error',
//       details: error.message,
//     });
//   }
// });









// app.post('/api/pay/jwt', async (req, res) => {
//   try {
//     const { merchantTxnId, paymentData, merchantCallbackURL } = req.body;
//     if (!merchantTxnId || !paymentData || !merchantCallbackURL) {
//       return res.status(400).json({
//         status: 'error',
//         message: 'Missing required fields',
//         code: 'VALIDATION_ERROR',
//         details: { requiredFields: ['merchantTxnId', 'paymentData', 'merchantCallbackURL'] }
//       });
//     }

//     const payload = {
//       merchantTxnId,
//       paymentData,
//       merchantCallbackURL
//     };

//     console.log('Payload:', JSON.stringify(payload, null, 2));
//     console.log('Environment Variables:', {
//       MERCHANT_ID: process.env.PAYGLOCAL_MERCHANT_ID,
//       PUBLIC_KEY_ID: process.env.PAYGLOCAL_PUBLIC_KEY_ID,
//       PRIVATE_KEY_ID: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
//       API_KEY: process.env.PAYGLOCAL_API_KEY ? 'Set' : 'Not Set',
//     });

//     // Generate iat and exp

//     const jweIat = Math.floor(Date.now());
//     const jweExp = jweIat + 300000;

//     // Encrypt payload into JWE
//     const payloadStr = JSON.stringify(payload);
//     const publicKey = await pemToKey(payglocalPublicKey, false);
//     console.log({ publicKey })

//     const jwe = await new jose.CompactEncrypt(new TextEncoder().encode(payloadStr))
//       .setProtectedHeader({
//         alg: 'RSA-OAEP-256',
//         enc: 'A128CBC-HS256',
//         iat: jweIat.toString(),
//         exp: jweExp,
//         kid: process.env.PAYGLOCAL_PUBLIC_KEY_ID,
//         'issued-by': process.env.PAYGLOCAL_MERCHANT_ID,
//       })
//       .encrypt(publicKey);

//     console.log('JWE:', jwe);
//     console.log('JWE Header:', JSON.parse(Buffer.from(jwe.split('.')[0], 'base64').toString()));

//     // JWS token creation
//     console.log('Creating JWS token...');

//     // Generate iat and exp for JWS
//     const jwsIat = Math.floor(Date.now());
//     const jwsExp =  300000;

//     const privateKey = await pemToKey(merchantPrivateKey, true);
//     const digestObject = {
//       digest: crypto.createHash('sha256').update(jwe).digest('base64'),
//       digestAlgorithm: 'SHA-256',
//       iat: jweIat.toString(),
//       exp: 300000,
//     };

//     const jws = await new jose.CompactSign(new TextEncoder().encode(JSON.stringify(digestObject)))
//       .setProtectedHeader({
//         alg: 'RS256',
//         kid: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
//         'x-gl-merchantId': process.env.PAYGLOCAL_MERCHANT_ID,
//         'issued-by': process.env.PAYGLOCAL_MERCHANT_ID,
//         'x-gl-enc': 'true',
//         'is-digested': 'true',
//       })
//       .sign(privateKey);

//     console.log('JWS:', jws);
//     console.log('JWS Header:', JSON.parse(Buffer.from(jws.split('.')[0], 'base64').toString()));


//     // Send to PayGlocal
//     const pgResponse = await axios.post(
//       "https://api.uat.payglocal.in/gl/v1/payments/initiate/paycollect",
//       jwe,                         
//       {
//         headers: {
          // "Content-Type": "text/plain", 
          // "x-gl-token-external": jws,     
//         },
//       }
//     );

//     console.log('Raw PayGlocal response:', pgResponse.data);

//     const redirect_url =
//       pgResponse.data?.data?.redirectUrl ||
//       pgResponse.data?.redirect_url ||
//       pgResponse.data?.payment_link;

//     const status_url =
//       pgResponse.data?.data?.statusUrl ||
//       pgResponse.data?.status_url ||
//       null;

//     if (!redirect_url) {
//       console.error('No redirect_url found in:', pgResponse.data);
//       return res.status(502).json({ error: 'No payment link received' });
//     }

//     res.status(200).json({
//       payment_link: redirect_url,
//       status_link: status_url,
//     });
//   } catch (error) {
//     if (axios.isAxiosError(error)) {
//       console.error('Payglocal Error Response:', JSON.stringify(error.response?.data, null, 2));
//       console.error('Status:', error.response?.status);
//       console.error('Headers:', error.response?.headers);
//       return res.status(error.response?.status || 500).json({
//         error: 'Payment initiation failed',
//         details: error.response?.data || error.message,
//       });
//     }

//     console.error('Error in /api/pay/alt:', error.message || error);
//     return res.status(500).json({
//       error: 'Internal server error',
//       details: error.message,
//     });
//   }
// });


















app.post('/api/pay/jwt', async (req, res) => {
  try {
      const { merchantTxnId,paymentData, merchantCallbackURL} = req.body;
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

    console.log('Initiating JWT payment with payload:', payload);


    let payment;
    if (payload.paymentData.cardData) {
      payment = await pdclient.initiateJwtPayment(payload);

    } else {
      payment = await client.initiateJwtPayment(payload);
    }

    console.log('Raw SDK Response:', payment);

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
      raw_response: payment
    };

    res.status(200).json(formattedResponse);
  } catch (error) {
    console.error("Payment error:", error);
    res.status(500).json({
      status: "ERROR",
      message: "Payment failed",
      error: error.message || "Unknown error occurred",
      code: "PAYMENT_ERROR"
    });
  }

});



app.post('/callbackurl', (req, res) => {
  try {
    console.log('------ callbackurl request ------');

    console.log('req.body', req.body);
    const xGlToken = req.body['x-gl-token'] || req.headers['x-gl-token'] || req.query['x-gl-token'];

    if (!xGlToken) {
      console.error('Missing x-gl-token');
      return res.redirect('http://localhost:8080/#/payment-failure?reason=Missing+payment+token');
    }

    // console.log('xGlToken', xGlToken);

    const parts = xGlToken.split('.');


    const base64urlToBase64 = (str) => {
      const b64 = str.replace(/-/g, '+').replace(/_/g, '/');
      return b64.padEnd(Math.ceil(b64.length / 4) * 4, '=');
    };

    const payloadB64 = base64urlToBase64(parts[1]);
    const payloadJson = Buffer.from(payloadB64, 'base64').toString('utf8');
    const decoded = JSON.parse(payloadJson);

    console.log('\n========== decoded response, I am testing  ==========');
    console.log(decoded);
    console.log('====i am testing ====\n');


    if (decoded.status === 'SENT_FOR_CAPTURE') {
      const queryParams = new URLSearchParams({
        txnId: decoded.merchantTxnId || 'N/A',
        amount: decoded.Amount || decoded.amount || 'N/A',
        status: decoded.status,
        gid: decoded.gid || decoded['x-gl-gid'] || 'N/A',
        paymentMethod: decoded.paymentMethod || 'CARD'
      });
      console.log('Would redirect to success page with:', queryParams.toString());
      return res.redirect(`http://localhost:8080/#/payment-success?${queryParams.toString()}`);
      // return res.json({ ok: true, payload: decoded, redirectUrl: `http://localhost:8080/#/payment-success?${queryParams.toString()}` });
    } else {
      const reason = decoded.failureReason || decoded.message || `Payment status: ${decoded.status}`;
      console.log('Would redirect to failure page with reason:', reason);
      return res.redirect(`http://localhost:8080/#/payment-failure?reason=${encodeURIComponent(reason)}&txnId=${decoded.merchantTxnId || 'N/A'}`);
      // return res.json({ ok: false, payload: decoded, redirectUrl: `http://localhost:8080/#/payment-failure?reason=${encodeURIComponent(reason)}&txnId=${decoded.merchantTxnId || 'N/A'}` });
    }
  } catch (err) {
    console.error('Callback error:', err.message);
    return res.redirect(`http://localhost:8080/#/payment-failure?reason=${encodeURIComponent(err.message)}`);
    // return res.json({ error: 'Server error', details: err.message });
  }
});




// app.post('/callbackurl', (req, res) => {
//   try {
//     console.log('------ callbackurl request ------');
//     const xGlToken = req.body['x-gl-token'] || req.headers['x-gl-token'] || req.query['x-gl-token'];

//     if (!xGlToken) {
//       console.error('Missing x-gl-token');
//       return res.redirect('http://localhost:8080/#/payment-failure?reason=Missing+payment+token');
//     }

//     const parts = xGlToken.split('.');


//     const base64urlToBase64 = (str) => {
//       const b64 = str.replace(/-/g, '+').replace(/_/g, '/');
//       return b64.padEnd(Math.ceil(b64.length / 4) * 4, '=');
//     };

//     const payloadB64 = base64urlToBase64(parts[1]);
//     const payloadJson = Buffer.from(payloadB64, 'base64').toString('utf8');
//     const decoded = JSON.parse(payloadJson);

//     console.log('\n========== decoded response, I am testing  ==========');
//     console.log(decoded);
//     console.log('====i am testing ====\n');


//     if (decoded.status === 'SENT_FOR_CAPTURE') {
//       const queryParams = new URLSearchParams({
//         txnId: decoded.merchantTxnId || 'N/A',
//         amount: decoded.Amount || decoded.amount || 'N/A',
//         status: decoded.status,
//         gid: decoded.gid || decoded['x-gl-gid'] || 'N/A',
//         paymentMethod: decoded.paymentMethod || 'CARD'
//       });
//       console.log('Would redirect to success page with:', queryParams.toString());
//       return res.redirect(`http://localhost:8080/#/payment-success?${queryParams.toString()}`);
//       // return res.json({ ok: true, payload: decoded, redirectUrl: `http://localhost:8080/#/payment-success?${queryParams.toString()}` });
//     } else {
//       const reason = decoded.failureReason || decoded.message || `Payment status: ${decoded.status}`;
//       console.log('Would redirect to failure page with reason:', reason);
//       return res.redirect(`http://localhost:8080/#/payment-failure?reason=${encodeURIComponent(reason)}&txnId=${decoded.merchantTxnId || 'N/A'}`);
//       // return res.json({ ok: false, payload: decoded, redirectUrl: `http://localhost:8080/#/payment-failure?reason=${encodeURIComponent(reason)}&txnId=${decoded.merchantTxnId || 'N/A'}` });
//     }
//   } catch (err) {
//     console.error('Callback error:', err.message);
//     return res.redirect(`http://localhost:8080/#/payment-failure?reason=${encodeURIComponent(err.message)}`);
//     // return res.json({ error: 'Server error', details: err.message });
//   }
// });














/////Standing Instruction payment methods//////

app.post('/api/pay/si', async (req, res) => {
  console.log('Received request to initiate SI payment');
  try {
    const { merchantTxnId, paymentData, merchantCallbackURL, standingInstruction } = req.body;
    if (!merchantTxnId || !paymentData || !merchantCallbackURL || !standingInstruction) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing required fields',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['merchantTxnId', 'paymentData', 'merchantCallbackURL', 'standingInstruction'] }
      });
    }

    const payload = {
      merchantTxnId,
      paymentData,
      standingInstruction,
      merchantCallbackURL,
    };
    console.log('Initiating SI payment with payload:', payload);

    let payment;

    if (paymentData.cardData) {
      // payment = await pdclient.initiateSiPayment(payload);
    }
    else if (standingInstruction.data.maxAmount) {
      if (!client3) {
        return res.status(400).json({
          status: 'error',
          message: 'Configuration 3 not available. Please set PAYGLOCAL_API_KEY3 and related environment variables.',
          code: 'CONFIG_ERROR'
        });
      }
      payment = await client3.initiateSiPayment(payload);
    }
    else {
      payment = await client.initiateSiPayment(payload);
    }

    console.log('Raw SDK Response:', payment);

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

    const mandateId = payment?.mandateId ||
      payment?.data?.mandateId ||
      payment?.standingInstruction?.mandateId;

    // Format response to match frontend expectations
    const formattedResponse = {
      status: 'SUCCESS',
      message: 'SI Payment initiated successfully',
      payment_link: paymentLink,
      gid: gid,
      mandateId: mandateId,
      // Include all other fields from PayGlocal response for debugging
      raw_response: payment
    };

    res.status(200).json(formattedResponse);
  } catch (error) {
    console.error("Payment error:", error);
    res.status(500).json({
      status: "ERROR",
      message: "Payment failed",
      error: error.message || "Unknown error occurred",
      code: "PAYMENT_ERROR"
    });
  }
});


// Auth payment methods/////

app.post('/api/pay/auth', async (req, res) => {
  console.log('Received request to initiate Auth payment');
  try {
    const { merchantTxnId, paymentData, captureTxn, riskData, merchantCallbackURL } = req.body;
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
      captureTxn,
      riskData,
      merchantCallbackURL,
    };

    console.log('Initiating Auth payment with payload:', payload);

    let payment;

    if (payload.paymentData.cardData) {
      // payment = await pdclient.initiateAuthPayment(payload);
    } else {
      payment = await client.initiateAuthPayment(payload);
    }

    console.log('Raw SDK Response:', payment);

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
      message: 'Auth Payment initiated successfully',
      payment_link: paymentLink,
      gid: gid,
      // Include all other fields from PayGlocal response for debugging
      raw_response: payment
    };

    res.status(200).json(formattedResponse);
  } catch (error) {
    console.error("Payment error:", error);
    res.status(500).json({
      status: "ERROR",
      message: "Payment failed",
      error: error.message || "Unknown error occurred",
      code: "PAYMENT_ERROR"
    });
  }
});


async function pemToKey(pem, isPrivate = false) {
  const joseModule = await getJose();
  return isPrivate
    ? await joseModule.importPKCS8(pem, 'RS256') // JWS
    : await joseModule.importSPKI(pem, 'RSA-OAEP-256'); // JWE
}


// // Alt Pay payment method with JWT authentication (direct implementation)//
// app.post('/api/pay/alt', async (req, res) => {
//   try {
//     const { merchantTxnId, merchantUniqueId, selectedPaymentMethod, paymentData, riskData, merchantCallbackURL } = req.body;



// Refund service method//

app.post('/api/refund', async (req, res) => {
  console.log('>>> /api/refund endpoint hit');
  try {
    const { gid, refundType, paymentData } = req.body;

    console.log('Received refund request:', { gid, refundType, paymentData });

    if (!gid) {
      console.error('Missing gid');
      return res.status(400).json({
        status: 'error',
        message: 'Missing gid',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['gid'] }
      });
    }

    if (refundType === 'P' && (!paymentData || !paymentData.totalAmount)) {
      console.error('Missing paymentData.totalAmount for partial refund');
      return res.status(400).json({
        status: 'error',
        message: 'Missing paymentData.totalAmount for partial refund',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['paymentData.totalAmount'] }
      });
    }



    const merchantTxnId = '1100TestRefund0011';

    const payload = {
      refundType,
      gid,
      merchantTxnId,
      paymentData: refundType === 'F' ? { totalAmount: 0 } : { totalAmount: paymentData.totalAmount }
    };

    console.log('payload', payload);

    const refundDetail = await client.initiateRefund(payload);
    console.log('Raw SDK Response:', refundDetail);

    // Check if the SDK response indicates an error
    if (refundDetail?.status === 'REQUEST_ERROR' || refundDetail?.status === 'ERROR' || refundDetail?.error) {
      throw new Error(`PayGlocal SDK Error: ${refundDetail.message || refundDetail.error || 'Unknown error'}`);
    }

    // Extract fields from the actual PayGlocal response structure
    const refundGid = refundDetail?.gid ||
      refundDetail?.data?.gid ||
      refundDetail?.transactionId ||
      refundDetail?.data?.transactionId;

    const refundId = refundDetail?.refundId ||
      refundDetail?.data?.refundId ||
      refundDetail?.id ||
      refundDetail?.data?.id;

    const status = refundDetail?.status ||
      refundDetail?.data?.status ||
      refundDetail?.result ||
      refundDetail?.data?.result;

    // Format response to match frontend expectations
    const formattedResponse = {
      status: 'SUCCESS',
      message: `Refund ${status ? status.toLowerCase() : 'initiated'} successfully`,
      gid: refundGid,
      refundId: refundId,
      transactionStatus: status,
      // Include all other fields from PayGlocal response for debugging
      raw_response: refundDetail
    };

    res.status(200).json(formattedResponse);
  } catch (error) {
    console.error('Refund failed:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'Refund failed',
      code: 'REFUND_ERROR'
    });
  }
});


// Capture service method//

app.post('/api/cap', async (req, res) => {
  console.log('>>> /api/cap endpoint hit');
  try {
    const { captureType, paymentData } = req.body;
    const { gid } = req.query;

    const merchantTxnId = '1100TestCapture0011';

    console.log('Received capture request:', { gid, captureType, paymentData });

    if (!gid) {
      console.error('Missing gid');
      return res.status(400).json({
        status: 'error',
        message: 'Missing gid',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['gid'] }
      });
    }

    if (captureType === 'P' && (!paymentData || !paymentData.totalAmount)) {
      console.error('Missing paymentData.totalAmount for partial capture');
      return res.status(400).json({
        status: 'error',
        message: 'Missing paymentData.totalAmount for partial capture',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['paymentData.totalAmount'] }
      });
    }

    const payload = captureType === 'F'
      ? { captureType: 'F', gid, merchantTxnId }
      : {
        captureType: 'P',
        gid,
        merchantTxnId,
        paymentData: { totalAmount: paymentData.totalAmount }
      };

    const payment = await client.initiateCapture(payload);
    console.log('Raw SDK Response:', payment);

    // Extract fields from the actual PayGlocal response structure
    const captureGid = payment?.gid ||
      payment?.data?.gid ||
      payment?.transactionId ||
      payment?.data?.transactionId;

    const captureId = payment?.captureId ||
      payment?.data?.captureId ||
      payment?.id ||
      payment?.data?.id;

    const captureStatus = payment?.status ||
      payment?.data?.status ||
      payment?.result ||
      payment?.data?.result;

    // Format response to match frontend expectations
    const formattedResponse = {
      status: 'SUCCESS',
      message: `Capture ${captureStatus ? captureStatus.toLowerCase() : 'initiated'} successfully`,
      gid: captureGid,
      captureId: captureId,
      transactionStatus: captureStatus,
      // Include all other fields from PayGlocal response for debugging
      raw_response: payment
    };

    res.status(200).json(formattedResponse);
  } catch (error) {
    console.error('Capture failed:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'Capture failed',
      code: 'CAPTURE_ERROR'
    });
  }
});



// Auth Reversal service method //

app.post('/api/authreversal', async (req, res) => {
  console.log('>>> /api/authreversal endpoint hit');
  try {
    const { gid } = req.query;
    if (!gid) {
      console.error('Missing gid');
      return res.status(400).json({
        status: 'error',
        message: 'Missing gid',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['gid'] }
      });
    }
    const merchantTxnId = '1100TestAuthReversal011';
    const payload = { gid, merchantTxnId };
    const payment = await client.initiateAuthReversal(payload);
    console.log('Raw SDK Response:', payment);

    // Extract fields from the actual PayGlocal response structure
    const reversalGid = payment?.gid ||
      payment?.data?.gid ||
      payment?.transactionId ||
      payment?.data?.transactionId;

    const reversalId = payment?.reversalId ||
      payment?.data?.reversalId ||
      payment?.id ||
      payment?.data?.id;

    const reversalStatus = payment?.status ||
      payment?.data?.status ||
      payment?.result ||
      payment?.data?.result;

    // Format response to match frontend expectations
    const formattedResponse = {
      status: 'SUCCESS',
      message: `Auth reversal ${reversalStatus ? reversalStatus.toLowerCase() : 'initiated'} successfully`,
      gid: reversalGid,
      reversalId: reversalId,
      transactionStatus: reversalStatus,
      // Include all other fields from PayGlocal response for debugging
      raw_response: payment
    };

    res.status(200).json(formattedResponse);
  } catch (error) {
    console.error('Auth reversal failed:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'Auth reversal failed',
      code: 'AUTH_REVERSAL_ERROR'
    });
  }
});



// Check Status service method //


// app.get('/api/status', async (req, res) => {
//   console.log('>>> /api/status endpoint hit');
//   try {
//     const { gid } = req.query;
//     console.log('Received status check request:', { gid });

//     if (!gid) {
//       console.error('Missing gid');
//       return res.status(400).json({
//         status: 'error',
//         message: 'Missing gid',
//         code: 'VALIDATION_ERROR',
//         details: { requiredFields: ['gid'] }
//       });
//     }

//     const payload = { gid };

//     const payment = await client.initiateCheckStatus(payload);
//     console.log('Raw SDK Response:', payment);

//     // Extract fields from the actual PayGlocal response structure
//     const statusGid = payment?.gid ||
//       payment?.data?.gid ||
//       payment?.transactionId ||
//       payment?.data?.transactionId;

//     const statusResult = payment?.status ||
//       payment?.data?.status ||
//       payment?.result ||
//       payment?.data?.result ||
//       payment?.transactionStatus ||
//       payment?.data?.transactionStatus;

//     // Format response to match frontend expectations
//     const formattedResponse = {
//       status: 'SUCCESS',
//       message: `Status check completed - Transaction ${statusResult ? statusResult.toLowerCase() : 'status retrieved'}`,
//       gid: statusGid,
//       transactionStatus: statusResult,
//       // Include all other fields from PayGlocal response for debugging
//       raw_response: payment
//     };

//     res.status(200).json(formattedResponse);
//   } catch (error) {
//     console.error('Status check failed:', error);
//     return res.status(500).json({
//       status: 'error',
//       message: error.message || 'Status check failed',
//       code: 'STATUS_CHECK_ERROR'
//     });
//   }
// });




app.get('/api/status', async (req, res) => {
  console.log('>>> /api/status endpoint hit');
try {
  const { gid } = req.query;

  if (!gid) {
    return res.status(400).json({
      status: 'error',
      message: 'Missing gid',
      code: 'VALIDATION_ERROR',
      details: { requiredFields: ['gid'] },
    });
  }

  const path = `/gl/v1/payments/${gid}/status`;
  const statusUrl =`https://api.uat.payglocal.in/gl/v1/payments/${gid}/status`;

  console.log('GID:', gid);
  console.log('Status URL:', statusUrl);


  const iat = Date.now();            
  const exp = iat + 300000;           

  const digest = crypto.createHash('sha256').update(path).digest('base64');
  const digestObject = {
    digest,
    digestAlgorithm: 'SHA-256',
    exp,                    
    iat: iat.toString(),     
  };

  // 3) Sign with merchant private key → JWS
  const privateKey = await pemToKey(merchantPrivateKey, true);
  const joseModule = await getJose();
  const jws = await new joseModule.SignJWT(digestObject)
    .setProtectedHeader({
      alg: 'RS256',
      kid: process.env.PAYGLOCAL_PRIVATE_KEY_ID,
      'x-gl-merchantId': process.env.PAYGLOCAL_MERCHANT_ID,
      'issued-by': process.env.PAYGLOCAL_MERCHANT_ID,
      'x-gl-enc': 'true',
      'is-digested': 'true',
    })
    .sign(privateKey);

  console.log('Status JWS header:', JSON.parse(Buffer.from(jws.split('.')[0], 'base64').toString()));

 
  const statusResponse = await axios.get(statusUrl, {
    headers: {
      'x-gl-token-external': jws,   
    },
  });

  console.log('Raw PayGlocal status response:', statusResponse.data);

  // 5) Return status to frontend (you can format this as you like)
  return res.status(200).json({
    status: 'SUCCESS',
    gid,
    raw_response: statusResponse.data,
  });
} catch (error) {
  if (axios.isAxiosError(error)) {
    console.error('PayGlocal Status Error Response:', JSON.stringify(error.response?.data, null, 2));
    console.error('Status:', error.response?.status);
    console.error('Headers:', error.response?.headers);
    return res.status(error.response?.status || 500).json({
      status: 'error',
      message: 'Status check failed',
      details: error.response?.data || error.message,
    });
  }

  console.error('Manual status check error:', error.message || error);
  return res.status(500).json({
    status: 'error',
    message: error.message || 'Status check failed',
  });
}
});














// Pause/Activate service method //

app.post('/api/pauseActivate', async (req, res) => {
  console.log('Received request to initiate pause/activate SI');

  try {
    const { standingInstruction } = req.body;
    const merchantTxnId = '1100pauseActivate011';
    if (!standingInstruction) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing standingInstruction',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['standingInstruction'] }
      });
    }

    if (!standingInstruction.action || !standingInstruction.mandateId) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing action or mandateId in standingInstruction',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['standingInstruction.action', 'standingInstruction.mandateId'] }
      });
    }
    // md_9893c7d8-271f-43fd-9df0-54c42ba1a2d6,gl_o-9683ae6a532e7ed664430ZrX2

    const payload = {
      merchantTxnId,
      standingInstruction,
    };

    console.log('Initiating SI with payload:', payload);

    const action = standingInstruction.action.toUpperCase();

    if (action === 'PAUSE') {
      response = await client.initiatePauseSI(payload);
    } else if (action === 'ACTIVATE') {
      response = await client.initiateActivateSI(payload);
    } else {
      return res.status(400).json({
        status: 'error',
        message: `Unsupported action: ${standingInstruction.action}`,
        code: 'VALIDATION_ERROR',
        details: { supportedActions: ['PAUSE', 'ACTIVATE'] }
      });
    }

    console.log('Raw SDK Response:', response);

    // Extract fields from the actual PayGlocal response structure
    const siMandateId = response?.mandateId ||
      response?.data?.mandateId ||
      response?.standingInstruction?.mandateId;

    const siStatus = response?.status ||
      response?.data?.status ||
      response?.result ||
      response?.data?.result;

    // Format response to match frontend expectations
    const formattedResponse = {
      status: 'SUCCESS',
      message: `SI ${action} ${siStatus ? siStatus.toLowerCase() : 'completed'} successfully`,
      mandateId: siMandateId,
      action: standingInstruction.action,
      transactionStatus: siStatus,
      // Include all other fields from PayGlocal response for debugging
      raw_response: response
    };

    res.status(200).json(formattedResponse);
  } catch (error) {
    console.error('SI pause/activate failed:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'SI pause/activate failed',
      code: 'SI_ERROR'
    });
  }
});

app.post('/api/codedrop', async (req, res) => {
  console.log('>>> /api/codedrop endpoint hit - Code Drop');
  try {
    const { merchantTxnId, paymentData, riskData, merchantCallbackURL, cdId, displayMode } = req.body;

    if (
      !merchantTxnId ||
      // !merchantUniqueId ||
      !paymentData ||
      !paymentData.totalAmount ||
      !paymentData.txnCurrency ||
      !paymentData.billingData ||
      !paymentData.billingData.emailId ||
      !merchantCallbackURL
    ) {
      return res.status(400).json({
        error: 'Missing required fields: merchantTxnId, paymentData (with totalAmount, txnCurrency, billingData.emailId), or merchantCallbackURL'
      });
    }

    // Build payload
    const payload = {
      merchantTxnId,
      paymentData,
      riskData,
      merchantCallbackURL,
    };

    console.log('Payload:', JSON.stringify(payload, null, 2));

    console.log('Environment Variables:', {
      MERCHANT_ID: process.env.PAYGLOCAL_MERCHANT_ID2,
      PUBLIC_KEY_ID: process.env.PAYGLOCAL_PUBLIC_KEY_ID2,
      PRIVATE_KEY_ID: process.env.PAYGLOCAL_PRIVATE_KEY_ID2,
      API_KEY: process.env.PAYGLOCAL_API_KEY ? 'Set' : 'Not Set',
    });

    // Generate iat and exp
    // let iat = Date.now();
    // let exp = iat + 300000; // 5 minutes

    // // Encrypt payload into JWE
    // const payloadStr = JSON.stringify(payload);
    const publicKey2 = await pemToKey(payglocalPublicKey2, false);

    // const jwe = await new jose.CompactEncrypt(new TextEncoder().encode(payloadStr))
    //   .setProtectedHeader({
    //     alg: 'RSA-OAEP-256',
    //     enc: 'A128CBC-HS256',
    //     iat: iat.toString(), // String for consistency
    //     exp: exp, // Number, not string
    //     kid: process.env.PAYGLOCAL_PUBLIC_KEY_ID2,
    //     'issued-by': process.env.PAYGLOCAL_MERCHANT_ID2,
    //   })
    //   .encrypt(publicKey2);

    // console.log('JWE:', jwe);
    // console.log('JWE Header:', JSON.parse(Buffer.from(jwe.split('.')[0], 'base64').toString()));

    //testing 
    // / Generate iat and exp for JWE
    const jweIat = Math.floor(Date.now() / 1000);
    const jweExp = jweIat + 300;

    // Encrypt payload into JWE
    const payloadStr = JSON.stringify(payload);
    const publicKey = await pemToKey(payglocalPublicKey, false);
    console.log({ publicKey })
    const joseModule = await getJose();

    const jwe = await new joseModule.CompactEncrypt(new TextEncoder().encode(payloadStr))
      .setProtectedHeader({
        alg: 'RSA-OAEP-256',
        enc: 'A128CBC-HS256',
        iat: jweIat.toString(),
        exp: jweExp,
        kid: process.env.PAYGLOCAL_PUBLIC_KEY_ID2,
        'issued-by': process.env.PAYGLOCAL_MERCHANT_ID2,
      })
      .encrypt(publicKey2);

    console.log('JWE:', jwe);
    console.log('JWE Header:', JSON.parse(Buffer.from(jwe.split('.')[0], 'base64').toString()));

    // Sign JWE into JWS
    // const jwsIat = Date.now();
    // exp = 300000;

    const privateKey2 = await pemToKey(merchantPrivateKey2, true);
    // const digestObject = {
    //   digest: crypto.createHash('sha256').update(jwe).digest('base64'),
    //   digestAlgorithm: 'SHA-256',
    //   exp: exp, // Number, not string
    //   iat: iat.toString(), // String for consistency
    // };

    // const jws = await new jose.CompactSign(new TextEncoder().encode(JSON.stringify(digestObject)))
    //   .setProtectedHeader({
    //     alg: 'RS256',
    //     kid: process.env.PAYGLOCAL_PRIVATE_KEY_ID2,
    //     'x-gl-merchantId': process.env.PAYGLOCAL_MERCHANT_ID2,
    //     'issued-by': process.env.PAYGLOCAL_MERCHANT_ID2,
    //     'x-gl-enc': 'true',
    //     'is-digested': 'true',
    //   })
    //   .sign(privateKey2);

    // console.log('JWS:', jws);
    // console.log('JWS Header:', JSON.parse(Buffer.from(jws.split('.')[0], 'base64').toString()));


    //testing
    // JWS token creation
    console.log('Creating JWS token...');

    // Generate iat and exp for JWS
    const jwsIat = Math.floor(Date.now() / 1000);
    const jwsExp = jwsIat + 300;

    const privateKey = await pemToKey(merchantPrivateKey, true);
    const digestObject = {
      digest: crypto.createHash('sha256').update(jwe).digest('base64'),
      digestAlgorithm: 'SHA-256',
      exp: jwsExp,
      iat: jwsIat,
    };
    const joseModule2 = await getJose();

    const jws = await new joseModule2.CompactSign(new TextEncoder().encode(JSON.stringify(digestObject)))
      .setProtectedHeader({
        alg: 'RS256',
        kid: privateKeyId,
        'x-gl-merchantId': process.env.PAYGLOCAL_MERCHANT_ID2,
        'issued-by': process.env.PAYGLOCAL_MERCHANT_ID2,
        'x-gl-enc': 'true',
        'is-digested': 'true',
      })
      .sign(privateKey2);

    console.log('JWS:', jws);
    console.log('JWS Header:', JSON.parse(Buffer.from(jws.split('.')[0], 'base64').toString()));




    const pgResponse = await axios.post(
      'https://api.uat.payglocal.in/gl/v1/payments/initiate/paycollect',
      jwe,
      {
        headers: {
          'Content-Type': 'text/plain',
          'x-gl-token-external': jws,
        },
      }
    );

    console.log('PayGlocal response status:', pgResponse.status);

    const responseData = pgResponse.data || {};
    // Try different keys for redirect url as PayGlocal may vary
    const redirectUrl =
      responseData.redirectUrl ||
      responseData.redirect_url ||
      responseData.payment_link ||
      responseData.paymentLink ||
      (responseData.data && (responseData.data.redirectUrl || responseData.data.payment_link));

    if (!redirectUrl) {
      console.error('No redirect URL returned from PayGlocal:', responseData);
      return res.status(500).json({ error: 'No redirect URL returned from PayGlocal', raw: responseData });
    }

    // Extract statusUrl and gid if present (for later status polling)
    const statusUrl =
      responseData.statusUrl ||
      responseData.status_url ||
      (responseData.data && (responseData.data.statusUrl || responseData.data.status_url));

    let gid = responseData.gid || (responseData.data && responseData.data.gid) || null;
    if (!gid && statusUrl) {
      const match = statusUrl.match(/\/payments\/([^/]+)\/status/);
      gid = match && match[1] ? match[1] : null;
    }

    console.log('Codedrop redirectUrl:', redirectUrl);
    console.log('Codedrop gid:', gid);
    console.log('Codedrop statusUrl:', statusUrl);

    return res.status(200).json({ redirectUrl: redirectUrl, gid: gid, statusUrl: statusUrl });
  } catch (err) {
    console.error('Code Drop payment error:', err?.response?.data || err.message || err);
    return res.status(500).json({
      status: 'ERROR',
      message: 'Code Drop payment failed',
      error: err?.response?.data || err.message || 'Unknown',
    });
  }
});




////////////////8*****************************************8////////////////

// Status check for codedrop MID/region
app.get('/api/codedrop/status', async (req, res) => {
  console.log('>>> /api/codedrop/status endpoint hit');
  try {
    const { gid } = req.query;
    console.log('Received codedrop status check request:', { gid });

    if (!gid) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing gid',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['gid'] }
      });
    }

    if (!client2) {
      return res.status(400).json({
        status: 'error',
        message: 'Configuration 2 (CodeDrop) not available. Please set PAYGLOCAL_API_KEY2 and related environment variables.',
        code: 'CONFIG_ERROR'
      });
    }
    const payment = await client2.initiateCheckStatus({ gid });
    console.log('Raw SDK Response (codedrop):', payment);

    const statusGid = payment?.gid || payment?.data?.gid || payment?.transactionId || payment?.data?.transactionId;
    const statusResult = payment?.status || payment?.data?.status || payment?.result || payment?.data?.result || payment?.transactionStatus || payment?.data?.transactionStatus;

    const formattedResponse = {
      status: 'SUCCESS',
      message: `Codedrop status - Transaction ${statusResult ? statusResult.toLowerCase() : 'status retrieved'}`,
      gid: statusGid,
      transactionStatus: statusResult,
      raw_response: payment
    };

    res.status(200).json(formattedResponse);
  } catch (error) {
    console.error('Codedrop status check failed:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'Codedrop status check failed',
      code: 'CODEDROP_STATUS_ERROR'
    });
  }
});

// SI On-Demand sale method //
app.post('/api/siOnDemand', async (req, res) => {
  console.log('>>> /api/siOnDemand endpoint hit');
  try {
    const { paymentData = {}, standingInstruction } = req.body;

    if (!standingInstruction || !standingInstruction.mandateId) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing required fields',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['standingInstruction.mandateId'] }
      });
    }

    const hasAmount = paymentData && paymentData.totalAmount != null && String(paymentData.totalAmount).trim() !== '';

    const payload = hasAmount
      ? {
        merchantTxnId: 'SI_ON_DEMAND_' + Date.now(),
        paymentData: { totalAmount: paymentData.totalAmount },
        standingInstruction: { mandateId: standingInstruction.mandateId }
      }
      : {
        merchantTxnId: 'SI_ON_DEMAND_' + Date.now(),
        standingInstruction: { mandateId: standingInstruction.mandateId }
      };

    console.log('Initiating SI On-Demand with payload:', payload);
    let response;
    if (hasAmount) {
      if (!client3) {
        return res.status(400).json({
          status: 'error',
          message: 'Configuration 3 not available. Please set PAYGLOCAL_API_KEY3 and related environment variables.',
          code: 'CONFIG_ERROR'
        });
      }
      response = await client3.initiateSiOnDemandVariable(payload);
    } else {
      response = await client.initiateSiOnDemandFixed(payload);
    }

    // const response = await client3.initiateSiOnDemand(payload);
    console.log('Raw SDK Response (SI On-Demand):', response);

    const status = response?.status || response?.data?.status || response?.result || response?.data?.result || 'SUCCESS';
    const respMandateId = response?.mandateId || response?.data?.mandateId || standingInstruction.mandateId;

    const formatted = {
      status: 'SUCCESS',
      message: `SI on-demand ${status ? status.toLowerCase() : 'completed'}`,
      mandateId: respMandateId,
      raw_response: response
    };

    return res.status(200).json(formatted);
  } catch (error) {
    console.error('SI On-Demand failed:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'SI On-Demand failed',
      code: 'SI_ON_DEMAND_ERROR'
    });
  }
});






app.post('/api/siStatus', async (req, res) => {
  console.log('>>> /api/siStatus endpoint hit');
  try {
    const { standingInstruction } = req.body;

    if (!standingInstruction || !standingInstruction.mandateId) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing required fields',
        code: 'VALIDATION_ERROR',
        details: { requiredFields: ['standingInstruction.mandateId'] }
      });
    }

    const payload = { standingInstruction };
    const response = await client.initiateSiStatusCheck(payload);

    const siMandateId = response?.mandateId ||
      response?.data?.mandateId ||
      standingInstruction.mandateId;

    const siStatus = response?.status ||
      response?.data?.status ||
      response?.result ||
      response?.data?.result;

    const formatted = {
      status: 'SUCCESS',
      message: `SI status ${siStatus ? String(siStatus).toLowerCase() : 'retrieved'}`,
      mandateId: siMandateId,
      transactionStatus: siStatus,
      raw_response: response
    };

    return res.status(200).json(formatted);
  } catch (error) {
    console.error('SI status check failed:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'SI status check failed',
      code: 'SI_STATUS_ERROR'
    });
  }
});




