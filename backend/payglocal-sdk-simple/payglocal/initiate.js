/**
 * =============================================================================
 * 2. INITIATE A PAYMENT
 * =============================================================================
 *
 * You build the payload. This sends it.
 *
 *   import { initiate } from './payglocal/initiate.js';
 *
 *   const payload = { ... };          // see payloads.js for the structures
 *   const payment = await initiate(payload);
 *
 *   res.redirect(payment.paymentUrl);
 *
 *
 * WHAT THIS DOES
 *   - authenticates the request with your keys (signs it)
 *   - encrypts the payload for PayGlocal
 *   - sets the headers and picks the endpoint for your environment
 *   - sends it and hands you back the payment URL
 *
 * WHAT THIS DOES NOT DO
 *   Your payload is sent exactly as you wrote it. Nothing here inspects it,
 *   checks its shape, rebuilds it, picks a structure for you, or validates any
 *   field. If something is wrong with it, PayGlocal says so and you get their
 *   own reason code, which is more accurate than any guess made here.
 *
 * The only thing added is merchantCallbackURL, and only when you leave it out:
 * it then falls back to config.callbackUrl so the value cannot drift away from
 * the route you actually serve. Set it in the payload and yours is used.
 *
 *
 * ============================== WHAT YOU GET BACK ============================
 *
 *   {
 *     paymentUrl:    'https://...'   send the customer here
 *     transactionId: 'gl_o-...'      PayGlocal's id. SAVE IT on your order.
 *     raw:           { ... }         PayGlocal's untouched response
 *   }
 *
 * Save `transactionId` before you redirect. It is the only thing status.js can
 * look a payment up by, so an order without it can never be checked or repaired.
 */

import { config, endpoints, PayGlocalError, callPayGlocal } from './config.js';

/**
 * Sends a payment to PayGlocal.
 *
 * @param {object} payload  A PayGlocal payload. See payloads.js.
 * @returns {Promise<{paymentUrl: string, transactionId: string, raw: object}>}
 */
export async function initiate(payload) {
  const response = await callPayGlocal({
    method: 'POST',
    path: endpoints.initiate,
    payload: {
      ...payload,
      merchantCallbackURL: payload?.merchantCallbackURL ?? config.callbackUrl,
    },
  });

  const paymentUrl = response?.data?.redirectUrl;
  if (!paymentUrl) {
    throw new PayGlocalError(
      'PayGlocal accepted the request but returned no payment URL, so there is ' +
        'nowhere to send the customer. Treat this as a failed payment.',
      'INVALID_RESPONSE',
      { response }
    );
  }

  return {
    paymentUrl,
    transactionId: response.gid,
    raw: response,
  };
}
