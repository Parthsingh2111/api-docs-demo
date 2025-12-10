# Visualization Screen Corrections

## What Was Wrong

### 1. **Incorrect Step Count (6 steps → 4 steps)**
The original visualization showed 6 manual steps suggesting the SDK does everything manually:
- ❌ Step 1: Create Payload
- ❌ Step 2: Generate CEK manually
- ❌ Step 3: Encrypt Payload with AES-256-GCM manually
- ❌ Step 4: Encrypt CEK with RSA-OAEP manually
- ❌ Step 5: Assemble JWE manually
- ❌ Step 6: Sign with JWS

**Reality:** The SDK uses the `jose` library which handles steps 2-5 automatically. The actual flow is:
- ✅ Step 1: Generate JWE (jose library does CEK, AES, RSA, assembly)
- ✅ Step 2: Generate JWS (sign the JWE)
- ✅ Step 3: Build headers (JWS in header, JWE in body)
- ✅ Step 4: Send HTTP request

### 2. **Wrong Encryption Algorithm**
- ❌ Original claimed: `AES-256-GCM`
- ✅ SDK actually uses: `A128CBC-HS256` (AES-128-CBC + HMAC-SHA256)

From `crypto.js` line 42:
```javascript
enc: 'A128CBC-HS256',
```

### 3. **Misleading CEK Generation Details**
The original screen showed manual CEK generation code:
```javascript
const cek = crypto.randomBytes(32);
```

**Reality:** The `jose` library's `CompactEncrypt` generates the CEK internally. Developers never touch it.

### 4. **Wrong Claims About Manual Encryption**
Original showed code for manual AES-GCM encryption with IV and auth tags.

**Reality:** From `crypto.js` line 39:
```javascript
return await new jose.CompactEncrypt(new TextEncoder().encode(payloadStr))
  .setProtectedHeader({ ... })
  .encrypt(publicKey);
```
One call does everything. No manual cipher creation needed.

### 5. **Incorrect Timestamp Format**
- ❌ Original suggested: `iat` and `exp` should be numeric epoch seconds
- ✅ SDK actually uses: **Milliseconds as strings**

From `crypto.js` lines 34, 44, 67:
```javascript
const iat = Date.now();  // milliseconds
const exp = iat + 300000;
// ...
iat: iat.toString(),  // converted to string!
exp: exp.toString(),  // converted to string!
```

This is why your curl token had:
```json
"iat": "1761900553827",
"exp": "300000"
```
The `iat` is correct (milliseconds string), but `exp` should be absolute time, not duration.

### 6. **Over-Complicated UI**
- ❌ Had 1875 lines with heavy animations, complex gradients, hero sections
- ❌ Multiple animation controllers, flow animations, stat chips
- ❌ Separate sections for algorithms, code examples, complete flow

**Improved:**
- ✅ 769 lines - clean, focused
- ✅ Single fade animation (removed flow animation)
- ✅ Clear 4-step process matching SDK reality
- ✅ Simple, readable cards without overwhelming visuals

### 7. **Misleading JWE Structure Explanation**
Original explained manual 5-part assembly:
```
BASE64URL(Header).BASE64URL(EncryptedKey).BASE64URL(IV).BASE64URL(Ciphertext).BASE64URL(AuthTag)
```

**Reality:** `jose.CompactEncrypt().encrypt()` returns this assembled string automatically. You never build it manually.

### 8. **Incorrect Request Format Description**
The original didn't clearly explain the critical mistake users make:

**Wrong (causes GL-400-001):**
```bash
curl -X POST ... \
  -H 'Content-Type: application/json' \
  -d '{"data": "JWE...", "signature": "JWS..."}'
```

**Correct:**
```bash
curl -X POST ... \
  -H 'Content-Type: text/plain' \
  -H 'x-gl-token-external: JWS...' \
  --data-raw 'JWE...'
```

Now clearly shown in Step 3 and Step 4.

## What Was Corrected

### Accurate SDK Flow (4 Steps)

#### **Step 1: Generate JWE**
- Uses `jose.CompactEncrypt()` with PayGlocal public key
- Internally generates CEK, encrypts payload with AES-128-CBC-HS256, wraps CEK with RSA-OAEP-256
- Returns assembled 5-part token automatically
- Timestamps in milliseconds (as strings)

#### **Step 2: Generate JWS**
- Hashes JWE with SHA-256
- Signs hash with merchant private key using RS256
- Creates 3-part token: header.payload.signature
- Timestamps: `exp` as number (milliseconds), `iat` as string

#### **Step 3: Build Headers**
- `Content-Type: text/plain` (NOT application/json)
- `x-gl-token-external: JWS` (signature in header)
- Body contains raw JWE (not wrapped in JSON)

#### **Step 4: Send Request**
- POST to `/gl/v1/payments/initiate/paycollect`
- Body is raw JWE string
- Common mistake highlighted: don't send `{"data": JWE, "signature": JWS}`

### UI Improvements

1. **Simplified Layout**
   - Removed hero section with stats
   - Removed redundant algorithm reference section
   - Combined flow diagram into single view
   - Max width 900px for readability

2. **Performance**
   - Removed flow animation controller
   - Reduced animation from 1000ms to 600ms
   - Removed heavy gradient computations
   - Simplified card structures

3. **Clarity**
   - Each step shows exactly what the SDK code does
   - Code examples match actual `crypto.js` implementation
   - Clear notes highlight common mistakes
   - Color-coded steps (purple → cyan → green → orange)

4. **Accuracy**
   - All algorithms match SDK reality
   - All code examples use actual jose library calls
   - Timestamps match SDK format (milliseconds as strings)
   - Request format matches `headerHelper.js` and `http.js`

## Key Takeaways for Users

1. **Don't manually encrypt** - `jose` library does it all
2. **Timestamps are milliseconds as strings** in JWE/JWS headers
3. **`exp` must be absolute time**, not duration (your issue)
4. **JWS goes in header** `x-gl-token-external`, not body
5. **Body is raw JWE**, not JSON
6. **Content-Type must be text/plain**, not application/json

## Your Token Issue Explained

Your curl command failed because:
1. ✅ JWS was in body instead of `x-gl-token-external` header
2. ✅ Body was JSON `{"data": "...", "signature": "..."}` instead of raw JWE
3. ✅ Content-Type was `application/json` instead of `text/plain`
4. ⚠️  `exp: 300000` was a duration, not absolute timestamp (should be `iat + 300000`)

## Files Changed

- `lib/screen/visualization_screen.dart` - Complete rewrite (1875 → 769 lines)
  - Accurate 4-step flow matching SDK
  - Correct algorithms (A128CBC-HS256, not AES-256-GCM)
  - Proper timestamp format (milliseconds as strings)
  - Clear header vs body placement
  - Simplified UI without excessive animations

## References to SDK Code

All corrections verified against:
- `backend/pg-client-sdk/lib/core/crypto.js` (lines 32-82)
- `backend/pg-client-sdk/lib/helper/tokenHelper.js` (lines 12-36)
- `backend/pg-client-sdk/lib/helper/headerHelper.js` (lines 7-13)
- `backend/pg-client-sdk/lib/core/http.js` (lines 54-82)

