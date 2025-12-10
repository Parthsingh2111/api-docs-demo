# Payment Success/Failure Redirect Flow

## Overview
This document explains how payment callbacks redirect users to success or failure pages based on payment status.

## Flow Diagram

```
User Completes Payment
         ↓
PayGlocal sends callback to backend
         ↓
Backend receives callback with x-gl-token
         ↓
Backend decodes JWT token
         ↓
Backend checks payment status
         ↓
   ┌─────┴─────┐
   ↓           ↓
SUCCESS     FAILURE
   ↓           ↓
Redirect    Redirect
to Success  to Failure
Page        Page
```

## Status Mapping

### Success Statuses
The following statuses redirect to the **success page**:
- `SENT_FOR_CAPTURE` - Payment sent for capture
- `SUCCESS` - Payment successful
- `CAPTURED` - Payment captured
- `AUTHORIZED` - Payment authorized

### Failure Statuses
The following statuses redirect to the **failure page**:
- `FAILED` - Payment failed
- `CANCELLED` - Payment cancelled by user
- `DECLINED` - Payment declined
- `ERROR` - Error occurred during payment

## Implementation Details

### 1. Backend Callback Handler (`backend/index.js`)

```javascript
app.post('/callbackurl', (req, res) => {
  // Extract and decode JWT token
  const decoded = /* decode token */;
  
  // Check status
  const status = decoded.status?.toUpperCase();
  
  if (successStatuses.includes(status)) {
    // Redirect to success page with payment details
    return res.redirect(`http://localhost:8080/#/payment-success?txnId=...&amount=...`);
  } else {
    // Redirect to failure page with error reason
    return res.redirect(`http://localhost:8080/#/payment-failure?reason=...`);
  }
});
```

### 2. Success Page (`lib/screen/payment_success_screen.dart`)

**Accepts the following query parameters:**
- `txnId` - Transaction ID
- `amount` - Payment amount
- `status` - Payment status
- `gid` - PayGlocal Global ID
- `paymentMethod` - Payment method used

**Example URL:**
```
http://localhost:8080/#/payment-success?txnId=1763458300085488915&amount=1499.00&status=SENT_FOR_CAPTURE&gid=gl_o-9a0674c9d3a73e2d1kp90PpX2&paymentMethod=CARD
```

**Features:**
- ✅ Displays payment details
- ✅ Shows transaction ID
- ✅ Shows PayGlocal GID
- ✅ Shows amount and status
- ✅ "Back to Home" button
- ✅ "Download Receipt" button (placeholder)

### 3. Failure Page (`lib/screen/payment_failure_screen.dart`)

**Accepts the following query parameters:**
- `reason` - Failure reason/message
- `txnId` - Transaction ID (if available)
- `status` - Payment status

**Example URL:**
```
http://localhost:8080/#/payment-failure?reason=Payment+declined&txnId=1763458300085488915
```

**Features:**
- ✅ Displays failure reason
- ✅ Shows transaction ID
- ✅ Helpful suggestions
- ✅ "Back to Home" button
- ✅ "Try Again" button

### 4. Router Configuration (`lib/navigation/app_router.dart`)

The router parses query parameters from the URL and passes them to the screens:

```dart
case paymentSuccess: {
  final queryParams = uri.queryParameters;
  return PaymentSuccessScreen(
    txnId: queryParams['txnId'],
    amount: queryParams['amount'],
    // ... other params
  );
}
```

## Testing

### Test Success Flow
1. Complete a payment
2. PayGlocal sends callback with status `SENT_FOR_CAPTURE`
3. Backend redirects to: `http://localhost:8080/#/payment-success?...`
4. User sees success page with payment details

### Test Failure Flow
1. Initiate a payment that will fail (e.g., insufficient funds)
2. PayGlocal sends callback with status `FAILED`
3. Backend redirects to: `http://localhost:8080/#/payment-failure?reason=...`
4. User sees failure page with error message

## Configuration

### Update Redirect URL
To change the redirect URL (e.g., for production), update in `backend/index.js`:

```javascript
// Change from:
return res.redirect('http://localhost:8080/#/payment-success?...');

// To your production URL:
return res.redirect('https://yourdomain.com/#/payment-success?...');
```

### Update Callback URL
The callback URL is set in `lib/utils/pc_payment_utils.dart`:

```dart
"merchantCallbackURL": "https://f4e9e08f868f.ngrok-free.app/callbackurl"
```

## Console Logs

When a callback is received, you'll see:
```bash
POST /callbackurl
Callback received - Status: SENT_FOR_CAPTURE TxnId: 1763458300085488915
```

## Security Notes

⚠️ **Important:** In production:
1. Verify the JWT signature using PayGlocal's public key
2. Use HTTPS for all callback URLs
3. Validate the merchant ID matches your configuration
4. Log all callbacks for audit purposes
5. Implement idempotency to prevent duplicate processing

## Troubleshooting

### Issue: User not redirected
- Check that the callback URL is accessible
- Verify the backend server is running
- Check browser console for errors

### Issue: Parameters not showing
- Verify query parameters are in the URL
- Check that the router is parsing parameters correctly
- Ensure the screens are receiving the parameters

### Issue: Wrong page displayed
- Check the status mapping in `backend/index.js`
- Verify the decoded token contains the correct status
- Check console logs for the actual status received

## Future Enhancements

- [ ] Add signature verification for callbacks
- [ ] Implement retry payment functionality
- [ ] Add receipt download feature
- [ ] Store payment history
- [ ] Add email notifications
- [ ] Implement webhook handling for async notifications

