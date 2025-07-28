
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const PayGlocalClient = require('./pg-client-sdk/dist/index.js');
const PayPdGlocalClient = require('./pgpd-client-sdk');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');


dotenv.config();
const port = process.env.PORT || 3000;

const app = express();

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

app.use(cors());
app.use(express.json());

function normalizePemKey(key) {
  return key
    .trim()
    .replace(/\r\n|\r/g, '\n') // Normalize line endings to \n
    .replace(/\n\s*\n/g, '\n') // Remove empty lines
    .replace(/[^\x00-\x7F]/g, ''); // Remove non-ASCII characters
}

// Read and normalize PEM key content
const payglocalPublicKey = normalizePemKey(fs.readFileSync(path.resolve(__dirname, process.env.PAYGLOCAL_PUBLIC_KEY), 'utf8'));
const merchantPrivateKey = normalizePemKey(fs.readFileSync(path.resolve(__dirname, process.env.PAYGLOCAL_PRIVATE_KEY), 'utf8'));

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
  baseUrl: process.env.PAYGLOCAL_BASE_URL,
  logLevel: process.env.PAYGLOCAL_LOG_LEVEL || 'debug'
};

const client = new PayGlocalClient(config);
const pdclient = new PayPdGlocalClient(config);

/////jwt payment methods//////

app.post('/api/pay/jwt', async (req, res) => {
  try {
      const { merchantTxnId, paymentData, merchantCallbackURL } = req.body;
      if (!merchantTxnId || !paymentData || !merchantCallbackURL) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

    const payload = {
      merchantTxnId,
      paymentData,
      merchantCallbackURL
    };


    // const payload = {
    //   "merchantTxnId": "123432456543",
    //   // "merchantUniqueId": "",
    //   "paymentData": {
    //     "totalAmount": "8000.00",
    //     "txnCurrency": "INR",
    //     "cardData": {
    //       "number": "4242424242424242",
    //       "expiryMonth": "12",
    //       "expiryYear": "2026",
    //       "type": "visa",
    //       "securityCode": "789"
    //     }
    //   },
    //   "riskData": {
    //     "lodgingData": {
    //       "checkInDate": "04092025",
    //       "checkOutDate": "09092025",
    //       "city": "Goa",
    //       "country": "IN",
    //       "lodgingType": "Hotel",
    //       "lodgingName": "Sunset Resort",
    //       "bookingPersonFirstName": "John",
    //       "bookingPersonLastName": "Bell",
    //       "bookingPersonEmailid": "joh.bell@goodmail.com",
    //       "bookingPersonPhoneNumber": "2011915716",
    //       "bookingPersonCallingCode": "+91",
    //       "rooms": [
    //         {
    //           "numberOfGuests": "2",
    //           "roomType": "Twin",
    //           "roomCategory": "Deluxe",
    //           "roomPrice": "4000",
    //           "numberOfNights": "2",
    //           "guestFirstName": "Ricky",
    //           "guestLastName": "Martin",
    //           "guestEmail": "ricky.martin@irock.com"
    //         }
    //       ]
    //     },
    //   },
    //   "merchantCallbackURL": "https://merchant.com/hotel-callback"
    // }

    //     "lodgingData": {
    // "checkInDate": "04092021",
    // "checkOutDate": "03092021",
    // "city": "New York",
    // "country": "USA",
    // "lodgingType": "Motel",
    // "lodgingName": "Lake view hotel",
    // "rating": "4",
    // "cancellationPolicy": "NC",
    // "bookingPersonFirstName": "John",
    // "bookingPersonLastName": "Bell",
    // "bookingPersonEmailid": "joh.bell@goodmail.com",
    // "bookingPersonPhoneNumber": "2011915716",
    // "bookingPersonCallingCode": "+1",
    // "rooms": [
    // {
    // "numberOfGuests": "2",
    // "roomType": "Twin",
    // "roomCategory": "Deluxe",
    // "numberOfNights": "2",
    // "roomPrice": "320",
    // "guestFirstName": "Ricky",
    // "guestLastName": "Martin",
    // "guestEmail": "ricky.martin@irock.com"
    // }
    // ]
    // },

    console.log('Initiating JWT payment with payload:', payload);

    let payment;
    if (payload.paymentData.cardData) {
      payment = await pdclient.initiateJwtPayment(payload);
    } else {
      payment = await client.initiateJwtPayment(payload);
    }


    console.log('Payment Link:', payment.paymentLink);
    console.log('GID:', payment.gid);

    res.status(200).json({
      message: 'Payment initiated successfully',
      payment_link: payment.paymentLink,
      gid: payment.gid
    });
  } catch (error) {
    console.error('Error initiating JWT payment:', error);
    return res.status(500).json({ error: 'Failed to initiate payment' });
  }
});



/////Standing Instruction payment methods//////

app.post('/api/pay/si', async (req, res) => {

  console.log('Received request to initiate SI payment');
  try {
    const { merchantTxnId, paymentData, merchantCallbackURL, standingInstruction } = req.body;
    if (!merchantTxnId || !paymentData || !merchantCallbackURL || !standingInstruction) {
      return res.status(400).json({ error: 'Missing required fields' });
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
      payment = await pdclient.initiateSiPayment(
        payload
      )
    } else {
      payment = await client.initiateSiPayment(
        payload
      );
    }

    console.log('Payment Link:', payment.paymentLink);

    res.status(200).json({
      message: 'Payment initiated successfully',
      payment_link: payment.paymentLink,
      gid: payment.gid
    });
  } catch (error) {
    console.error('Error initiating SI payment:', error);
    return res.status(500).json({ error: 'Failed to initiate payment' });
  }
});


// Auth payment methods/////

app.post('/api/pay/auth', async (req, res) => {
  console.log('Received request to initiate Auth payment');
  try {
    const { merchantTxnId, paymentData,captureTxn,riskData,merchantCallbackURL } = req.body;
    if (!merchantTxnId || !paymentData || !merchantCallbackURL) {
      return res.status(400).json({ error: 'Missing required fields' });
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
      payment = await pdclient.initiateAuthPayment(
        payload
      )
    } else {
      payment = await client.initiateAuthPayment(
        payload
      );
    }

    console.log('Payment Link:', payment.paymentLink);
    console.log('GID:', payment.gid);

    res.status(200).json({
      message: 'Payment initiated successfully',
      payment_link: payment.paymentLink,
      gid: payment.gid
    });
  } catch (error) {
    console.error('Error initiating Auth payment:', error);
    return res.status(500).json({ error: 'Failed to initiate payment' });
  }
});




// Refund service method//

app.post('/api/refund', async (req, res) => {
  console.log('>>> /api/refund endpoint hit');
  try {
    const { gid, refundType, paymentData } = req.body;
    console.log('Received refund request:', { gid, refundType, paymentData });

    if (!gid) {
      console.error('Missing gid');
      return res.status(400).json({ error: 'Missing gid' });
    }


    if (refundType === 'P' && (!paymentData || !paymentData.totalAmount)) {
      console.error('Missing paymentData.totalAmount for partial refund');
      return res.status(400).json({ error: 'Missing paymentData.totalAmount for partial refund' });
    }

    // const merchantTxnId = '23AEE8CB6B62EE2AF06'; // Hardcoded it since it can be used multiple type 

    const payload = refundType === 'F'
      ? { refundType: 'F', gid }
      : {
        refundType: 'P',
        paymentData: { totalAmount: paymentData.totalAmount },
        gid
      };

    console.log('payload', payload);

    const payment = await client.initiateRefund(
      payload
    );
    console.log('Payment Link:', payment.paymentLink);
    res.status(200).json({
      message: 'Payment initiated successfully',
      payment_link: payment.paymentLink,
      gid: payment.gid
    });
  } catch (error) {
    console.error('Error initiating initiateRefund payment:', error);
    return res.status(500).json({ error: 'Failed to initiate payment' });
  }
});


// Capture service method//

app.post('/api/cap', async (req, res) => {
  console.log('>>> /api/cap endpoint hit');
  merchantTxnId = "123456754"
  try {
    const { captureType, paymentData, merchantTxnId } = req.body;
    const { gid } = req.query;

    console.log('Received capture request:', { gid, captureType, paymentData, merchantTxnId });

    if (!gid) {
      console.error('Missing gid');
      return res.status(400).json({ error: 'Missing gid' });
    }

    if (!merchantTxnId) {
      console.error('Missing merchantTxnId');
      return res.status(400).json({ error: 'Missing merchantTxnId' });
    }

    if (captureType === 'P' && (!paymentData || !paymentData.totalAmount)) {
      console.error('Missing paymentData.totalAmount for partial capture');
      return res.status(400).json({ error: 'Missing paymentData.totalAmount for partial capture' });
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
    console.log('response:', payment);
    res.status(200).json({
      message: 'Payment initiated successfully',
      captureId: payment.captureId,
      gid: payment.gid,
      status: payment.status,
    });
  } catch (error) {
    console.error('Error initiating capture payment:', error);
    return res.status(500).json({ error: 'Failed to initiate payment' });
  }
});



// Auth Reversal service method //

app.post('/api/authreversal', async (req, res) => {
  console.log('>>> /api/authreversal endpoint hit');
  try {
    const { gid } = req.query;
    const { merchantTxnId } = req.body
    if (!gid) {
      console.error('Missing gid');
      return res.status(400).json({ error: 'Missing gid' });
    }

    const payload = { gid, merchantTxnId };
    const payment = await client.initiateAuthReversal(
      payload
    );
    console.log('response', payment);
    res.status(200).json({
      message: 'Payment initiated successfully',
      payment_link: payment.paymentLink,
      gid: payment.gid
    });
  } catch (error) {
    console.error('Error initiating auth reversal payment:', error);
    return res.status(500).json({ error: 'Failed to initiate payment' });
  }
});



// Check Status service method //


app.get('/api/status', async (req, res) => {
  console.log('>>> /api/status endpoint hit');
  try {
    const { gid } = req.query;
    console.log('Received refund request:', { gid });

    if (!gid) {
      console.error('Missing gid');
      return res.status(400).json({ error: 'Missing gid' });
    }

    const payload = gid;

    const payment = await client.initiateCheckStatus(
      payload
    );
    console.log('response', payment);
    res.status(200).json({
      message: 'Payment initiated successfully',
      payment_link: payment.paymentLink,
      gid: payment.gid
    });
  } catch (error) {
    console.error('Error initiating initiateRefund payment:', error);
    return res.status(500).json({ error: 'Failed to initiate payment' });
  }
});





// Pause/Activate service method //

app.post('/api/pauseActivate', async (req, res) => {
  console.log('Received request to initiate pause/activate SI');

  try {
    const { merchantTxnId, standingInstruction } = req.body;

    // Basic validations
    if (!merchantTxnId || !standingInstruction) {
      return res.status(400).json({ error: 'Missing merchantTxnId or standingInstruction' });
    }

    if (!standingInstruction.action || !standingInstruction.mandateId) {
      return res.status(400).json({ error: 'Missing action or mandateId in standingInstruction' });
    }

    const payload = {
      merchantTxnId,
      standingInstruction,
    };

    console.log('Initiating SI with payload:', payload);

    let response;
    const action = standingInstruction.action.toLowerCase();

    if (action === 'pause' || action === 'pausebydate') {
      response = await client.initiatePauseSI(payload);
    } else if (action === 'activate') {
      response = await client.initiateActivateSI(payload);
    } else {
      return res.status(400).json({ error: `Unsupported action: ${standingInstruction.action}` });
    }

    console.log('SI Response:', response);

    res.status(200).json({
      message: response.message || 'Standing instruction processed successfully',
      status: response.status || 'SUCCESS',
      mandateId: response.mandateId || standingInstruction.mandateId,
    });
  } catch (error) {
    console.error('Error initiating SI payment:', error.message);
    return res.status(500).json({ error: error.message || 'Failed to initiate SI payment' });
  }
});






