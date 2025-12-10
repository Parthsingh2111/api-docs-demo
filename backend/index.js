const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const PayGlocalClient = require('./pg-client-sdk/lib/index.js');
const PayPdGlocalClient = require('./pgpd-client-sdk/lib/index.js');

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { start } = require('repl');
const jose = require('jose');
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
  return key
    .trim()
    .replace(/\r\n|\r/g, '\n') // Normalize line endings to \n
    .replace(/\n\s*\n/g, '\n') // Remove empty lines
    .replace(/[^\x00-\x7F]/g, ''); // Remove non-ASCII characters
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

// Read and normalize PEM key content (supports both env vars and files)
const payglocalPublicKey = loadKey('PAYGLOCAL_PUBLIC_KEY_CONTENT', 'PAYGLOCAL_PUBLIC_KEY');
const merchantPrivateKey = loadKey('PAYGLOCAL_PRIVATE_KEY_CONTENT', 'PAYGLOCAL_PRIVATE_KEY');

const payglocalPublicKey2 = loadKey('PAYGLOCAL_PUBLIC_KEY2_CONTENT', 'PAYGLOCAL_PUBLIC_KEY2');
const merchantPrivateKey2 = loadKey('PAYGLOCAL_PRIVATE_KEY2_CONTENT', 'PAYGLOCAL_PRIVATE_KEY2');

const merchantPrivateKey3 = loadKey('PAYGLOCAL_PRIVATE_KEY3_CONTENT', 'PAYGLOCAL_PRIVATE_KEY3');
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

// Secondary config/client for codedrop (separate MID/region)
const config2 = {
  apiKey: process.env.PAYGLOCAL_API_KEY2,
  merchantId: process.env.PAYGLOCAL_MERCHANT_ID2,
  publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID2,
  privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID2,
  payglocalPublicKey: payglocalPublicKey2,
  merchantPrivateKey: merchantPrivateKey2,
  payglocalEnv: process.env.PAYGLOCAL_Env_VAR2 || process.env.PAYGLOCAL_Env_VAR,
  logLevel: process.env.PAYGLOCAL_LOG_LEVEL || 'debug'
};

const config3 = {
  apiKey: process.env.PAYGLOCAL_API_KEY3,
  merchantId: process.env.PAYGLOCAL_MERCHANT_ID3,
  publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID3,
  privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID3,
  payglocalPublicKey,
  merchantPrivateKey: merchantPrivateKey3,
  payglocalEnv: process.env.PAYGLOCAL_Env_VAR3 || process.env.PAYGLOCAL_Env_VAR,
  logLevel: process.env.PAYGLOCAL_LOG_LEVEL || 'debug'
};





// jwt based payment method
const client = new PayGlocalClient(config);
const client2 = new PayGlocalClient(config2);
const client3 = new PayGlocalClient(config3);

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
  return isPrivate
    ? await jose.importPKCS8(pem, 'RS256') // JWS
    : await jose.importSPKI(pem, 'RSA-OAEP-256'); // JWE
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
  const jws = await new jose.SignJWT(digestObject)
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

    const jwe = await new jose.CompactEncrypt(new TextEncoder().encode(payloadStr))
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

    const jws = await new jose.CompactSign(new TextEncoder().encode(JSON.stringify(digestObject)))
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

    const payload = {
      merchantTxnId: 'SI_Status_' + Date.now(),
      standingInstruction
    };
    console.log('Initiating SI status check with payload:', payload);
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
    console.log('SI status response:', JSON.stringify(formatted));

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







// async function createJwtPayment() {
//   try {
//     const response = await client.initiateJwtPayment(



// {
//   "merchantTxnId": "1756728697873338303",
//   "captureTxn": false,
//   "paymentData": {
//     "totalAmount": "117800.00",
//     "txnCurrency": "INR"
//   },
//   "riskData": {
//     "flightData": [
//       {
//         "journeyType": "ONEWAY",
//         "reservationDate": "20250901",
//         "legData": [
//           {
//             "routeId": "1",
//             "legId": "1",
//             "flightNumber": "BA112",
//             "departureAirportCode": "BLR",
//             "departureCity": "Bengaluru",
//             "departureDate": "2025-09-01T03:45:00Z",
//             "arrivalAirportCode": "LAX",
//             "arrivalCity": "Los Angeles",
//             "arrivalDate": "2025-09-01T13:15:00Z",
//             "carrierCode": "B7",
//             "serviceClass": "ECONOMY"
//           }
//         ],
//         "passengerData": [
//           {
//             "firstName": "Sam",
//             "lastName": "Thomas"
//           }
//         ]
//       }
//     ]
//   },
//   "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// }


// {
//   "merchantTxnId": "TXN123456789",
//   // "merchantUniqueId": "MUID987654321",
//   "merchantCallbackURL": "https://merchant.example.com/callback",
//   "captureTxn": true,
//   "gpiTxnTimeout": "300",
//   "paymentData": {

//     "totalAmount": "1500.00",
//     "txnCurrency": "INR",
//     "cardData": {
//       "number": "4111111111111111",
//       "expiryMonth": "12",
//       "expiryYear": "2026",
//       "securityCode": "123",
//       "type": "VISA"
//     },
//     "billingData": {
//       "fullName": "Rahul Sharma",
//       "firstName": "Rahul",
//       "lastName": "Sharma",
//       "addressStreet1": "123 MG Road",
//       "addressStreet2": null,
//       "addressCity": "Bengaluru",
//       "addressState": "Karnataka",
//       "addressStateCode": "KA",
//       "addressPostalCode": "560001",
//       "addressCountry": "IN",
//       "emailId": "rahul.sharma@example.com",
//       "callingCode": "+91",
//       "phoneNumber": "9876543210",
//       "panNumber": "ABCDE1234F"
//     }
//   },

// "orderData": [
//   {
//     "productDescription": "Flight from Delhi to Goa",
//     "productSKU": "FL123",
//     "productType": "Flight",
//     "itemUnitPrice": "1500.00",
//     "itemQuantity": "1"
//   }
// ],

//   "riskData": {

//     "customerData": {
//       "customerAccountType": "REGISTERED",
//       "customerSuccessOrderCount": "10",
//       "customerAccountCreationDate": "2021-01-15T10:00:00Z",
//       "merchantAssignedCustomerId": "CUST1001"
//     },
//     "shippingData": {
//       "fullName": "Rahul Sharma",
//       "firstName": "Rahul",
//       "lastName": "Sharma",
//       "addressStreet1": "123 MG Road",
//       "addressStreet2": null,
//       "addressCity": "Bengaluru",
//       "addressState": "Karnataka",
//       "addressStateCode": "KA",
//       "addressPostalCode": "560001",
//       "addressCountry": "IN",
//       "emailId": "rahul.sharma@example.com",
//       "callingCode": "+91",
//       "phoneNumber": "9876543210"
//     },
//     "flightData": [
//       {
//         "agentCode": "AGT123",
//         "agentName": "Best Travels",
//         "ticketNumber": "TCK987654321",
//         // "reservationDate": "2023-03-18T09:01:56Z",
//         "ticketIssueCity": "Delhi",
//         "ticketIssueState": "Delhi",
//         "ticketIssueCountry": "IN",
//         "ticketIssuePostalCode": "110001",
//         "reservationCode": "123456",
//         "reservationSystem": "Amadeus",
//         "journeyType": "ONEWAY",
//         "electronicTicket": "Y",
//         "refundable": "N",
//         "ticketType": "E-Ticket",
//         "legData": [
//           {
//             "routeId": "1",
//             "legId": "1",
//             "flightNumber": "AI202",
//             "departureDate": "2023-03-20T09:01:56Z",
//             "departureAirportCode": "DEL",
//             "departureCity": "Delhi",
//             "departureCountry": "IN",
//             "arrivalDate": "2023-03-20T11:15:00Z",
//             "arrivalAirportCode": "GOI",
//             "arrivalCity": "Goa",
//             "arrivalCountry": "IN",
//             "carrierCode": "AI",
//             "carrierName": "Air India",
//             "serviceClass": "Economy"
//           }
//         ],
//         "passengerData": [
//           {
//             "title": "Mr",
//             "firstName": "Rahul",
//             "lastName": "Sharma",
//             // "dateOfBirth": "1990-05-10T00:00:00Z",
//             "type": "ADT",
//             "email": "rahul.sharma@example.com",
//             "passportNumber": "P1234567",
//             "passportCountry": "IN",
//             // "passportIssueDate": "2015-01-01T00:00:00Z",
//             // "passportExpiryDate": "2025-01-01T00:00:00Z",
//             "referenceNumber": "PAX001"
//           }
//         ]
//       }
//     ]
//   }
// }


//        {
//         "merchantTxnId": "23AEE8CB6B62EE2AF07",
//         // "merchantUniqueId": "IFNN939494NJFJ",
//         "selectedPaymentMethod": {
//           "iso2CountryCode": "DE",
//           "methodName": "SOFORT" // Send exact value as received in response of the Get Method Service
//         },
//         "paymentData": {
//           "totalAmount": "300.00", // Minimum amount for Global Alt-Pay is INR 300 (or equivalent)
//           "txnCurrency": "INR", // Currencies supported for Global Alt-Pay are INR, AUD, AED, USD, SGD, NZD, EUR, GBP, and CAD
//           "billingData": {
//             "firstName": "John",
//             "lastName": "Denver",
//             "addressStreet1": "Rowdy Street 1", // Mandatory for Services Goods Export
//             "addressStreet2": "Rowdy Street 2",
//             "addressCity": "Stadt", // Mandatory for Digital Goods/ Services Goods Export
//             "addressState": "Berlin", // Mandatory for Digital Goods/ Services Goods Export
//             "addressPostalCode": "10274", // Mandatory for Digital Goods/ Services Goods Export
//             "addressCountry": "DE", // Mandatory for Digital Goods/ Services Goods Export
//             "emailId": "johndenver@myemail.com", // Mandatory for Digital Goods/ Services Export
//             "callingCode": "+91",
//             "phoneNumber": "9008018469" // Mandatory for Digital Goods/ Services Export
//           }
//         },
//         "riskData": {
//           "shippingData": {
//             "firstName": "John",
//             "lastName": "Denver",
//             "addressStreet1": "Rowdy Street 1", // Mandatory for Physical Goods Export
//             "addressStreet2": "Rowdy Street 2",
//             "addressCity": "Stadt", // Mandatory for Physical Goods Export
//             "addressState": "Berlin", // Mandatory for Physical Goods Export
//             "addressPostalCode": "10274", // Mandatory for Physical Goods Export
//             "addressCountry": "DE", // Mandatory for Physical Goods Export
//             "emailId": "johndenver@myemail.com",
//             "callingCode": "+91",
//             "phoneNumber": "9008018469"
//           }
//         },
//         "merchantCallbackURL": "https://www.merchanturl.com/callback"
//       }







//   );

//     console.log(' response received Successfully');
//     console.log('Resonse:', response);
//     return response;
//   } catch (error) {
//     // Print concise PayGlocal error if available, do not rethrow to avoid duplicate stacks
//     console.error(error && error.message ? error.message : 'Request failed');
//     return { error: true, message: error && error.message ? error.message : 'Request failed' };
//   }
// }

// createJwtPayment();

// // api key based payment method

// async function createApiKeyPayment() {
//   try {
//     const response = await client.initiateApiKeyPayment({
//       merchantTxnId: 'TXN_' + Date.now(),
//       paymentData: {
//         totalAmount: '500.00',
//         txnCurrency: 'INR',
//         billingData: {
//           emailId: 'customer@example.com'
//         }
//       },
//       merchantCallbackURL: 'https://your-domain.com/payment/callback'
//     });

//     console.log(' response received Successfully');
//     console.log('Resonse:', response);
//     return response;
//   } catch (error) {
//     console.error('Error: Response not received:', error.message);
//     throw error;
//   }
// }


// // createApiKeyPayment();


// async function createSiPayment() {
//   try {
//     const response = await client.initiateSiPayment({
//       merchantTxnId: 'SI_TXN_' + Date.now(),
//       paymentData: {
//         totalAmount: '1000.00',
//         txnCurrency: 'INR',
//         billingData: {
//           emailId: 'customer@example.com'
//         }
//       },
//       standingInstruction: {
//         data: {
//           numberOfPayments: '12',
//           frequency: 'MONTHLY',
//           type: 'FIXED',
//           amount: '1000.00',
//           startDate: '2025-09-01'
//         }
//       },
//       merchantCallbackURL: 'https://your-domain.com/payment/callback'
//     });

//     console.log('SI Payment Created');
//     console.log('response:', response);


//     return response;
//   } catch (error) {
//     console.error('SI Payment Failed:', error.message);
//     throw error;
//   }
// }

// // createSiPayment();


// // // Auth payment method
// async function createAuthPayment() {
//   try {
//     const response = await client.initiateAuthPayment(
//       // {
//       //   "merchantTxnId": "1756728697873338303",
//       //   "captureTxn": false,
//       //   "paymentData": {
//       //     "totalAmount": "117800.00",
//       //     "txnCurrency": "INR"
//       //   },
//       //   "riskData": {
//           // "trainData": [
//           //   {
//           //     "ticketNumber": "ticket12346",
//           //     "reservationDate": "20230220",
//           //     "legData": [
//           //       {
//           //         "routeId": "1",
//           //         "legId": "1",
//           //         "trainNumber": "train123",
//           //         "departureCity": "Kannur",
//           //         "departureCountry": "IN",
//           //         "departureDate": "2023-03-20T09:01:56Z",
//           //         "arrivalCity": "Coimbatore",
//           //         "arrivalCountry": "IN",
//           //         "arrivalDate": "2023-03-21T09:01:56Z"
//           //       }
//           //     ],
//           //     "passengerData": [
//           //       {
//           //         "firstName": "Sam",
//           //         "lastName": "Thomas",
//           //         "dateOfBirth": "19980320",
//           //         "passportCountry": "IN"
//           //       }
//           //     ]
//           //   }
//           // ]
//       //   },
//       //   "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
//       // }



//       {
//         "merchantTxnId": "TXN123456789",
//         "merchantCallbackURL": "https://merchant.com/callback",
//         "captureTxn": true,
//         "gpiTxnTimeout": "30",
//         "paymentData": {
//           "totalAmount": "1000.00",
//           "txnCurrency": "INR",
//           "cardData": {
//             "number": "4111111111111111",
//             "expiryMonth": "12",
//             "expiryYear": "2026",
//             "securityCode": "123",
//             "type": "VISA"
//           },
//           "billingData": {
//             "fullName": "Ravi Kumar",
//             "firstName": "Ravi",
//             "lastName": "Kumar",
//             "addressStreet1": "MG Road",
//             "addressStreet2": "Suite 10",
//             "addressCity": "Bengaluru",
//             "addressState": "Karnataka",
//             "addressStateCode": "KA",
//             "addressPostalCode": "560001",
//             "addressCountry": "IN",
//             "emailId": "ravi.kumar@example.com",
//             "callingCode": "+91",
//             "phoneNumber": "9876543210",
//             "panNumber": "ABCDE1234F"
//           }
//         },
//         "riskData": {
//           "orderData": [
//             {
//               "productDescription": "Flight Ticket",
//               "productSKU": "FL123",
//               "productType": "Flight",
//               "itemUnitPrice": "1000.00",
//               "itemQuantity": "1"
//             }
//           ],
//           "customerData": {
//             "customerAccountType": "Registered",
//             "customerSuccessOrderCount": "5",
//             "customerAccountCreationDate": "2022-01-10T00:00:00Z",
//             "merchantAssignedCustomerId": "CUST12345"
//           },
//           "shippingData": {
//             "fullName": "Ravi Kumar",
//             "firstName": "Ravi",
//             "lastName": "Kumar",
//             "addressStreet1": "MG Road",
//             "addressStreet2": "Suite 10",
//             "addressCity": "Bengaluru",
//             "addressState": "Karnataka",
//             "addressStateCode": "KA",
//             "addressPostalCode": "560001",
//             "addressCountry": "IN",
//             "emailId": "ravi.kumar@example.com",
//             "callingCode": "+91",
//             "phoneNumber": "9876543210"
//           },
//           "flightData": [
//             {
//               "agentCode": "AG001",
//               "agentName": "TravelWorld",
//               "ticketNumber": "0987654321",
//               "reservationDate": "2023-03-15T10:00:00Z",
//               "ticketIssueCity": "Delhi",
//               "ticketIssueState": "Delhi",
//               "ticketIssueCountry": "IN",
//               "ticketIssuePostalCode": "110001",
//               "reservationCode": "PNR12345",
//               "reservationSystem": "Amadeus",
//               "journeyType": "OneWay",
//               "electronicTicket": "true",
//               "refundable": "true",
//               "ticketType": "E-Ticket",
//               "legData": [
//                 {
//                   "routeId": "101",
//                   "legId": "1",
//                   "flightNumber": "AI202",
//                   "departureDate": "2023-03-20T09:01:56Z",
//                   "departureAirportCode": "DEL",
//                   "departureCity": "Delhi",
//                   "departureCountry": "IN",
//                   "arrivalDate": "2023-03-20T11:30:00Z",
//                   "arrivalAirportCode": "BOM",
//                   "arrivalCity": "Mumbai",
//                   "arrivalCountry": "IN",
//                   "carrierCode": "AI",
//                   "carrierName": "Air India",
//                   "serviceClass": "Economy"
//                 }
//               ],
//               "passengerData": [
//                 {
//                   "title": "Mr",
//                   "firstName": "Ravi",
//                   "lastName": "Kumar",
//                   "dateOfBirth": "1990-01-01T00:00:00Z",
//                   "type": "ADT",
//                   "email": "ravi.kumar@example.com",
//                   "passportNumber": "N1234567",
//                   "passportCountry": "IN",
//                   "passportIssueDate": "2015-01-01T00:00:00Z",
//                   "passportExpiryDate": "2025-01-01T00:00:00Z",
//                   "referenceNumber": "PAX001"
//                 }
//               ]
//             }
//           ]
//         }
//       }









//   );

//     console.log('Auth Payment Created');
//     console.log('response:', response);


//     return response;
//   } catch (error) {
//     console.error('Auth Payment Failed:', error.message);
//     throw error;
//   }
// }

// createAuthPayment();


// // transection service methods


// //check status method
// async function checkPaymentStatus(gid) {
//   try {
//     const response = await client.initiateCheckStatus({ gid });


//     console.log('Status Retrieved');
//     console.log('Status:', response.status);
//     console.log('GID:', response.gid);
//     console.log('Message:', response.message);

//     console.log('Raw Response:', response);

//     return response;
//   } catch (error) {
//     console.error('Status Check Failed:', error.message);
//     throw error;
//   }
// }
// // checkPaymentStatus('gl_o-96b659ad9445b2b15ov40RMX2');


// //check refund method

// async function refundPayment(gid, amount = null) {
//   try {
//     const response = await client.initiateRefund({
//       gid: gid,
//       merchantTxnId: 'REFUND_' + Date.now(),
//       refundType: amount ? 'P' : 'F', // P = Partial, F = Full
//       paymentData: amount ? { totalAmount: amount } : undefined
//     });

//     console.log('Payment Refunded');
//     console.log('Status:', response.status);
//     console.log('raw response:', response);
//     return response;
//   } catch (error) {
//     console.error('Refund Failed:', error.message);
//     throw error;
//   }
// }

// // refundPayment(); // Replace with actual GID and amount for partial refund


// async function reverseAuth(gid) {
//   try {
//     const response = await client.initiateAuthReversal({
//       gid: gid,
//       merchantTxnId: 'REVERSAL_' + Date.now()
//     });

//     console.log( 'Auth Reversed');
//     console.log('Status:', response.status);
//     console.log('response:', response);

//     return response;
//   } catch (error) {
//     console.error('Auth Reversal Failed:', error.message);
//     throw error;
//   }
// }

// // reverseAuth("gl_o-9628ffff042675e9b30Yyv7X2"); // Replace with actual GID




// // si service methods

// // si pause method(IMPORTANT: This method is used to pause the standing instruction, it can be used to pause the SI for a specific date or indefinitely. If you want to pause the SI for a specific date, you can pass the startDate parameter, otherwise you can leave it empty to pause indefinitely.)

// // async function pauseStandingInstruction(mandateId, startDate) {
// //   try {
// //     const response = await client.initiatePauseSI({
// //       merchantTxnId: 'PAUSE_SI_' + Date.now(),
// //       if(startDate){
// //          standingInstruction: {
// //         action: 'PAUSE',
// //         mandateId: mandateId,
// //       }}else{
// //              standingInstruction: {
// //         action: 'PAUSE',
// //         mandateId: mandateId,
// //         data: {
// //           startDate: startDate // Optional, if you want to specify a pause start date
// //       }

// //       }
// //     });

// //     console.log('SI Paused');
// //     console.log('Status:', response.status);
// //     console.log('Mandate ID:', response.mandateId);
// //     console.log('Raw Response:', response);
// //     return response;
// //   } catch (error) {
// //     console.error('SI Pause Failed:', error.message);
// //     throw error;
// //   }
// // }


// async function pauseStandingInstruction(mandateId, startDate) {
//   try {
//     const standingInstruction = {
//       action: 'PAUSE',
//       mandateId
//     };

//     if (startDate) {
//       standingInstruction.data = { startDate };
//     }

//     const response = await client.initiatePauseSI({
//       merchantTxnId: 'PAUSE_SI_' + Date.now(),
//       standingInstruction
//     });

//     console.log('SI Paused');
//     console.log('Status:', response.status);
//     console.log('Raw Response:', response);
//     return response;
//   } catch (error) {
//     console.error('SI Pause Failed:', error.message);
//     throw error;
//   }
// }

// // pauseStandingInstruction("md_87c381eb-46a9-4936-b05b-7403d02f8758", '20250901'); // Replace with actual Mandate ID and start date


// async function activateStandingInstruction(mandateId) {
//   try {
//     const response = await client.initiateActivateSI({
//       merchantTxnId: 'ACTIVATE_SI_' + Date.now(),
//       standingInstruction: {
//         action: 'ACTIVATE',
//         mandateId: mandateId
//       }
//     });

//     console.log('SI Activated');
//     console.log('Status:', response.status);
//     console.log('Raw Response:', response);
//     return response;
//   } catch (error) {
//     console.error('SI Activation Failed:', error.message);
//     throw error;
//   }
// }

// activateStandingInstruction('md_87c381eb-46a9-4936-b05b-7403d02f8758');


// // const pdclient = new PayPdGlocalClient(config);

///jwt payment methods//////

// const client 


























// async function createJwtPayment() {
//   try {
//     const response = await client.initiateJwtPayment(



// {
//   "merchantTxnId": "1756728697873338303",
//   "captureTxn": false,
//   "paymentData": {
//     "totalAmount": "117800.00",
//     "txnCurrency": "INR"
//   },
//   "riskData": {
//     "flightData": [
//       {
//         "journeyType": "ONEWAY",
//         "reservationDate": "20250901",
//         "legData": [
//           {
//             "routeId": "1",
//             "legId": "1",
//             "flightNumber": "BA112",
//             "departureAirportCode": "BLR",
//             "departureCity": "Bengaluru",
//             "departureDate": "2025-09-01T03:45:00Z",
//             "arrivalAirportCode": "LAX",
//             "arrivalCity": "Los Angeles",
//             "arrivalDate": "2025-09-01T13:15:00Z",
//             "carrierCode": "B7",
//             "serviceClass": "ECONOMY"
//           }
//         ],
//         "passengerData": [
//           {
//             "firstName": "Sam",
//             "lastName": "Thomas"
//           }
//         ]
//       }
//     ]
//   },
//   "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// }


// {
//   "merchantTxnId": "TXN123456789",
//   // "merchantUniqueId": "MUID987654321",
//   "merchantCallbackURL": "https://merchant.example.com/callback",
//   "captureTxn": true,
//   "gpiTxnTimeout": "300",
//   "paymentData": {

//     "totalAmount": "1500.00",
//     "txnCurrency": "INR",
//     "cardData": {
//       "number": "4111111111111111",
//       "expiryMonth": "12",
//       "expiryYear": "2026",
//       "securityCode": "123",
//       "type": "VISA"
//     },
//     "billingData": {
//       "fullName": "Rahul Sharma",
//       "firstName": "Rahul",
//       "lastName": "Sharma",
//       "addressStreet1": "123 MG Road",
//       "addressStreet2": null,
//       "addressCity": "Bengaluru",
//       "addressState": "Karnataka",
//       "addressStateCode": "KA",
//       "addressPostalCode": "560001",
//       "addressCountry": "IN",
//       "emailId": "rahul.sharma@example.com",
//       "callingCode": "+91",
//       "phoneNumber": "9876543210",
//       "panNumber": "ABCDE1234F"
//     }
//   },

// "orderData": [
//   {
//     "productDescription": "Flight from Delhi to Goa",
//     "productSKU": "FL123",
//     "productType": "Flight",
//     "itemUnitPrice": "1500.00",
//     "itemQuantity": "1"
//   }
// ],

//   "riskData": {

//     "customerData": {
//       "customerAccountType": "REGISTERED",
//       "customerSuccessOrderCount": "10",
//       "customerAccountCreationDate": "2021-01-15T10:00:00Z",
//       "merchantAssignedCustomerId": "CUST1001"
//     },
//     "shippingData": {
//       "fullName": "Rahul Sharma",
//       "firstName": "Rahul",
//       "lastName": "Sharma",
//       "addressStreet1": "123 MG Road",
//       "addressStreet2": null,
//       "addressCity": "Bengaluru",
//       "addressState": "Karnataka",
//       "addressStateCode": "KA",
//       "addressPostalCode": "560001",
//       "addressCountry": "IN",
//       "emailId": "rahul.sharma@example.com",
//       "callingCode": "+91",
//       "phoneNumber": "9876543210"
//     },
//     "flightData": [
//       {
//         "agentCode": "AGT123",
//         "agentName": "Best Travels",
//         "ticketNumber": "TCK987654321",
//         // "reservationDate": "2023-03-18T09:01:56Z",
//         "ticketIssueCity": "Delhi",
//         "ticketIssueState": "Delhi",
//         "ticketIssueCountry": "IN",
//         "ticketIssuePostalCode": "110001",
//         "reservationCode": "123456",
//         "reservationSystem": "Amadeus",
//         "journeyType": "ONEWAY",
//         "electronicTicket": "Y",
//         "refundable": "N",
//         "ticketType": "E-Ticket",
//         "legData": [
//           {
//             "routeId": "1",
//             "legId": "1",
//             "flightNumber": "AI202",
//             "departureDate": "2023-03-20T09:01:56Z",
//             "departureAirportCode": "DEL",
//             "departureCity": "Delhi",
//             "departureCountry": "IN",
//             "arrivalDate": "2023-03-20T11:15:00Z",
//             "arrivalAirportCode": "GOI",
//             "arrivalCity": "Goa",
//             "arrivalCountry": "IN",
//             "carrierCode": "AI",
//             "carrierName": "Air India",
//             "serviceClass": "Economy"
//           }
//         ],
//         "passengerData": [
//           {
//             "title": "Mr",
//             "firstName": "Rahul",
//             "lastName": "Sharma",
//             // "dateOfBirth": "1990-05-10T00:00:00Z",
//             "type": "ADT",
//             "email": "rahul.sharma@example.com",
//             "passportNumber": "P1234567",
//             "passportCountry": "IN",
//             // "passportIssueDate": "2015-01-01T00:00:00Z",
//             // "passportExpiryDate": "2025-01-01T00:00:00Z",
//             "referenceNumber": "PAX001"
//           }
//         ]
//       }
//     ]
//   }
// }


//        {
//         "merchantTxnId": "23AEE8CB6B62EE2AF07",
//         // "merchantUniqueId": "IFNN939494NJFJ",
//         "selectedPaymentMethod": {
//           "iso2CountryCode": "DE",
//           "methodName": "SOFORT" // Send exact value as received in response of the Get Method Service
//         },
//         "paymentData": {
//           "totalAmount": "300.00", // Minimum amount for Global Alt-Pay is INR 300 (or equivalent)
//           "txnCurrency": "INR", // Currencies supported for Global Alt-Pay are INR, AUD, AED, USD, SGD, NZD, EUR, GBP, and CAD
//           "billingData": {
//             "firstName": "John",
//             "lastName": "Denver",
//             "addressStreet1": "Rowdy Street 1", // Mandatory for Services Goods Export
//             "addressStreet2": "Rowdy Street 2",
//             "addressCity": "Stadt", // Mandatory for Digital Goods/ Services Goods Export
//             "addressState": "Berlin", // Mandatory for Digital Goods/ Services Goods Export
//             "addressPostalCode": "10274", // Mandatory for Digital Goods/ Services Goods Export
//             "addressCountry": "DE", // Mandatory for Digital Goods/ Services Goods Export
//             "emailId": "johndenver@myemail.com", // Mandatory for Digital Goods/ Services Export
//             "callingCode": "+91",
//             "phoneNumber": "9008018469" // Mandatory for Digital Goods/ Services Export
//           }
//         },
//         "riskData": {
//           "shippingData": {
//             "firstName": "John",
//             "lastName": "Denver",
//             "addressStreet1": "Rowdy Street 1", // Mandatory for Physical Goods Export
//             "addressStreet2": "Rowdy Street 2",
//             "addressCity": "Stadt", // Mandatory for Physical Goods Export
//             "addressState": "Berlin", // Mandatory for Physical Goods Export
//             "addressPostalCode": "10274", // Mandatory for Physical Goods Export
//             "addressCountry": "DE", // Mandatory for Physical Goods Export
//             "emailId": "johndenver@myemail.com",
//             "callingCode": "+91",
//             "phoneNumber": "9008018469"
//           }
//         },
//         "merchantCallbackURL": "https://www.merchanturl.com/callback"
//       }







//   );

//     console.log(' response received Successfully');
//     console.log('Resonse:', response);
//     return response;
//   } catch (error) {
//     // Print concise PayGlocal error if available, do not rethrow to avoid duplicate stacks
//     console.error(error && error.message ? error.message : 'Request failed');
//     return { error: true, message: error && error.message ? error.message : 'Request failed' };
//   }
// }

// createJwtPayment();

// // api key based payment method

// async function createApiKeyPayment() {
//   try {
//     const response = await client.initiateApiKeyPayment({
//       merchantTxnId: 'TXN_' + Date.now(),
//       paymentData: {
//         totalAmount: '500.00',
//         txnCurrency: 'INR',
//         billingData: {
//           emailId: 'customer@example.com'
//         }
//       },
//       merchantCallbackURL: 'https://your-domain.com/payment/callback'
//     });

//     console.log(' response received Successfully');
//     console.log('Resonse:', response);
//     return response;
//   } catch (error) {
//     console.error('Error: Response not received:', error.message);
//     throw error;
//   }
// }


// // createApiKeyPayment();


// async function createSiPayment() {
//   try {
//     const response = await client.initiateSiPayment({
//       merchantTxnId: 'SI_TXN_' + Date.now(),
//       paymentData: {
//         totalAmount: '1000.00',
//         txnCurrency: 'INR',
//         billingData: {
//           emailId: 'customer@example.com'
//         }
//       },
//       standingInstruction: {
//         data: {
//           numberOfPayments: '12',
//           frequency: 'MONTHLY',
//           type: 'FIXED',
//           amount: '1000.00',
//           startDate: '2025-09-01'
//         }
//       },
//       merchantCallbackURL: 'https://your-domain.com/payment/callback'
//     });

//     console.log('SI Payment Created');
//     console.log('response:', response);


//     return response;
//   } catch (error) {
//     console.error('SI Payment Failed:', error.message);
//     throw error;
//   }
// }

// // createSiPayment();


// // // Auth payment method
// async function createAuthPayment() {
//   try {
//     const response = await client.initiateAuthPayment(
//       // {
//       //   "merchantTxnId": "1756728697873338303",
//       //   "captureTxn": false,
//       //   "paymentData": {
//       //     "totalAmount": "117800.00",
//       //     "txnCurrency": "INR"
//       //   },
//       //   "riskData": {
//           // "trainData": [
//           //   {
//           //     "ticketNumber": "ticket12346",
//           //     "reservationDate": "20230220",
//           //     "legData": [
//           //       {
//           //         "routeId": "1",
//           //         "legId": "1",
//           //         "trainNumber": "train123",
//           //         "departureCity": "Kannur",
//           //         "departureCountry": "IN",
//           //         "departureDate": "2023-03-20T09:01:56Z",
//           //         "arrivalCity": "Coimbatore",
//           //         "arrivalCountry": "IN",
//           //         "arrivalDate": "2023-03-21T09:01:56Z"
//           //       }
//           //     ],
//           //     "passengerData": [
//           //       {
//           //         "firstName": "Sam",
//           //         "lastName": "Thomas",
//           //         "dateOfBirth": "19980320",
//           //         "passportCountry": "IN"
//           //       }
//           //     ]
//           //   }
//           // ]
//       //   },
//       //   "merchantCallbackURL": "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
//       // }



//       {
//         "merchantTxnId": "TXN123456789",
//         "merchantCallbackURL": "https://merchant.com/callback",
//         "captureTxn": true,
//         "gpiTxnTimeout": "30",
//         "paymentData": {
//           "totalAmount": "1000.00",
//           "txnCurrency": "INR",
//           "cardData": {
//             "number": "4111111111111111",
//             "expiryMonth": "12",
//             "expiryYear": "2026",
//             "securityCode": "123",
//             "type": "VISA"
//           },
//           "billingData": {
//             "fullName": "Ravi Kumar",
//             "firstName": "Ravi",
//             "lastName": "Kumar",
//             "addressStreet1": "MG Road",
//             "addressStreet2": "Suite 10",
//             "addressCity": "Bengaluru",
//             "addressState": "Karnataka",
//             "addressStateCode": "KA",
//             "addressPostalCode": "560001",
//             "addressCountry": "IN",
//             "emailId": "ravi.kumar@example.com",
//             "callingCode": "+91",
//             "phoneNumber": "9876543210",
//             "panNumber": "ABCDE1234F"
//           }
//         },
//         "riskData": {
//           "orderData": [
//             {
//               "productDescription": "Flight Ticket",
//               "productSKU": "FL123",
//               "productType": "Flight",
//               "itemUnitPrice": "1000.00",
//               "itemQuantity": "1"
//             }
//           ],
//           "customerData": {
//             "customerAccountType": "Registered",
//             "customerSuccessOrderCount": "5",
//             "customerAccountCreationDate": "2022-01-10T00:00:00Z",
//             "merchantAssignedCustomerId": "CUST12345"
//           },
//           "shippingData": {
//             "fullName": "Ravi Kumar",
//             "firstName": "Ravi",
//             "lastName": "Kumar",
//             "addressStreet1": "MG Road",
//             "addressStreet2": "Suite 10",
//             "addressCity": "Bengaluru",
//             "addressState": "Karnataka",
//             "addressStateCode": "KA",
//             "addressPostalCode": "560001",
//             "addressCountry": "IN",
//             "emailId": "ravi.kumar@example.com",
//             "callingCode": "+91",
//             "phoneNumber": "9876543210"
//           },
//           "flightData": [
//             {
//               "agentCode": "AG001",
//               "agentName": "TravelWorld",
//               "ticketNumber": "0987654321",
//               "reservationDate": "2023-03-15T10:00:00Z",
//               "ticketIssueCity": "Delhi",
//               "ticketIssueState": "Delhi",
//               "ticketIssueCountry": "IN",
//               "ticketIssuePostalCode": "110001",
//               "reservationCode": "PNR12345",
//               "reservationSystem": "Amadeus",
//               "journeyType": "OneWay",
//               "electronicTicket": "true",
//               "refundable": "true",
//               "ticketType": "E-Ticket",
//               "legData": [
//                 {
//                   "routeId": "101",
//                   "legId": "1",
//                   "flightNumber": "AI202",
//                   "departureDate": "2023-03-20T09:01:56Z",
//                   "departureAirportCode": "DEL",
//                   "departureCity": "Delhi",
//                   "departureCountry": "IN",
//                   "arrivalDate": "2023-03-20T11:30:00Z",
//                   "arrivalAirportCode": "BOM",
//                   "arrivalCity": "Mumbai",
//                   "arrivalCountry": "IN",
//                   "carrierCode": "AI",
//                   "carrierName": "Air India",
//                   "serviceClass": "Economy"
//                 }
//               ],
//               "passengerData": [
//                 {
//                   "title": "Mr",
//                   "firstName": "Ravi",
//                   "lastName": "Kumar",
//                   "dateOfBirth": "1990-01-01T00:00:00Z",
//                   "type": "ADT",
//                   "email": "ravi.kumar@example.com",
//                   "passportNumber": "N1234567",
//                   "passportCountry": "IN",
//                   "passportIssueDate": "2015-01-01T00:00:00Z",
//                   "passportExpiryDate": "2025-01-01T00:00:00Z",
//                   "referenceNumber": "PAX001"
//                 }
//               ]
//             }
//           ]
//         }
//       }









//   );

//     console.log('Auth Payment Created');
//     console.log('response:', response);


//     return response;
//   } catch (error) {
//     console.error('Auth Payment Failed:', error.message);
//     throw error;
//   }
// }

// createAuthPayment();


// // transection service methods


// //check status method
// async function checkPaymentStatus(gid) {
//   try {
//     const response = await client.initiateCheckStatus({ gid });


//     console.log('Status Retrieved');
//     console.log('Status:', response.status);
//     console.log('GID:', response.gid);
//     console.log('Message:', response.message);

//     console.log('Raw Response:', response);

//     return response;
//   } catch (error) {
//     console.error('Status Check Failed:', error.message);
//     throw error;
//   }
// }
// // checkPaymentStatus('gl_o-96b659ad9445b2b15ov40RMX2');


// //check refund method

// async function refundPayment(gid, amount = null) {
//   try {
//     const response = await client.initiateRefund({
//       gid: gid,
//       merchantTxnId: 'REFUND_' + Date.now(),
//       refundType: amount ? 'P' : 'F', // P = Partial, F = Full
//       paymentData: amount ? { totalAmount: amount } : undefined
//     });

//     console.log('Payment Refunded');
//     console.log('Status:', response.status);
//     console.log('raw response:', response);
//     return response;
//   } catch (error) {
//     console.error('Refund Failed:', error.message);
//     throw error;
//   }
// }

// // refundPayment(); // Replace with actual GID and amount for partial refund


// async function reverseAuth(gid) {
//   try {
//     const response = await client.initiateAuthReversal({
//       gid: gid,
//       merchantTxnId: 'REVERSAL_' + Date.now()
//     });

//     console.log( 'Auth Reversed');
//     console.log('Status:', response.status);
//     console.log('response:', response);

//     return response;
//   } catch (error) {
//     console.error('Auth Reversal Failed:', error.message);
//     throw error;
//   }
// }

// // reverseAuth("gl_o-9628ffff042675e9b30Yyv7X2"); // Replace with actual GID




// // si service methods

// // si pause method(IMPORTANT: This method is used to pause the standing instruction, it can be used to pause the SI for a specific date or indefinitely. If you want to pause the SI for a specific date, you can pass the startDate parameter, otherwise you can leave it empty to pause indefinitely.)

// // async function pauseStandingInstruction(mandateId, startDate) {
// //   try {
// //     const response = await client.initiatePauseSI({
// //       merchantTxnId: 'PAUSE_SI_' + Date.now(),
// //       if(startDate){
// //          standingInstruction: {
// //         action: 'PAUSE',
// //         mandateId: mandateId,
// //       }}else{
// //              standingInstruction: {
// //         action: 'PAUSE',
// //         mandateId: mandateId,
// //         data: {
// //           startDate: startDate // Optional, if you want to specify a pause start date
// //       }

// //       }
// //     });

// //     console.log('SI Paused');
// //     console.log('Status:', response.status);
// //     console.log('Mandate ID:', response.mandateId);
// //     console.log('Raw Response:', response);
// //     return response;
// //   } catch (error) {
// //     console.error('SI Pause Failed:', error.message);
// //     throw error;
// //   }
// // }


// async function pauseStandingInstruction(mandateId, startDate) {
//   try {
//     const standingInstruction = {
//       action: 'PAUSE',
//       mandateId
//     };

//     if (startDate) {
//       standingInstruction.data = { startDate };
//     }

//     const response = await client.initiatePauseSI({
//       merchantTxnId: 'PAUSE_SI_' + Date.now(),
//       standingInstruction
//     });

//     console.log('SI Paused');
//     console.log('Status:', response.status);
//     console.log('Raw Response:', response);
//     return response;
//   } catch (error) {
//     console.error('SI Pause Failed:', error.message);
//     throw error;
//   }
// }

// // pauseStandingInstruction("md_87c381eb-46a9-4936-b05b-7403d02f8758", '20250901'); // Replace with actual Mandate ID and start date


// async function activateStandingInstruction(mandateId) {
//   try {
//     const response = await client.initiateActivateSI({
//       merchantTxnId: 'ACTIVATE_SI_' + Date.now(),
//       standingInstruction: {
//         action: 'ACTIVATE',
//         mandateId: mandateId
//       }
//     });

//     console.log('SI Activated');
//     console.log('Status:', response.status);
//     console.log('Raw Response:', response);
//     return response;
//   } catch (error) {
//     console.error('SI Activation Failed:', error.message);
//     throw error;
//   }
// }

// activateStandingInstruction('md_87c381eb-46a9-4936-b05b-7403d02f8758');


// // const pdclient = new PayPdGlocalClient(config);

///jwt payment methods//////

// const client 





////////////////8*****************************************8////////////////





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




