/**
 * =============================================================================
 * 5. CHECK A PAYMENT'S STATUS
 * =============================================================================
 *
 * Ask PayGlocal what actually happened to a payment.
 *
 *   import { checkStatus } from './payglocal/status.js';
 *
 *   const payment = await checkStatus(order.transactionId);
 *
 *   if (payment.result === 'PAID') { ... }
 *
 * You pass the transactionId that initiatePayment() gave you. Encryption,
 * signing, the endpoint and the response parsing are all handled for you.
 *
 *
 * ============================ WHEN YOU NEED THIS =============================
 *
 * Two situations, and the first one will happen to you:
 *
 *   1. An order is stuck. The webhook never arrived, because it was not
 *      registered yet, was pointed at the wrong URL, or your server was down
 *      longer than PayGlocal kept retrying. Run this over orders that have been
 *      awaiting payment for a while and you will find out where they really are.
 *
 *   2. Before doing something you cannot undo. A webhook event is not signed, so
 *      anyone who learns your webhook URL could send a fake one. If an order is
 *      expensive or ships immediately, confirm it here first. This asks
 *      PayGlocal directly, so the answer cannot be faked.
 *
 * A simple recovery job:
 *
 *   const stuck = await db.query(
 *     `SELECT order_id, payglocal_id FROM orders
 *       WHERE status = 'AWAITING_PAYMENT'
 *         AND created_at < now() - interval '15 minutes'`
 *   );
 *
 *   for (const order of stuck.rows) {
 *     const payment = await checkStatus(order.payglocal_id);
 *     if (payment.result !== 'IN_PROGRESS') {
 *       // same update you do in webhook.js
 *     }
 *   }
 *
 * You can only look a payment up by transactionId; there is no way to search by
 * your own order id. That is why initiate.js tells you to save it.
 */

import { endpoints, PAID_STATUS, FAILED_STATUSES, PayGlocalError, callPayGlocal } from './config.js';

/**
 * Asks PayGlocal about one payment.
 *
 * @param {string} transactionId  The id from initiatePayment(), the callback or
 *                                the webhook. PayGlocal calls this the "gid".
 * @returns {Promise<object>}
 *   {
 *     result:        'PAID' | 'FAILED' | 'IN_PROGRESS'
 *     paid:          true / false
 *     status:        PayGlocal's own status text
 *     orderId:       your order id
 *     transactionId: PayGlocal's id
 *     amount:        '499.00'
 *     currency:      'INR'
 *     raw:           PayGlocal's untouched response
 *   }
 */
export async function checkStatus(transactionId) {
  if (!transactionId || typeof transactionId !== 'string') {
    throw new PayGlocalError(
      'checkStatus() needs the transactionId that initiatePayment() returned. ' +
        'It is the only thing PayGlocal will look a payment up by.',
      'MISSING_FIELD'
    );
  }

  const response = await callPayGlocal({
    method: 'GET',
    path: endpoints.status(transactionId),
  });

  // PayGlocal puts the payment details in a `data` block here, whereas the
  // webhook sends them at the top level. Flatten it so both look the same to
  // you and you only ever write one piece of order logic.
  const details = response?.data && typeof response.data === 'object' ? response.data : {};

  const status = details.status ?? response?.status;
  const paid = status === PAID_STATUS;
  const failed = FAILED_STATUSES.includes(String(status).toUpperCase());

  return {
    result: paid ? 'PAID' : failed ? 'FAILED' : 'IN_PROGRESS',
    paid,
    status,
    orderId: details.merchantTxnId ?? response?.merchantTxnId ?? details.merchantUniqueId,
    transactionId: details.gid ?? response?.gid ?? transactionId,
    amount: details.amount ?? response?.amount,
    currency: details.currency ?? response?.currency,
    raw: response,
  };
}
