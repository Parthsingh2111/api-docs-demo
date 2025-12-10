# API Reference Screens - Fix Progress

## ✅ Completed Fixes

### 1. Headers Fixed
- ✅ Removed `X-MERCHANT-ID` header from all requests
- ✅ Changed `Content-Type` from `application/jose` to `text/plain`
- ✅ Only sending `X-GL-TOKEN-EXTERNAL: <jws>` in headers
- ✅ Body contains only JWE token

**Files Updated:**
- `lib/screen/paycollect_si_api_reference.dart`
- `lib/screen/paycollect_api_reference_jwt_screen.dart`
- `lib/screen/paycollect_auth_api_reference.dart`

### 2. Token Creation Code Updated
- ✅ Updated to show function that returns both JWE and JWS
- ✅ Added support for JWS-only mode (for status check)
- ✅ Improved function signatures in code examples

### 3. Response Text Fixed
- ✅ Removed "Response (After JWS Decryption)" text
- ✅ Now just shows "Response"

### 4. SI Status Check Response Updated
- ✅ Updated with correct response format from user

### 5. SI Pause Section Updated
- ✅ Added structure for instant pause and pause by date

## ⏳ Remaining Work

### 1. Status Check - JWS Only
- ⏳ Create specialized status check builder (JWS only, GET method, no body)
- ⏳ Update status check in JWT API reference
- ⏳ Update status check in Auth API reference
- ⏳ Use endpoint path for JWS digest generation

### 2. Update All Responses
- ⏳ Standard Payment response
- ⏳ SI Payment response
- ⏳ Auth Payment response
- ⏳ Status Check response
- ⏳ Capture responses
- ⏳ Refund responses
- ⏳ Auth Reversal response
- ⏳ SI Pause/Activate responses

### 3. Fix Payload Structures
- ⏳ Study pg-client-sdk for correct payload formats
- ⏳ Update all payload examples
- ⏳ Ensure payload matches SDK structure

### 4. Navigation Fixes
- ⏳ Fix left panel navigation in JWT API reference
- ⏳ Fix left panel navigation in Auth API reference
- ⏳ Ensure scrolling works within same page

### 5. Pause Types
- ⏳ Complete instant pause vs pause by date implementation
- ⏳ Add to SI business flow documentation

## Next Steps

1. Create specialized status check builder method
2. Update all responses with user-provided values
3. Fix payload structures based on SDK
4. Fix navigation issues
5. Complete pause types documentation

