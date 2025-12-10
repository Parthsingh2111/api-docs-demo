# API Reference Screens - Required Fixes

## Summary of Changes Needed

### 1. Headers - Remove Merchant ID
- ❌ Remove `X-MERCHANT-ID` header from all requests
- ✅ Only send `Content-Type: text/plain` and `X-GL-TOKEN-EXTERNAL: <jws>`
- ✅ Body contains only JWE token

### 2. Status Check - JWS Only
- ❌ Status check should NOT generate JWE
- ✅ Status check uses ONLY JWS token in header
- ✅ Status check uses empty payload `{}` or endpoint path for JWS digest
- ✅ Method: GET for regular status check, POST for SI status check

### 3. Token Creation Code
- ✅ Show function that returns both JWE and JWS
- ✅ Example: `const { jwe, jws } = await generateTokens(payload);`

### 4. Response Format
- ❌ Remove "Response (After JWS Decryption)" text
- ✅ Just show "Response" - responses are already decoded

### 5. Payload Structures
- Study pg-client-sdk for correct payload formats
- Fix all payload examples to match SDK structure

### 6. Pause SI - Two Types
- Instant Pause: No startDate
- Pause by Date: Include `standingInstruction.data.startDate`

### 7. Navigation Fixes
- Fix left panel navigation in JWT and Auth API reference pages
- Ensure clicking items scrolls within the same page

## Files to Update

1. `lib/screen/paycollect_si_api_reference.dart`
2. `lib/screen/paycollect_api_reference_jwt_screen.dart`
3. `lib/screen/paycollect_auth_api_reference.dart`

## Response Updates

Use the actual responses provided by the user for each API endpoint.

