# Quick Testing Guide

## Step 1: Set Up Environment Variables

Create a `.env.local` file in the root directory (same level as `package.json`):

```bash
# Copy from backend/.env if you have one, or use these:
PAYGLOCAL_API_KEY=your_api_key
PAYGLOCAL_MERCHANT_ID=your_merchant_id
PAYGLOCAL_PUBLIC_KEY_ID=your_public_key_id
PAYGLOCAL_PRIVATE_KEY_ID=your_private_key_id
PAYGLOCAL_Env_VAR=uat
PAYGLOCAL_LOG_LEVEL=debug

# Use file paths (keys should be in backend/keys/)
PAYGLOCAL_PUBLIC_KEY=backend/keys/payglocal_public_key
PAYGLOCAL_PRIVATE_KEY=backend/keys/payglocal_private_key
```

## Step 2: Start Local Server

Open Terminal and run:

```bash
cd /Users/parthsinghpatawat/Library/CloudStorage/OneDrive-PayGlocalTechnologiesPrivateLimited/proj/payglocalCentraProject/centralproject
vercel dev
```

This will start a local server on port 3000 (or another port if 3000 is busy).

## Step 3: Test the API

### Option A: Use the test script (easiest)

In a NEW terminal window:

```bash
cd /Users/parthsinghpatawat/Library/CloudStorage/OneDrive-PayGlocalTechnologiesPrivateLimited/proj/payglocalCentraProject/centralproject
node test-api-local.js
```

### Option B: Use curl

```bash
curl -X POST http://localhost:3000/api/pay/jwt \
  -H "Content-Type: application/json" \
  -d '{
    "merchantTxnId": "test_12345",
    "paymentData": {
      "amount": 1000,
      "currency": "INR"
    },
    "merchantCallbackURL": "https://example.com/callback"
  }'
```

### Option C: Use Postman or similar tool

- Method: POST
- URL: `http://localhost:3000/api/pay/jwt`
- Headers: `Content-Type: application/json`
- Body (JSON):
```json
{
  "merchantTxnId": "test_12345",
  "paymentData": {
    "amount": 1000,
    "currency": "INR"
  },
  "merchantCallbackURL": "https://example.com/callback"
}
```

## Step 4: Check Results

- **Success**: You'll see a JSON response with `status: "SUCCESS"` and a `payment_link`
- **Error**: Check the terminal where `vercel dev` is running for detailed error messages

## Troubleshooting

1. **Port already in use**: Change the port in the test script or stop other services
2. **Module not found**: Make sure you're in the project root directory
3. **Environment variables missing**: Check `.env.local` file exists and has all required variables
4. **Key files not found**: Verify `backend/keys/payglocal_private_key` and `backend/keys/payglocal_public_key` exist

