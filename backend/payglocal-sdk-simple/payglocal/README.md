# PayGlocal SDK for Node.js

Five files. You edit the top of one of them.

```
payglocal/
├── config.js     1. Configure  — your credentials, keys and URLs
├── payloads.js   2. Payloads   — every payload structure, pick yours
├── initiate.js   3. Initiate   — send it
├── callback.js   4. Callback   — the customer coming back to your site
├── webhook.js    5. Webhook    — confirm the payment, update your database
└── status.js     6. Status     — ask PayGlocal what happened to a payment
```

Everything PayGlocal-specific — encryption, signing, authentication, endpoints,
headers, request formatting — is handled inside the SDK. You pass your payment
details in and get a payment URL back.

---

## 1. Installation

```
Download the ZIP  →  put the payglocal/ folder in your project  →  configure it
```

```bash
npm install jose
```

`jose` is the only thing the SDK needs. Requires Node 18 or newer.

Put the two key files PayGlocal gave you in `./keys/`.

---

## 2. Configuration

Open `payglocal/config.js` and fill in **PART 1**. That is the only part you edit.

```js
export const config = {
  environment: 'uat',                    // 'uat' or 'production'

  merchantId:   'your-merchant-id',
  publicKeyId:  'payglocal-key-id',      // PayGlocal's key id — encrypts
  privateKeyId: 'your-key-id',           // your key id — signs

  payglocalPublicKeyFile: './keys/payglocal_public_key.pem',
  merchantPrivateKeyFile: './keys/merchant_private_key.pem',

  callbackUrl: 'https://your-site.com/payglocal/callback',
  webhookUrl:  'https://your-site.com/payglocal/webhook',
  successUrl:  'https://your-site.com/success',
  failureUrl:  'https://your-site.com/failure',
};
```

Every value can also come from an environment variable (`PAYGLOCAL_MERCHANT_ID`
and so on), which is what you should do in production.

**Two things that catch everyone out:**

- `publicKeyId` is **PayGlocal's** key id, `privateKeyId` is **yours**. Swapping
  these two, or swapping the two key files, gives the same unhelpful
  `GL-400-001 Authentication failed`. The SDK detects swapped *files* for you;
  swapped *ids* it cannot see.
- **Email your `webhookUrl` to PayGlocal** (your account manager or
  merchant.support@payglocal.in) and ask them to register it. They do not
  discover it. Until they do, no payment is ever confirmed and nothing in any log
  tells you why.

---

## 3. Build the payload

Open `payglocal/payloads.js`. Every structure PayGlocal accepts is in there,
with the real JSON printed above each one. Pick the one that matches your
business:

| Use | For | Where the customer goes |
|---|---|---|
| `servicePayment()` | Services, software, subscriptions — nothing shipped | `paymentData.billingData` |
| `goodsPayment()` | Physical goods | `riskData.shippingData` |
| `recurringPayment()` | Standing instruction, charged on a schedule | adds `standingInstruction` |
| `airlinePayment()` | Flight tickets | adds `riskData.flightData` |

```js
import { goodsPayment } from './payglocal/payloads.js';

const payload = goodsPayment({
  merchantTxnId: 'ORDER-1001',      // your id, different every attempt
  totalAmount:   '15',              // text, not a number
  txnCurrency:   'USD',
  shippingData: {
    firstName: 'John', lastName: 'Denver',
    addressStreet1: 'Test123', addressStreet2: 'Punctuality lane',
    addressCity: 'Bangalore', addressState: 'Karnataka',
    addressPostalCode: '560094', addressCountry: 'IN',
    emailId: 'johndenver@myemail.com',
    callingCode: '+91', phoneNumber: '9008018469',
  },
});
```

Prefer to write the object by hand? Do that and skip `payloads.js` entirely —
`initiatePayment()` takes any valid PayGlocal payload and does not rewrite it.

**Three things that bite everyone:**

- **`riskData` is top level**, beside `paymentData`, not inside it. Passing
  `paymentData.risk` is rejected with an error saying so.
- **`callingCode` includes the plus:** `'+91'`.
- **Two different date formats.** `startDate` and `reservationDate` are
  `'20251001'` (YYYYMMDD). `departureDate` and `arrivalDate` are
  `'2024-06-10T08:00:00Z'` (ISO 8601).

---

## 4. Send it

```js
import { initiatePayment } from './payglocal/initiate.js';

const payment = await initiatePayment(payload);

await db.saveTransactionId(payload.merchantTxnId, payment.transactionId);
res.redirect(payment.paymentUrl);
```

You get back:

```js
{
  paymentUrl:    'https://...',   // send the customer here
  transactionId: 'gl_o-...',      // PayGlocal's id — SAVE THIS
  merchantTxnId: 'ORDER-1001',
  raw:           { ... }          // PayGlocal's untouched response
}
```

**Save `transactionId`.** It is the only thing `status.js` can look a payment up
by, so an order without it can never be checked or repaired.

`initiatePayment()` adds `merchantCallbackURL` from `config.js`, encrypts the
payload, signs the request, sets the headers, picks the right endpoint for your
environment, sends it and checks the reply. You never touch any of that.

---

## 5. Callback — the customer comes back

```js
import { handleCallback } from './payglocal/callback.js';

app.post('/payglocal/callback', handleCallback);
app.get('/payglocal/callback', handleCallback);   // in case they hit cancel
```

That is the whole thing. It reads PayGlocal's token and redirects to your
`successUrl` or `failureUrl`.

Writing your own route instead? Use `readCallback(token)`, which gives you
`{ paid, status, orderId, transactionId, amount, currency }`.

**Do not confirm orders here.** This only runs if the customer's browser comes
back. Close the tab, lose signal, flat battery on the bank's screen, and it never
runs — and PayGlocal does not retry it. Confirming payment is the webhook's job.

Your success page should look the order up in your own database and show the
status you stored. PayGlocal does not sign this token, so anything in the URL
could have been changed by whoever holds the browser.

---

## 6. Webhook — this is what confirms the payment

```js
import { handleWebhook } from './payglocal/webhook.js';

app.post('/payglocal/webhook', handleWebhook);
```

Then open `payglocal/webhook.js`, scroll to the merchant section, and add your
code:

```js
// ---------------------------------------------------------------------------
// YOUR CODE GOES HERE
// ---------------------------------------------------------------------------

const result = await db.query(
  `UPDATE orders
      SET status = $1, payglocal_id = $2, updated_at = now()
    WHERE order_id = $3
      AND amount = $4
      AND currency = $5
      AND status = 'AWAITING_PAYMENT'`,
  [payment.result, payment.transactionId,
   payment.orderId, payment.amount, payment.currency]
);

if (result.rowCount === 1 && payment.result === 'PAID') {
  await sendReceiptEmail(payment.orderId);
}
```

Or just call your own function: `await myOrderService.recordPayment(payment)`.

`payment` gives you `result`, `orderId`, `transactionId`, `amount`, `currency`,
`status` and `raw`.

**Three rules, all shown in the file:**

1. **Use `payment.result`, not `payment.paid`.** `result` is `'PAID'`, `'FAILED'`
   or `'IN_PROGRESS'`. If it is `IN_PROGRESS`, do nothing and return — the
   payment is still happening, and marking it failed would kill an order whose
   money is about to arrive. `paid` is only true or false, so using it here means
   "not yet paid" and "failed" become the same thing.
2. **Only update an order still awaiting payment, and match the amount.** The
   same payment can arrive more than once: PayGlocal retries, you may run several
   servers, and events can arrive out of order. This makes a repeat harmless.
3. **Send emails and release stock only if your update actually changed a row.**
   Otherwise a retry sends the customer a second receipt.

If your code throws, the SDK replies with an error and PayGlocal retries later.
That is correct — never catch a database failure and pretend it worked, or the
order is lost for good.

---

## 7. Check a payment's status

```js
import { checkStatus } from './payglocal/status.js';

const payment = await checkStatus(order.transactionId);

if (payment.result === 'PAID') { /* ... */ }
```

Same shape as the webhook gives you, so your order logic stays in one place.

Two reasons you will need this:

- **An order is stuck.** The webhook never arrived — not registered yet, wrong
  URL, or your server was down longer than PayGlocal kept retrying. Run this over
  orders that have been awaiting payment for more than fifteen minutes. Worth
  setting up as a cron job from day one; `status.js` has a ready-made example.
- **Before doing something you cannot undo.** A webhook event is not signed, so
  anyone who learns your webhook URL could send a fake one. This asks PayGlocal
  directly, so the answer cannot be faked. Use it before shipping anything
  expensive.

---

## 8. Errors

Every error is a `PayGlocalError` with a plain-English `message` and a `code`.

```js
try {
  const payment = await initiatePayment({ ... });
} catch (error) {
  console.error(error.code, error.message);
}
```

| `code` | What it means | What to do |
|---|---|---|
| `CONFIG_MISSING` | A value in `config.js` is empty, still a placeholder, or not a valid URL | Fill in PART 1 of `config.js` |
| `INVALID_ENVIRONMENT` | `environment` is not `'uat'` or `'production'` | Fix the spelling |
| `INVALID_KEY` | A key file is missing, unreadable, in the wrong format, or the two are swapped | The message says which file and gives the `openssl` command if a conversion is needed |
| `INVALID_PAYLOAD` | Your payment details are wrong, e.g. amount is a number instead of `'499.00'` | The message names the field |
| `MISSING_FIELD` | A required field was not supplied | The message names it |
| `ENCRYPTION_FAILED` | The request could not be encrypted | Almost always a bad PayGlocal key file |
| `SIGNING_FAILED` | The request could not be signed | Almost always a bad private key |
| `REQUEST_FAILED` | PayGlocal could not be reached | **The result is unknown. Do not mark the order failed** — check it with `checkStatus()` |
| `REQUEST_TIMEOUT` | PayGlocal did not answer in time | Same as above: unknown, so leave the order alone |
| `API_ERROR` | PayGlocal rejected the request | The message carries their reason. `GL-400-001` means swapped keys or key ids |
| `INVALID_RESPONSE` | PayGlocal's reply was not usable | Treat the payment as failed |
| `CALLBACK_INVALID` | The callback token was missing or malformed | Handled for you — the customer goes to your failure page |
| `WEBHOOK_INVALID` | The webhook body was not valid JSON | The SDK replies `400` |

The important distinction: `API_ERROR` and `INVALID_RESPONSE` mean **no payment
was created**, so the order failed. `REQUEST_FAILED` and `REQUEST_TIMEOUT` mean
**nobody knows** — a payment may exist, so leave the order alone and use
`checkStatus()`.

---

## Two things to confirm with PayGlocal before you go live

The SDK is honest about what it cannot know from the outside:

1. **The exact field names in a live webhook.** The SDK passes their event
   through as-is and reads `merchantTxnId`, `amount` and `currency`. Log one real
   UAT webhook and check the names match. If they do not, your database update
   will quietly match zero rows.
2. **The full list of statuses, and which ones are final.** `FAILED_STATUSES` in
   `config.js` is a best effort. Anything unrecognised is treated as still in
   progress on purpose, so a wrong list means a stuck order rather than a lost
   one — but get the real list.

Also worth knowing: **refunds and chargebacks are not covered by this SDK.**
