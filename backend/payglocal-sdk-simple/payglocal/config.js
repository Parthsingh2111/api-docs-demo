/**
 * =============================================================================
 * 1. CONFIGURE
 * =============================================================================
 *
 * PART 1 of this file is the only thing you edit.
 * PART 2 is PayGlocal's endpoints and statuses, for reference.
 * PART 3 is the PayGlocal plumbing: keys, signing, encryption, the HTTP call.
 *        You never need to read or change PART 3.
 *
 * Fill in PART 1, put your two key files in ./keys/, and you are done.
 */

import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { CompactEncrypt, CompactSign, importSPKI, importPKCS8, importX509 } from 'jose';

// #############################################################################
// PART 1  —  EDIT THIS
// #############################################################################

export const config = {
  /** 'uat' while you test, 'production' when you go live. */
  environment: process.env.PAYGLOCAL_ENVIRONMENT || 'uat',

  // --- Your credentials, from PayGlocal ---------------------------------------
  merchantId: process.env.PAYGLOCAL_MERCHANT_ID || 'PUT_YOUR_MERCHANT_ID_HERE',

  /** Key id for PAYGLOCAL'S key. Encrypts what you send. */
  publicKeyId: process.env.PAYGLOCAL_PUBLIC_KEY_ID || 'PUT_PAYGLOCAL_KEY_ID_HERE',

  /** Key id for YOUR key. Signs what you send. */
  privateKeyId: process.env.PAYGLOCAL_PRIVATE_KEY_ID || 'PUT_YOUR_KEY_ID_HERE',

  // --- Your two key files, both in ./keys/ ------------------------------------
  // PayGlocal's can be a .pem or a .cert, whichever they gave you.
  // Yours must be an unencrypted "-----BEGIN PRIVATE KEY-----" file.
  payglocalPublicKeyFile: process.env.PAYGLOCAL_PUBLIC_KEY_PATH || './keys/payglocal_public_key.pem',
  merchantPrivateKeyFile: process.env.PAYGLOCAL_PRIVATE_KEY_PATH || './keys/merchant_private_key.pem',

  // --- Or the keys inline, instead of as files -------------------------------
  //
  // Serverless hosts (Vercel, Lambda, Cloud Run) deploy no key files and give
  // you no disk to put them on, so there the PEM has to travel as an
  // environment variable. Set these and the two file paths above are not read
  // at all. A value may use real newlines or the literal "\n" that most
  // dashboards produce; both are handled.
  payglocalPublicKeyPem: process.env.PAYGLOCAL_PUBLIC_KEY_CONTENT || null,
  merchantPrivateKeyPem: process.env.PAYGLOCAL_PRIVATE_KEY_CONTENT || null,

  // --- Your URLs -------------------------------------------------------------

  /** Where PayGlocal sends the customer's browser back. See callback.js */
  callbackUrl: process.env.PAYGLOCAL_CALLBACK_URL || 'http://localhost:3000/payglocal/callback',

  /**
   * Where PayGlocal sends payment events, server to server. See webhook.js
   *
   * PayGlocal does not discover this by itself. Email this exact URL to your
   * account manager or merchant.support@payglocal.in and ask them to register
   * it. Until they do it is never called, and because the webhook is what
   * confirms payment, every order will sit unpaid with no error anywhere.
   */
  webhookUrl: process.env.PAYGLOCAL_WEBHOOK_URL || 'http://localhost:3000/payglocal/webhook',

  /**
   * Your own pages, where the customer lands afterwards.
   *
   * If your app routes on the fragment, write the whole thing:
   * 'https://shop.com/#/thanks'. The parameters are added inside the fragment
   * so your router receives them.
   *
   * QUOTE THESE IN A .env FILE. An unquoted '#' starts a comment, so
   *     PAYGLOCAL_SUCCESS_URL=https://shop.com/#/thanks
   * silently becomes 'https://shop.com/' and every customer lands on your home
   * page. Write PAYGLOCAL_SUCCESS_URL="https://shop.com/#/thanks" instead.
   */
  successUrl: process.env.PAYGLOCAL_SUCCESS_URL || 'http://localhost:3000/success',
  failureUrl: process.env.PAYGLOCAL_FAILURE_URL || 'http://localhost:3000/failure',

  // --- Optional -------------------------------------------------------------

  /** How long to wait for PayGlocal, in milliseconds. */
  timeoutMs: 30000,

  /** Logs every PayGlocal call. Handy while integrating, never in production. */
  debug: process.env.PAYGLOCAL_DEBUG === 'true',
};

// #############################################################################
// PART 2  —  PAYGLOCAL'S ENDPOINTS AND STATUSES (reference)
// #############################################################################

export const endpoints = {
  uat: 'https://api.uat.payglocal.in',
  production: 'https://api.payglocal.in',
  initiate: '/gl/v1/payments/initiate/paycollect',
  status: (transactionId) => `/gl/v1/payments/${encodeURIComponent(transactionId)}/status`,
};

/** The single status that means the money is yours. */
export const PAID_STATUS = 'SENT_FOR_CAPTURE';

/**
 * Statuses that mean the payment is over and will never succeed.
 *
 * This list matters more than it looks. A status that is neither paid nor listed
 * here means the payment is still going (the customer may be on their bank's OTP
 * screen right now), so you must leave that order alone instead of failing it.
 *
 * Confirm the list with PayGlocal for your account. Anything unrecognised counts
 * as still-in-progress on purpose: a stuck order can be looked up and fixed, an
 * order wrongly marked failed is simply lost.
 */
export const FAILED_STATUSES = [
  'ISSUER_DECLINE', 'GENERAL_DECLINE', 'CUSTOMER_CANCELLED', 'ABANDONED',
  'REQUEST_ERROR', 'DECLINED', 'FAILED', 'EXPIRED', 'VOIDED', 'REVERSED',
];

// #############################################################################
// PART 3  —  THE PAYGLOCAL PLUMBING. Nothing below here needs your attention.
//
// Signing, encryption, authentication and the HTTP call live here so that
// initiate.js and status.js can both use them without either file repeating
// the crypto. This is the only shared code in the SDK.
// #############################################################################

/** The one error this SDK throws. Read `error.message`; it says what to fix. */
export class PayGlocalError extends Error {
  constructor(message, code, extra = {}) {
    super(message);
    this.name = 'PayGlocalError';
    this.code = code;
    Object.assign(this, extra);
  }
}

// --- Configuration check, run once before the first call ---------------------

let checked = false;

export function checkConfig() {
  if (checked) return;

  for (const field of ['merchantId', 'publicKeyId', 'privateKeyId']) {
    const value = config[field];
    if (!value || value.startsWith('PUT_')) {
      throw new PayGlocalError(
        `Missing configuration: config.${field} is still "${value}". ` +
          `Fill it in at the top of payglocal/config.js, or set the matching ` +
          `PAYGLOCAL_* environment variable.`,
        'CONFIG_MISSING'
      );
    }
  }

  if (!endpoints[config.environment]) {
    throw new PayGlocalError(
      `Invalid environment "${config.environment}". Use 'uat' or 'production'.`,
      'INVALID_ENVIRONMENT'
    );
  }

  if (config.publicKeyId === config.privateKeyId) {
    throw new PayGlocalError(
      'publicKeyId and privateKeyId are set to the same value. publicKeyId is ' +
        "PayGlocal's key id, privateKeyId is yours. They are always different.",
      'CONFIG_MISSING'
    );
  }

  for (const field of ['callbackUrl', 'webhookUrl', 'successUrl', 'failureUrl']) {
    let parsed;
    try {
      parsed = new URL(config[field]);
    } catch {
      throw new PayGlocalError(
        `config.${field} must be a full URL, e.g. https://your-site.com/... ` +
          `Got "${config[field]}".`,
        'CONFIG_MISSING'
      );
    }

    // A bare origin is almost always an unquoted '#' in a .env file: dotenv
    // treats the rest of the line as a comment, so 'https://shop.com/#/thanks'
    // arrives as 'https://shop.com/'. That is a valid URL, so the check above
    // passes and the customer quietly lands on the home page instead.
    const isBareOrigin = (parsed.pathname === '/' || parsed.pathname === '') &&
      !parsed.search && !parsed.hash;

    if (isBareOrigin && (field === 'successUrl' || field === 'failureUrl')) {
      throw new PayGlocalError(
        `config.${field} is just "${config[field]}", with no path. If you set ` +
          `it in a .env file and the URL contains a '#', quote it: an ` +
          `unquoted '#' starts a comment and everything after it is dropped. ` +
          `Write ${field === 'successUrl' ? 'PAYGLOCAL_SUCCESS_URL' : 'PAYGLOCAL_FAILURE_URL'}` +
          `="https://your-site.com/#/your-page". If your page really is at the ` +
          `site root, add an explicit path such as "/" plus a query, or set ` +
          `config.${field} in config.js instead.`,
        'CONFIG_MISSING'
      );
    }
  }

  if (!Number.isInteger(config.timeoutMs) || config.timeoutMs <= 0) {
    throw new PayGlocalError(
      `config.timeoutMs must be a whole number of milliseconds. Got ` +
        `${JSON.stringify(config.timeoutMs)}.`,
      'CONFIG_MISSING'
    );
  }

  checked = true;
}

// --- Keys, read and parsed once ----------------------------------------------

let cachedKeys = null;

function readPem(file, label) {
  try {
    return readFileSync(file, 'utf8').trim();
  } catch (error) {
    throw new PayGlocalError(
      `Could not read your ${label}: ${file} ` +
        `(${error.code === 'ENOENT' ? 'file not found' : error.message}). ` +
        `Put the files PayGlocal gave you in ./keys/ and check the paths in ` +
        `payglocal/config.js.`,
      'INVALID_KEY'
    );
  }
}

/**
 * Cleans up a PEM that arrived in an environment variable.
 *
 * Dashboards and shells mangle multi-line values in predictable ways: the
 * newlines come through as the two characters \ and n, the whole thing may be
 * wrapped in quotes, and Windows line endings sneak in. A PEM has to have real
 * line breaks or the parser rejects it, so undo all three.
 */
function normalisePem(pem, label) {
  const cleaned = String(pem)
    .trim()
    .replace(/^['"]|['"]$/g, '')
    .replace(/\\r\\n|\\n/g, '\n')
    .replace(/\r\n|\r/g, '\n')
    .trim();

  if (!cleaned.includes('-----BEGIN')) {
    throw new PayGlocalError(
      `The ${label} supplied inline does not look like a PEM: no ` +
        `"-----BEGIN" line. Copy the whole file, including the BEGIN and END ` +
        `lines.`,
      'INVALID_KEY'
    );
  }

  return cleaned;
}

async function getKeys() {
  if (cachedKeys) return cachedKeys;

  const publicPem = config.payglocalPublicKeyPem
    ? normalisePem(config.payglocalPublicKeyPem, "PayGlocal public key")
    : readPem(config.payglocalPublicKeyFile, "PayGlocal public key");

  const privatePem = config.merchantPrivateKeyPem
    ? normalisePem(config.merchantPrivateKeyPem, 'private key')
    : readPem(config.merchantPrivateKeyFile, 'private key');

  // Catch the classic mix-up before PayGlocal replies with a vague
  // "Authentication failed".
  if (publicPem.includes('PRIVATE KEY') || privatePem.includes('PUBLIC KEY')) {
    throw new PayGlocalError(
      'Your two key files look swapped. payglocalPublicKeyFile must be ' +
        "PayGlocal's public key or .cert, and merchantPrivateKeyFile must be " +
        'your own private key. Check payglocal/config.js.',
      'INVALID_KEY'
    );
  }

  let publicKey;
  try {
    // PayGlocal usually ships a certificate rather than a bare public key.
    publicKey = publicPem.includes('BEGIN CERTIFICATE')
      ? await importX509(publicPem, 'RSA-OAEP-256')
      : await importSPKI(publicPem, 'RSA-OAEP-256');
  } catch (error) {
    throw new PayGlocalError(
      `PayGlocal's public key could not be read (${config.payglocalPublicKeyFile}): ` +
        `${error.message}. It should start with "-----BEGIN PUBLIC KEY-----" or ` +
        `"-----BEGIN CERTIFICATE-----".`,
      'INVALID_KEY'
    );
  }

  let privateKey;
  try {
    privateKey = await importPKCS8(privatePem, 'RS256');
  } catch (error) {
    const hint = privatePem.includes('BEGIN RSA PRIVATE KEY')
      ? `\n\nYours is in the older PKCS#1 format. Convert it:\n` +
        `  openssl pkcs8 -topk8 -nocrypt -in ${config.merchantPrivateKeyFile} ` +
        `-out key.pk8.pem`
      : privatePem.includes('ENCRYPTED')
        ? `\n\nYours is password-protected. Decrypt it:\n` +
          `  openssl pkcs8 -topk8 -nocrypt -in ${config.merchantPrivateKeyFile} ` +
          `-out key.pk8.pem`
        : '';

    throw new PayGlocalError(
      `Your private key could not be read (${config.merchantPrivateKeyFile}): ` +
        `${error.message}. It must start with "-----BEGIN PRIVATE KEY-----".${hint}`,
      'INVALID_KEY'
    );
  }

  cachedKeys = { publicKey, privateKey };
  return cachedKeys;
}

// --- The PayGlocal request ---------------------------------------------------
//
// PayGlocal expects the request body to BE an encrypted token (a JWE), with a
// second signed token (a JWS) in a header proving it came from you. Both are
// built here. `exp` is a lifetime in milliseconds, not a timestamp; that is
// their spec, so do not "correct" it.

async function encryptPayload(payload, publicKey) {
  try {
    return await new CompactEncrypt(new TextEncoder().encode(JSON.stringify(payload)))
      .setProtectedHeader({
        'issued-by': config.merchantId,
        alg: 'RSA-OAEP-256',
        enc: 'A128CBC-HS256',
        exp: 300000,
        iat: `${Date.now()}`,
        kid: config.publicKeyId,
      })
      .encrypt(publicKey);
  } catch (error) {
    throw new PayGlocalError(`Encryption failed: ${error.message}`, 'ENCRYPTION_FAILED');
  }
}

async function signContent(content, privateKey) {
  try {
    return await new CompactSign(
      new TextEncoder().encode(
        JSON.stringify({
          digest: createHash('sha256').update(content).digest('base64'),
          digestAlgorithm: 'SHA-256',
          exp: 300000,
          iat: `${Date.now()}`,
        })
      )
    )
      .setProtectedHeader({
        alg: 'RS256',
        kid: config.privateKeyId,
        'x-gl-merchantId': config.merchantId,
        'issued-by': config.merchantId,
        'is-digested': 'true',
        'x-gl-enc': 'true',
      })
      .sign(privateKey);
  } catch (error) {
    throw new PayGlocalError(`Signing failed: ${error.message}`, 'SIGNING_FAILED');
  }
}

/**
 * Sends a request to PayGlocal and returns their parsed response.
 *
 * Used by initiate.js (POST, with a payload) and status.js (GET, no payload).
 * Handles encryption, signing, headers, the URL and errors.
 */
export async function callPayGlocal({ method, path, payload }) {
  checkConfig();
  const { publicKey, privateKey } = await getKeys();

  const url = endpoints[config.environment] + path;
  const headers = {};
  let body;

  if (method === 'POST') {
    body = await encryptPayload(payload, publicKey);
    headers['Content-Type'] = 'text/plain';
    headers['x-gl-token-external'] = await signContent(body, privateKey);
  } else {
    // A GET has no body, so the path itself is what gets signed.
    headers['x-gl-token-external'] = await signContent(path, privateKey);
  }

  let httpStatus;
  let text;
  try {
    const response = await fetch(url, {
      method,
      headers,
      body,
      signal: AbortSignal.timeout(config.timeoutMs),
    });
    httpStatus = response.status;
    // Read the body inside this try: a server that sends headers and then
    // stalls fails here, not at fetch().
    text = await response.text();
  } catch (error) {
    const timedOut = error.name === 'TimeoutError' || error.name === 'AbortError';
    throw new PayGlocalError(
      timedOut
        ? `PayGlocal did not respond within ${config.timeoutMs}ms. IMPORTANT: the ` +
          `result is unknown and a payment may have been created. Do not mark the ` +
          `order failed; check it with status.js instead.`
        : `Could not reach PayGlocal (${method} ${url}): ${error.message}. The ` +
          `result is unknown, so do not mark the order failed.`,
      timedOut ? 'REQUEST_TIMEOUT' : 'REQUEST_FAILED'
    );
  }

  let data;
  try {
    data = text ? JSON.parse(text) : {};
  } catch {
    throw new PayGlocalError(
      `PayGlocal returned something that is not JSON (HTTP ${httpStatus}).`,
      'INVALID_RESPONSE',
      { httpStatus }
    );
  }

  if (config.debug) {
    // Deliberately narrow: never the tokens, the payload or the full response.
    console.log(
      `[payglocal] ${method} ${url} -> HTTP ${httpStatus} ` +
        `status=${data.status ?? '-'} reasonCode=${data.reasonCode ?? '-'}`
    );
  }

  if (httpStatus < 200 || httpStatus >= 300) {
    throw new PayGlocalError(
      `PayGlocal rejected the request (HTTP ${httpStatus}` +
        `${data.reasonCode ? `, ${data.reasonCode}` : ''})` +
        `${data.message ? `: ${data.message}` : ''}` +
        `${data.reasonCode === 'GL-400-001'
          ? '. This usually means your key files or your two key ids are swapped.'
          : ''}`,
      'API_ERROR',
      { httpStatus, reasonCode: data.reasonCode, response: data }
    );
  }

  return data;
}
