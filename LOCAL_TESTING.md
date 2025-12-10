# Local Testing Guide

## Testing API Functions Locally with Vercel CLI

### Prerequisites

1. **Install Vercel CLI** (if not already installed):
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**:
   ```bash
   vercel login
   ```

3. **Link your project** (if not already linked):
   ```bash
   vercel link
   ```

### Setting Up Environment Variables

Create a `.env.local` file in the root directory with your PayGlocal credentials:

```env
PAYGLOCAL_API_KEY=your_api_key_here
PAYGLOCAL_MERCHANT_ID=your_merchant_id_here
PAYGLOCAL_PUBLIC_KEY_ID=your_public_key_id_here
PAYGLOCAL_PRIVATE_KEY_ID=your_private_key_id_here
PAYGLOCAL_Env_VAR=uat
PAYGLOCAL_LOG_LEVEL=debug

# Option 1: Use file paths (for local testing)
PAYGLOCAL_PUBLIC_KEY=backend/keys/payglocal_public_key
PAYGLOCAL_PRIVATE_KEY=backend/keys/payglocal_private_key

# Option 2: Use key content directly (better for Vercel)
# PAYGLOCAL_PUBLIC_KEY_CONTENT="-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----"
# PAYGLOCAL_PRIVATE_KEY_CONTENT="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
```

### Running Local Development Server

1. **Start Vercel dev server**:
   ```bash
   vercel dev
   ```

   This will start a local server (usually on port 3000) that mimics Vercel's serverless environment.

2. **Test the API endpoint**:

   Using curl:
   ```bash
   curl -X POST http://localhost:3000/api/pay/jwt \
     -H "Content-Type: application/json" \
     -d '{
       "merchantTxnId": "test_123",
       "paymentData": {
         "amount": 1000,
         "currency": "INR"
       },
       "merchantCallbackURL": "https://example.com/callback"
     }'
   ```

   Or using the test script:
   ```bash
   node test-api-local.js
   ```

### Debugging Tips

1. **Check function logs**: The Vercel dev server will show logs in the terminal
2. **Check for missing dependencies**: Make sure `backend/pg-client-sdk` and `backend/pgpd-client-sdk` are accessible
3. **Verify environment variables**: Make sure all required env vars are set in `.env.local`
4. **Check key file paths**: Ensure the key files exist at the specified paths

### Common Issues

1. **Module not found**: The SDK paths might be incorrect. Check that `backend/pg-client-sdk/lib/index.js` exists
2. **Missing environment variables**: Make sure all required env vars are set
3. **Key file not found**: Either set key file paths correctly or use `PAYGLOCAL_*_KEY_CONTENT` env vars

### After Local Testing Works

Once local testing is successful:
1. Commit and push your changes
2. Make sure environment variables are set in Vercel Dashboard → Settings → Environment Variables
3. Redeploy your application

