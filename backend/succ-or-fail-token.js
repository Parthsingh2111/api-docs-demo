// import express from 'express';
// import crypto from 'crypto';

// const app = express();
// app.use(express.json());


// app.post('callbackurl', async (req, res) => {
//   try {
//     const { token } = req.body;
//     if (!token) return res.status(400).json({ error: 'Missing token in callback' });

//     const decodedString = Buffer.from(token, 'base64').toString('utf-8');
//     const decodedResponse = JSON.parse(decodedString);

//     const status = decodedResponse?.status || decodedResponse?.txnStatus;
//     const merchantTxnId = decodedResponse?.merchantTxnId;
//     const gid = decodedResponse?.gid;

//     if (status === 'SENT_FOR_CAPTURE') {
//       return res.redirect(`https://pg-dynamic-docs.com/payment-success?txnId=${merchantTxnId}&gid=${gid}`);// sucess page
//     } else {
//       return res.redirect(`https://pg-dynamic-docs.com/payment-failed?txnId=${merchantTxnId}&gid=${gid}`);// failure page
//     }
//   } catch (error) {
//     return res.status(500).json({ error: 'Callback processing failed' });
//   }
// });


import express from 'express';
import crypto from 'crypto';

const app = express();
app.use(express.json());

app.post('/callbackurl', async (req, res) => {
  try {
    // PayGlocal sends token in header
    const token = req.body['x-gl-token'];
    if (!token) return res.status(400).json({ error: 'Missing x-gl-token header' });

    // Decode base64 token
    const decodedString = Buffer.from(token, 'base64').toString('utf-8');
    const decodedResponse = JSON.parse(decodedString);

    const status = decodedResponse?.status || decodedResponse?.txnStatus;
    const merchantTxnId = decodedResponse?.merchantTxnId;
    const gid = decodedResponse?.gid;

    // Redirect merchant to success/failure pages
    if (status === 'SENT_FOR_CAPTURE') {
      return res.redirect(`https://pg-dynamic-docs.com/payment-success?txnId=${merchantTxnId}&gid=${gid}`);
    } else {
      return res.redirect(`https://pg-dynamic-docs.com/payment-failed?txnId=${merchantTxnId}&gid=${gid}`);
    }

  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'Callback processing failed' });
  }
});
