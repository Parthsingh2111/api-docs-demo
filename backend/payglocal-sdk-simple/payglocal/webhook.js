/**
 * =============================================================================
 * 4. HANDLE THE WEBHOOK  —  this is what actually confirms a payment
 * =============================================================================
 *
 * PayGlocal posts payment events here, server to server, and retries if you are
 * down. Unlike the callback it does not depend on the customer's browser, so
 * this is the only place you should update your database.
 *
 * Wire it up like this:
 *
 *   import { handleWebhook } from './payglocal/webhook.js';
 *
 *   app.post('/payglocal/webhook', handleWebhook);
 *
 * Then scroll down to MERCHANT IMPLEMENTATION and add your database code.
 *
 *
 * ================================ IMPORTANT ==================================
 *
 * PayGlocal will not call this until their support team registers your
 * webhookUrl against your merchant id. Email it to them. Until then no order is
 * ever confirmed and nothing appears in any log to tell you why.
 *
 * The same payment can arrive more than once. PayGlocal retries, you may run
 * more than one server, and events can arrive out of order. So your database
 * code must be safe to run twice. The example below shows how.
 */

import { config, PAID_STATUS, FAILED_STATUSES, PayGlocalError } from './config.js';

/**
 * Turns PayGlocal's event into the bits you need.
 *
 *   {
 *     result:        'PAID' | 'FAILED' | 'IN_PROGRESS'
 *     paid:          true / false
 *     status:        PayGlocal's own status text
 *     orderId:       your order id
 *     transactionId: PayGlocal's id
 *     amount:        '499.00'
 *     currency:      'INR'
 *     raw:           the whole event
 *   }
 *
 * Use `result`, not `paid`, when deciding what to write. `paid` is only true or
 * false, so "not paid" would also catch payments that are still in progress and
 * would mark them failed by mistake.
 */
export function readWebhook(event) {
  if (!event || typeof event !== 'object' || Array.isArray(event)) {
    throw new PayGlocalError(
      'The webhook body was not a JSON object.',
      'WEBHOOK_INVALID'
    );
  }

  const status = event.status;
  const paid = status === PAID_STATUS;
  const failed = FAILED_STATUSES.includes(String(status).toUpperCase());

  return {
    result: paid ? 'PAID' : failed ? 'FAILED' : 'IN_PROGRESS',
    paid,
    status,
    orderId: event.merchantTxnId,
    transactionId: event.gid,
    amount: event.amount,
    currency: event.currency,
    raw: event,
  };
}

/**
 * A ready-made route handler.
 *
 *   app.post('/payglocal/webhook', handleWebhook);
 */
export async function handleWebhook(req, res) {
  let payment;

  try {
    const event = req.body && Object.keys(req.body).length ? req.body : await readRawJson(req);
    payment = readWebhook(event);
  } catch (error) {
    console.error(`[payglocal] webhook: ${error.message}`);
    return res.status(400).json({ received: false });
  }

  try {
    await onPaymentUpdate(payment);
  } catch (error) {
    // Reply with an error so PayGlocal tries again later. If you swallow this,
    // a brief database outage silently loses the order forever.
    console.error(`[payglocal] webhook: your code threw: ${error.message}`);
    return res.status(500).json({ received: false });
  }

  // Only now, once your code has finished successfully, tell PayGlocal we have it.
  return res.status(200).json({ received: true });
}

/**
 * ===========================================================================
 *
 *                        M E R C H A N T   C O D E
 *
 *              This is where you update your own system.
 *
 * ===========================================================================
 *
 * `payment` looks like this:
 *
 *   payment.result         'PAID' | 'FAILED' | 'IN_PROGRESS'   <- use this
 *   payment.orderId        the orderId you sent to initiatePayment()
 *   payment.transactionId  PayGlocal's id, worth storing for support
 *   payment.amount         '499.00'
 *   payment.currency       'INR'
 *   payment.status         PayGlocal's raw status text
 *   payment.raw            the full event, if you need anything else
 *
 * Three rules, and the example below follows all three:
 *
 *   1. If result is 'IN_PROGRESS', do nothing and return. The payment is still
 *      happening. Marking it failed here would kill an order whose money is
 *      about to arrive.
 *
 *   2. Only change an order that is still awaiting payment, and check the amount
 *      matches what you charged. This stops a repeated event from overwriting a
 *      finished order.
 *
 *   3. Send emails, release stock and so on ONLY if your update actually changed
 *      something. Otherwise a retry sends the customer a second receipt.
 *
 * If anything you do here throws, PayGlocal is told to retry. That is correct.
 * Never catch an error and pretend it worked.
 */
async function onPaymentUpdate(payment) {
  // -------------------------------------------------------------------------
  // Rule 1: still in progress, so there is nothing to record yet.
  // -------------------------------------------------------------------------
  if (payment.result === 'IN_PROGRESS') {
    console.log(`[order] ${payment.orderId} still in progress (${payment.status})`);
    return;
  }

  // -------------------------------------------------------------------------
  // YOUR CODE GOES HERE. Replace the console.log below.
  //
  // Rules 2 and 3, written out with a real database:
  //
  //   const result = await db.query(
  //     `UPDATE orders
  //         SET status = $1, payglocal_id = $2, updated_at = now()
  //       WHERE order_id = $3
  //         AND amount = $4
  //         AND currency = $5
  //         AND status = 'AWAITING_PAYMENT'`,
  //     [payment.result, payment.transactionId,
  //      payment.orderId, payment.amount, payment.currency]
  //   );
  //
  //   const weJustChangedIt = result.rowCount === 1;
  //
  //   if (weJustChangedIt && payment.result === 'PAID') {
  //     await sendReceiptEmail(payment.orderId);
  //     await releaseStock(payment.orderId);
  //   }
  //
  // Or simply call your own function and let it do the work:
  //
  //   await myOrderService.recordPayment(payment);
  // -------------------------------------------------------------------------

  console.log(
    `[order] ${payment.orderId} -> ${payment.result} ` +
      `(${payment.amount} ${payment.currency}, PayGlocal id ${payment.transactionId})`
  );
  console.log('[order] Add your database update in payglocal/webhook.js');
}

/** Reads the JSON body if no body parser has run. */
async function readRawJson(req) {
  if (req.readableEnded) {
    throw new PayGlocalError(
      'The request body was already read by something else in your app. Register ' +
        'this route before any middleware that consumes the request stream.',
      'WEBHOOK_INVALID'
    );
  }

  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const body = Buffer.concat(chunks).toString('utf8').trim();

  try {
    return JSON.parse(body);
  } catch {
    throw new PayGlocalError('The webhook body was not valid JSON.', 'WEBHOOK_INVALID');
  }
}
