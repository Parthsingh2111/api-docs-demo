/**
 * Routes for the "simple" PayGlocal SDK, the one vendored in
 * ./payglocal-sdk-simple/payglocal/.
 *
 * These sit alongside the existing /api/pay/* routes rather than replacing
 * them. The point is to exercise the new SDK from the Flutter app against the
 * same UAT credentials the rest of the backend already uses, so the two can be
 * compared side by side.
 *
 * Two things make this file necessary rather than importing the SDK directly:
 *
 *   1. The SDK is ESM, this backend is CommonJS. So it is pulled in with a
 *      dynamic import(), once, and cached.
 *   2. The SDK reads PAYGLOCAL_PUBLIC_KEY_PATH and PAYGLOCAL_ENVIRONMENT. This
 *      project has always called those PAYGLOCAL_PUBLIC_KEY and
 *      PAYGLOCAL_Env_VAR. Rather than fork the SDK, the names are mapped here,
 *      which keeps the vendored copy byte-identical to the one we hand to
 *      merchants.
 */

const path = require('path');

const SDK_DIR = path.join(__dirname, 'payglocal-sdk-simple', 'payglocal');

/** Resolved once and reused; the SDK caches its own parsed keys internally. */
let sdkPromise = null;

/**
 * Loads the SDK and points its config at this project's environment variables.
 *
 * `config` is a plain exported object, so assigning to it is the documented way
 * to configure the SDK from code. Only the values this project names
 * differently are touched; everything else the SDK reads for itself.
 */
function loadSdk() {
  if (sdkPromise) return sdkPromise;

  sdkPromise = (async () => {
    const [configModule, initiateModule, statusModule, callbackModule, webhookModule] =
      await Promise.all([
        import(`file://${path.join(SDK_DIR, 'config.js')}`),
        import(`file://${path.join(SDK_DIR, 'initiate.js')}`),
        import(`file://${path.join(SDK_DIR, 'status.js')}`),
        import(`file://${path.join(SDK_DIR, 'callback.js')}`),
        import(`file://${path.join(SDK_DIR, 'webhook.js')}`),
      ]);

    const { config } = configModule;

    // 'UAT' / 'PROD' is how this project has always spelled it.
    if (!process.env.PAYGLOCAL_ENVIRONMENT && process.env.PAYGLOCAL_Env_VAR) {
      const declared = process.env.PAYGLOCAL_Env_VAR.trim().toLowerCase();
      config.environment = declared === 'prod' || declared === 'production'
        ? 'production'
        : 'uat';
    }

    // On Vercel the keys arrive as PEM content in the environment; locally they
    // are file paths. The SDK supports both, under its own names.
    if (!process.env.PAYGLOCAL_PUBLIC_KEY_CONTENT && process.env.PAYGLOCAL_PUBLIC_KEY) {
      config.payglocalPublicKeyFile = path.resolve(__dirname, process.env.PAYGLOCAL_PUBLIC_KEY);
    }
    if (!process.env.PAYGLOCAL_PRIVATE_KEY_CONTENT && process.env.PAYGLOCAL_PRIVATE_KEY) {
      config.merchantPrivateKeyFile = path.resolve(__dirname, process.env.PAYGLOCAL_PRIVATE_KEY);
    }

    config.debug = true;

    console.log('[sdk-simple] loaded', {
      environment: config.environment,
      merchantId: config.merchantId,
      keysFrom: config.payglocalPublicKeyPem ? 'environment' : 'files',
    });

    return {
      config,
      initiate: initiateModule.initiate,
      checkStatus: statusModule.checkStatus,
      readCallback: callbackModule.readCallback,
      readWebhook: webhookModule.readWebhook,
    };
  })().catch((error) => {
    // Do not cache a failed load; the next request should try again.
    sdkPromise = null;
    throw error;
  });

  return sdkPromise;
}

/**
 * The origin this request arrived on, so callback URLs work unchanged on
 * localhost, on a Vercel preview and in production without being configured
 * three times.
 */
function originOf(req) {
  const forwardedProto = req.headers['x-forwarded-proto'];
  const forwardedHost = req.headers['x-forwarded-host'];
  const host = forwardedHost || req.headers.host || 'localhost:3000';
  const protocol = forwardedProto || (host.startsWith('localhost') ? 'http' : 'https');
  return `${String(protocol).split(',')[0]}://${String(host).split(',')[0]}`;
}

/**
 * Where the Flutter app is served, which is not always where this backend is.
 *
 * Deployed, one origin serves both, so the request's own origin is right.
 * Locally the app is a separate static server on :8080 while this runs on
 * :3000, which is the same split the existing /callbackurl route assumes.
 */
function appOriginOf(req) {
  if (process.env.APP_BASE_URL) return process.env.APP_BASE_URL.replace(/\/$/, '');
  if (process.env.VERCEL || process.env.VERCEL_ENV) return originOf(req);
  return 'http://localhost:8080';
}

/**
 * The app routes on the fragment, so a redirect has to carry the "#" or the
 * app boots at its home screen and the payment result is lost.
 */
function appUrl(req, route, params) {
  const query = new URLSearchParams(
    Object.entries(params).filter(([, value]) => value != null && value !== '')
  ).toString();
  return `${appOriginOf(req)}/#${route}${query ? `?${query}` : ''}`;
}

/** PayGlocal errors carry a code and a readable message; pass both through. */
function sendError(res, error) {
  const status = error.code === 'API_ERROR' ? 502 : 500;
  console.error(`[sdk-simple] ${error.code || 'ERROR'}: ${error.message}`);
  return res.status(status).json({
    status: 'error',
    code: error.code || 'SDK_SIMPLE_ERROR',
    message: error.message,
    reasonCode: error.reasonCode,
  });
}

function register(app) {
  /**
   * Whether the SDK can load and what it thinks it is configured with. No
   * secrets: key ids are the public half of the credential pair, and the PEMs
   * are reported only as present or absent.
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
        hasPublicKey: Boolean(config.payglocalPublicKeyPem || config.payglocalPublicKeyFile),
        hasPrivateKey: Boolean(config.merchantPrivateKeyPem || config.merchantPrivateKeyFile),
        origin: originOf(req),
      });
    } catch (error) {
      return sendError(res, error);
    }
  });

  /**
   * Start a payment. Returns the URL to send the customer to.
   *
   * The response uses `payment_link` because that is what the existing
   * /api/pay/jwt route returns and the Flutter app already knows how to read.
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

      // Sent explicitly rather than left to config.js so the callback always
      // comes back to the deployment that started the payment.
      const merchantCallbackURL =
        req.body?.merchantCallbackURL || `${originOf(req)}/api/sdk-simple/callback`;

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
        merchantCallbackURL,
      });

      console.log(`[sdk-simple] initiate ${merchantTxnId} -> ${payment.transactionId}`);

      return res.status(200).json({
        status: 'SUCCESS',
        payment_link: payment.paymentUrl,
        transactionId: payment.transactionId,
        merchantTxnId,
        merchantCallbackURL,
        raw_response: payment.raw,
      });
    } catch (error) {
      return sendError(res, error);
    }
  });

  /** Ask PayGlocal what happened to a payment. */
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

      console.log(`[sdk-simple] status ${transactionId} -> ${payment.result} (${payment.status})`);
      return res.status(200).json(payment);
    } catch (error) {
      return sendError(res, error);
    }
  });

  /**
   * Where PayGlocal sends the customer's browser back.
   *
   * The SDK's own handleCallback would redirect to config.successUrl. This
   * builds the redirect instead, so the customer lands on the Flutter app's
   * own /payment-success or /payment-failure route with the fields those
   * screens read from the query string.
   *
   * Nothing is marked paid here. The callback only runs if the browser comes
   * back at all, and PayGlocal does not sign it. The webhook confirms payment.
   */
  const handleCallback = async (req, res) => {
    try {
      const { readCallback } = await loadSdk();

      const token =
        req.body?.['x-gl-token'] ||
        req.query?.['x-gl-token'] ||
        req.body?.token ||
        req.query?.token;

      const result = readCallback(token);
      console.log(`[sdk-simple] callback ${result.orderId} -> ${result.status}`);

      // The SDK reads `amount` and `gid`. Real PayGlocal callbacks have been
      // capitalising these (`Amount`), and the /callbackurl route in index.js
      // has read both spellings for as long as it has existed. Fall back the
      // same way, or the success screen shows a blank amount. Worth settling
      // with PayGlocal and fixing in the SDK rather than here.
      const raw = result.raw || {};
      const amount = result.amount ?? raw.Amount ?? raw.amount;
      const transactionId = result.transactionId ?? raw.gid ?? raw['x-gl-gid'];

      // Field names match what the app's success and failure screens read.
      if (result.paid) {
        return res.redirect(
          appUrl(req, '/payment-success', {
            txnId: result.orderId,
            gid: transactionId,
            amount,
            status: result.status,
          })
        );
      }

      return res.redirect(
        appUrl(req, '/payment-failure', {
          txnId: result.orderId,
          status: result.status,
          reason: result.status || 'Payment not completed',
        })
      );
    } catch (error) {
      console.error(`[sdk-simple] callback ${error.code}: ${error.message}`);
      return res.redirect(appUrl(req, '/payment-failure', { reason: error.message }));
    }
  };

  app.post('/api/sdk-simple/callback', handleCallback);
  app.get('/api/sdk-simple/callback', handleCallback);

  /**
   * Server-to-server payment events. This is what actually confirms a payment.
   *
   * PayGlocal has to be told this URL exists; they do not discover it. Until it
   * is registered nothing arrives here and every payment stays unconfirmed.
   *
   * There is no order database in this demo, so the event is logged rather than
   * written. A real integration puts its update where the log line is, and must
   * ignore IN_PROGRESS instead of treating it as a failure.
   */
  app.post('/api/sdk-simple/webhook', async (req, res) => {
    try {
      const { readWebhook } = await loadSdk();
      const payment = readWebhook(req.body);

      if (payment.result === 'IN_PROGRESS') {
        console.log(`[sdk-simple] webhook ${payment.orderId} still in progress (${payment.status})`);
        return res.status(200).json({ received: true });
      }

      console.log(
        `[sdk-simple] webhook ${payment.orderId} -> ${payment.result} ` +
          `${payment.amount} ${payment.currency} (${payment.transactionId})`
      );

      return res.status(200).json({ received: true, result: payment.result });
    } catch (error) {
      // A 4xx tells PayGlocal the body was unusable. A 5xx makes them retry,
      // which is what we would want if our own storage had failed.
      console.error(`[sdk-simple] webhook ${error.code}: ${error.message}`);
      return res.status(400).json({ status: 'error', code: error.code, message: error.message });
    }
  });

  console.log('[sdk-simple] routes registered at /api/sdk-simple/*');
}

module.exports = { register };
