/**
 * =============================================================================
 * 3. HANDLE THE CALLBACK  —  the customer coming back to your site
 * =============================================================================
 *
 * After paying, PayGlocal sends the customer's browser to your callbackUrl.
 * This file's only job is to work out where to send them next.
 *
 * Wire it up like this:
 *
 *   import { handleCallback } from './payglocal/callback.js';
 *
 *   app.post('/payglocal/callback', handleCallback);
 *   app.get('/payglocal/callback', handleCallback);   // if they hit cancel
 *
 * That is all. It reads PayGlocal's token, works out whether the payment
 * succeeded, and redirects to your successUrl or failureUrl from config.js.
 *
 *
 * ================================ IMPORTANT ==================================
 *
 * DO NOT mark orders paid here, and do not ship anything here.
 *
 * This only runs if the customer's browser comes back. If they close the tab,
 * lose signal, or their phone dies on the bank's screen, it never runs at all,
 * and PayGlocal does not retry it. Confirming payment is webhook.js's job.
 *
 * Also: PayGlocal does not sign this token, so anything in it could have been
 * faked by whoever is holding the browser. Use it to pick a page, nothing more.
 * Your success page should look the order up in your own database and show the
 * status you stored, rather than trusting what is in the URL.
 */

import { config, PAID_STATUS, PayGlocalError } from './config.js';

/**
 * Reads PayGlocal's callback token and returns the useful bits.
 *
 * Use this if you would rather write your own route, or if you are not on
 * Express. Everything you are likely to need:
 *
 *   {
 *     paid:          true / false
 *     status:        PayGlocal's own status text
 *     orderId:       your order id
 *     transactionId: PayGlocal's id
 *     amount:        '499.00'
 *     currency:      'INR'
 *     raw:           everything in the token
 *   }
 */
export function readCallback(token) {
  if (typeof token !== 'string' || token.split('.').length !== 3) {
    throw new PayGlocalError(
      'The callback token is missing or malformed. PayGlocal sends it as a form ' +
        'field called "x-gl-token".',
      'CALLBACK_INVALID'
    );
  }

  let data;
  try {
    data = JSON.parse(Buffer.from(token.split('.')[1], 'base64url').toString('utf8'));
  } catch {
    throw new PayGlocalError('The callback token could not be read.', 'CALLBACK_INVALID');
  }

  return {
    paid: data.status === PAID_STATUS,
    status: data.status,
    orderId: data.merchantTxnId,
    transactionId: data.gid,
    amount: data.amount,
    currency: data.currency,
    raw: data,
  };
}

/**
 * A ready-made route handler. Redirects the customer and nothing else.
 *
 *   app.post('/payglocal/callback', handleCallback);
 *   app.get('/payglocal/callback', handleCallback);
 */
export async function handleCallback(req, res) {
  let result;

  try {
    // PayGlocal posts the token as a form field. Some flows put it in the query.
    const token =
      req.body?.['x-gl-token'] ??
      req.query?.['x-gl-token'] ??
      (await readRawToken(req));

    result = readCallback(token);
  } catch (error) {
    // Never show a paying customer a stack trace. Send them to your failure
    // page; the webhook will still settle the order correctly.
    console.error(`[payglocal] callback: ${error.message}`);
    return res.redirect(config.failureUrl);
  }

  const target = new URL(result.paid ? config.successUrl : config.failureUrl);

  // Your order id, so your page can look the order up in your database.
  if (result.orderId) target.searchParams.set('orderId', result.orderId);
  if (!result.paid && result.status) target.searchParams.set('status', result.status);

  // Note: transactionId is deliberately NOT put in the URL. It is the key that
  // can query a payment, and URLs end up in browser history, referrer headers
  // and access logs.

  return res.redirect(target.toString());
}

/**
 * Fallback for when no body parser has run, so `handleCallback` works whether or
 * not you use express.json() / express.urlencoded().
 */
async function readRawToken(req) {
  if (req.readableEnded) return undefined;

  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const body = Buffer.concat(chunks).toString('utf8').trim();
  if (!body) return undefined;

  if (body.startsWith('{')) return JSON.parse(body)['x-gl-token'];
  return new URLSearchParams(body).get('x-gl-token') ?? undefined;
}
