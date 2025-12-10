# PayGlocal Token Generator for PHP 7.2+

Minimal lightweight token generator for PayGlocal payment initiation. This package provides **only** JWE and JWS token generation functionality - perfect for merchants who only need payment initiation and want to keep dependencies minimal.

## Features

- ✅ **PHP 7.2+ Compatible** - Works with PHP 7.2, 7.3, 7.4, 8.0, 8.1+
- ✅ **Minimal Dependencies** - Only requires JWT Framework for JWE/JWS operations
- ✅ **Simple Interface** - Single function call to generate both tokens
- ✅ **Payment Initiation Only** - Focused on token generation, no other SDK features
- ✅ **Lightweight** - Perfect for merchants who want minimal integration

## Requirements

- PHP >= 7.2
- ext-openssl
- ext-json
- ext-curl (for making API calls)

## Installation

### Option 1: Using Composer (Recommended)

```bash
composer require payglocal/pg-client-sdk-php-7.2
```

### Option 2: Direct Include

If you prefer not to use Composer, you can include the token generator directly:

```php
require_once 'path/to/pg-client-sdk-php-7.2/src/pg_token_generator.php';
```

**Note:** You'll still need to install `web-token/jwt-framework` version 2.1+ which supports PHP 7.2:

```bash
composer require web-token/jwt-framework:^2.1
```

## Quick Start

### 1. Install Dependencies

```bash
composer require payglocal/pg-client-sdk-php-7.2
composer require web-token/jwt-framework:^2.1
```

### 2. Include Autoloader

```php
<?php
require_once __DIR__ . '/vendor/autoload.php';
```

### 3. Generate Tokens

```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

// Your payment payload
$payload = [
    'merchantTxnId' => 'TXN_' . time(),
    'paymentData' => [
        'totalAmount' => '1000.00',
        'txnCurrency' => 'INR',
    ],
    'merchantCallbackURL' => 'https://yourwebsite.com/callback',
];

// Configuration
$config = [
    'merchantId' => 'your_merchant_id',
    'publicKeyId' => 'your_public_key_id',
    'privateKeyId' => 'your_private_key_id',
    'payglocalPublicKey' => file_get_contents('keys/payglocal_public_key.pem'),
    'merchantPrivateKey' => file_get_contents('keys/merchant_private_key.pem'),
    'tokenExpiration' => 300000, // 5 minutes (optional)
];

// Generate tokens
try {
    $tokens = generatePayGlocalTokens($payload, $config);
    
    $jwe = $tokens['jwe'];  // Encrypted payload
    $jws = $tokens['jws'];  // Signature token
    
    // Now use these tokens to make API call
    echo "JWE Token: " . $jwe . "\n";
    echo "JWS Token: " . $jws . "\n";
    
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
```

### 4. Make Payment API Call

```php
// Make the payment initiation API call
$endpoint = 'https://api.uat.payglocal.in/gl/v1/payments/initiate/paycollect';

$ch = curl_init($endpoint);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $jwe);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/jose',
    'X-GL-TOKEN-EXTERNAL: ' . $jws,
    'X-MERCHANT-ID: ' . $config['merchantId'],
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode === 200) {
    $result = json_decode($response, true);
    echo "Payment Link: " . $result['data']['redirectUrl'] . "\n";
} else {
    echo "Error: HTTP $httpCode - $response\n";
}
```

## API Reference

### `generatePayGlocalTokens(array $payload, array $config): array`

Generates both JWE and JWS tokens for payment initiation.

#### Parameters

**$payload** (array, required)
- Payment payload array containing:
  - `merchantTxnId` (string, required) - Unique transaction ID
  - `paymentData` (array, required) - Payment data
    - `totalAmount` (string, required) - Amount as string
    - `txnCurrency` (string, required) - Currency code (e.g., 'INR')
  - `merchantCallbackURL` (string, required) - Callback URL

**$config** (array, required)
- Configuration array containing:
  - `merchantId` (string, required) - Your merchant ID
  - `publicKeyId` (string, required) - PayGlocal public key ID
  - `privateKeyId` (string, required) - Your private key ID
  - `payglocalPublicKey` (string, required) - PayGlocal public key in PEM format
  - `merchantPrivateKey` (string, required) - Your private key in PEM format
  - `tokenExpiration` (int, optional) - Token expiration in milliseconds (default: 300000 = 5 minutes)

#### Returns

Returns an associative array:
```php
[
    'jwe' => 'eyJhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0...',
    'jws' => 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...'
]
```

#### Throws

- `InvalidArgumentException` - If required config or payload fields are missing
- `RuntimeException` - If JWT Framework is not installed or if token generation fails

## Example: Complete Payment Flow

```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

// Step 1: Prepare payment payload
$payload = [
    'merchantTxnId' => 'TXN_' . time(),
    'paymentData' => [
        'totalAmount' => '1000.00',
        'txnCurrency' => 'INR',
    ],
    'merchantCallbackURL' => 'https://yourwebsite.com/callback',
];

// Step 2: Load configuration
$config = [
    'merchantId' => getenv('PAYGLOCAL_MERCHANT_ID'),
    'publicKeyId' => getenv('PAYGLOCAL_PUBLIC_KEY_ID'),
    'privateKeyId' => getenv('PAYGLOCAL_PRIVATE_KEY_ID'),
    'payglocalPublicKey' => file_get_contents(getenv('PAYGLOCAL_PUBLIC_KEY_PATH')),
    'merchantPrivateKey' => file_get_contents(getenv('PAYGLOCAL_PRIVATE_KEY_PATH')),
];

// Step 3: Generate tokens
$tokens = generatePayGlocalTokens($payload, $config);

// Step 4: Make API call
$endpoint = 'https://api.uat.payglocal.in/gl/v1/payments/initiate/paycollect';
$ch = curl_init($endpoint);
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $tokens['jwe'],
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/jose',
        'X-GL-TOKEN-EXTERNAL: ' . $tokens['jws'],
        'X-MERCHANT-ID: ' . $config['merchantId'],
    ],
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

// Step 5: Process response
if ($httpCode === 200) {
    $result = json_decode($response, true);
    // Redirect customer to payment page
    header('Location: ' . $result['data']['redirectUrl']);
    exit;
} else {
    error_log("Payment initiation failed: HTTP $httpCode - $response");
    // Handle error
}
```

## Key File Format

Both public and private keys should be in PEM format:

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
-----END PUBLIC KEY-----
```

or

```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
-----END PRIVATE KEY-----
```

## PHP Version Compatibility

| PHP Version | Status |
|------------|--------|
| 7.2 | ✅ Supported |
| 7.3 | ✅ Supported |
| 7.4 | ✅ Supported |
| 8.0 | ✅ Supported |
| 8.1 | ✅ Supported |
| 8.2 | ✅ Supported |
| 8.3 | ✅ Supported |

## Security Notes

- ⚠️ **Never commit private keys to version control**
- ⚠️ **Store keys securely** - Use environment variables or secure key management
- ⚠️ **Use HTTPS** for all API calls
- ⚠️ **Validate and sanitize** all user inputs before creating payloads

## Troubleshooting

### Error: "JWT Framework not found"

**Solution:** Install the JWT Framework:
```bash
composer require web-token/jwt-framework:^2.1
```

### Error: "Invalid PEM format"

**Solution:** Ensure your keys are in proper PEM format with `-----BEGIN` and `-----END` markers.

### Error: "OpenSSL extension is required"

**Solution:** Install/enable the OpenSSL extension in your PHP installation.

## Support

- Email: support@payglocal.in
- Documentation: [PayGlocal Documentation](https://docs.payglocal.in)

## License

MIT License

## Comparison with Full SDK

| Feature | Minimal SDK (PHP 7.2) | Full SDK (PHP 8.1+) |
|---------|----------------------|---------------------|
| PHP Version | 7.2+ | 8.1+ |
| Token Generation | ✅ | ✅ |
| Payment Initiation | ✅ | ✅ |
| Status Check | ❌ | ✅ |
| Refund | ❌ | ✅ |
| Capture | ❌ | ✅ |
| SI Management | ❌ | ✅ |
| Validation | Basic | Full Schema Validation |
| Logging | ❌ | ✅ |

**Use this minimal SDK if:**
- You only need payment initiation
- You're using PHP 7.2-8.0
- You want minimal dependencies
- You prefer lightweight integration

**Use the full SDK if:**
- You need all payment features (status, refund, capture, SI)
- You're using PHP 8.1+
- You want comprehensive validation and logging

