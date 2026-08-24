/**
 * A MERCHANT INTEGRATION of the simple PayGlocal SDK.
 *
 * The point of this file is to be the smallest thing that could possibly work,
 * so that it answers one question honestly: can a merchant drop the SDK in and
 * be done? Everything payment-related is the SDK's own code. Nothing here
 * reformats a payload, builds a redirect, decodes a token, or decides what a
 * status means.
 *
 * In particular:
 *
 *   - the callback route IS the SDK's handleCallback, unmodified
 *   - the webhook route IS the SDK's handleWebhook, unmodified
 *   - initiate() is given a payload and nothing else; it fills in
 *     merchantCallbackURL from the SDK's own config
 *   - every URL comes from the SDK's own PAYGLOCAL_* environment variables
 *
 * If something does not work, that is a finding about the SDK, which is the
 * whole reason for wiring it this way. An earlier version of this file papered
 * over the rough edges and, in doing so, tested itself rather than the SDK.
 *
 * The only non-merchant thing here is the dynamic import: the SDK is ESM and
 * this backend is CommonJS. A merchant on ESM writes a plain `import`.
 */

const path = require('path');

const SDK_DIR = path.join(__dirname, 'payglocal-sdk-simple', 'payglocal');

let sdkPromise = null;

/** Loads the ESM SDK once. The `import()` is the CommonJS tax, nothing more. */
function loadSdk() {
  if (sdkPromise) return sdkPromise;

  sdkPromise = (async () => {
    const [config, initiate, status, callback, webhook] = await Promise.all([
      import(`file://${path.join(SDK_DIR, 'config.js')}`),
      import(`file://${path.join(SDK_DIR, 'initiate.js')}`),
      import(`file://${path.join(SDK_DIR, 'status.js')}`),
      import(`file://${path.join(SDK_DIR, 'callback.js')}`),
      import(`file://${path.join(SDK_DIR, 'webhook.js')}`),
    ]);

    return {
      config: config.config,
      initiate: initiate.initiate,
      checkStatus: status.checkStatus,
      handleCallback: callback.handleCallback,
      handleWebhook: webhook.handleWebhook,
    };
  })().catch((error) => {
    sdkPromise = null; // let the next request retry
    throw error;
  });

  return sdkPromise;
}

/** The SDK throws one error type, carrying a code and a readable message. */
function sendError(res, error) {
  console.error(`[sdk-simple] ${error.code || 'ERROR'}: ${error.message}`);
  return res.status(error.code === 'API_ERROR' ? 502 : 500).json({
    status: 'error',
    code: error.code || 'SDK_SIMPLE_ERROR',
    message: error.message,
    reasonCode: error.reasonCode,
  });
}

function register(app) {
  /**
   * Not part of a merchant integration. This exists so a failed deployment can
   * say why on the first request instead of failing silently. It reports the
   * SDK's resolved configuration, including the four URLs, so it is also the
   * quickest way to see whether the environment variables took effect.
   */
  app.get('/api/sdk-simple/health', async (req, res) => {
    try {
      const { config } = await loadSdk();
      return res.status(200).json({
        status: 'ok',
        sdk: 'payglocal-sdk-simple',
        environment: config.environment,
        merchantId: config.merchantId,
        publicKeyId: config.publicKeyId,
        privateKeyId: config.privateKeyId,
        keysFrom: config.payglocalPublicKeyPem ? 'environment' : 'files',
        // The four URLs the SDK will actually use, straight from its config.
        callbackUrl: config.callbackUrl,
        webhookUrl: config.webhookUrl,
        successUrl: config.successUrl,
        failureUrl: config.failureUrl,
      });
    } catch (error) {
      return sendError(res, error);
    }
  });

  /**
   * Start a payment.
   *
   * The payload is built the way payloads.js documents, then handed over. No
   * merchantCallbackURL is passed: initiate() fills that from config.callbackUrl
   * so the value cannot drift from the route actually served.
   */
  app.post('/api/sdk-simple/initiate', async (req, res) => {
    try {
      const { initiate } = await loadSdk();

      const {
        amount = '10.00',
        currency = 'INR',
        email = 'test.customer@example.com',
        firstName = 'Test',
        lastName = 'Customer',
      } = req.body || {};

      const merchantTxnId = req.body?.merchantTxnId || `SDKSIMPLE-${Date.now()}`;

      const payment = await initiate({
        merchantTxnId,
        paymentData: {
          totalAmount: String(amount),
          txnCurrency: currency,
          billingData: {
            firstName,
            lastName,
            addressStreet1: '12 MG Road',
            addressCity: 'Bengaluru',
            addressState: 'Karnataka',
            addressPostalCode: '560038',
            addressCountry: 'IN',
            emailId: email,
          },
        },
      });

      // A real merchant saves payment.transactionId on the order row here,
      // before redirecting, since it is the only way to look the payment up.
      console.log(`[sdk-simple] initiate ${merchantTxnId} -> ${payment.transactionId}`);

      return res.status(200).json({
        status: 'SUCCESS',
        payment_link: payment.paymentUrl,
        transactionId: payment.transactionId,
        merchantTxnId,
        raw_response: payment.raw,
      });
    } catch (error) {
      return sendError(res, error);
    }
  });

  /** Ask PayGlocal what happened to a payment. Straight passthrough. */
  app.get('/api/sdk-simple/status', async (req, res) => {
    try {
      const transactionId = req.query.gid || req.query.transactionId;
      if (!transactionId) {
        return res.status(400).json({
          status: 'error',
          code: 'MISSING_FIELD',
          message: 'Pass the transaction id as ?gid=... (the value initiate returned).',
        });
      }

      const { checkStatus } = await loadSdk();
      const payment = await checkStatus(String(transactionId));

      console.log(`[sdk-simple] status ${transactionId} -> ${payment.result}`);
      return res.status(200).json(payment);
    } catch (error) {
      return sendError(res, error);
    }
  });

  // ---------------------------------------------------------------------------
  // The callback and the webhook are the SDK's own handlers, mounted as-is.
  //
  // This is the entire integration for both. handleCallback reads the token and
  // redirects to config.successUrl or config.failureUrl. handleWebhook reads the
  // event and calls the merchant section inside webhook.js.
  // ---------------------------------------------------------------------------

  const withSdk = (pick) => async (req, res) => {
    let handler;
    try {
      handler = pick(await loadSdk());
    } catch (error) {
      return sendError(res, error);
    }
    return handler(req, res);
  };

  app.post('/api/sdk-simple/callback', withSdk((sdk) => sdk.handleCallback));
  app.get('/api/sdk-simple/callback', withSdk((sdk) => sdk.handleCallback));

  app.post('/api/sdk-simple/webhook', withSdk((sdk) => sdk.handleWebhook));

  console.log('[sdk-simple] routes registered at /api/sdk-simple/*');
}

module.exports = { register };
