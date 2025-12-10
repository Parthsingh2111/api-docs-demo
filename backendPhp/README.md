# PayGlocal PHP Backend

Simple PHP backend for PayGlocal payment gateway integration.

## File Structure

```
backendPhp/
├── keys/
│   ├── payglocal_public_key
│   └── payglocal_private_key
├── .env
└── index.php
```

## Setup

1. Install SDK:
```bash
git clone https://github.com/Parthsingh2111/pg-client-sdk-php.git
cd pg-client-sdk-php
composer install
cd ..
```

2. Create .env file:
```bash
cp env.php .env
# Edit .env with your PayGlocal credentials
```

3. Start server:
```bash
./start-server.sh
```

## Complete index.php Example

Copy this code into your `index.php` file:

```php
<?php

require_once __DIR__ . '/pg-client-sdk-php/vendor/autoload.php';

use PayGlocal\PgClientSdk\PayGlocalClient;

// CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin, ngrok-skip-browser-warning');
header('Content-Type: application/json');
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Load environment variables
$envPath = __DIR__ . '/.env';
if (file_exists($envPath)) {
    foreach (file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (strpos($line, '=') !== false && strpos(ltrim($line), '#') !== 0) {
            [$k, $v] = explode('=', $line, 2);
            $_ENV[trim($k)] = trim($v);
        }
    }
}

// Read PEM keys
function readPemFromEnv(?string $value, string $baseDir): string {
    $val = $value ?? '';
    if ($val === '') return '';
    if (strpos($val, '-----BEGIN') !== false) return $val;
    if (file_exists($val)) return (string)file_get_contents($val);
    $rel = rtrim($baseDir, '/').'/'.ltrim($val, '/');
    if (file_exists($rel)) return (string)file_get_contents($rel);
    return '';
}

$payglocalPublicKey = readPemFromEnv($_ENV['PAYGLOCAL_PUBLIC_KEY'] ?? '', __DIR__);
$merchantPrivateKey = readPemFromEnv($_ENV['PAYGLOCAL_PRIVATE_KEY'] ?? '', __DIR__);

// Initialize PayGlocal client
$client = new PayGlocalClient([
    'apiKey' => $_ENV['PAYGLOCAL_API_KEY'] ?? '',
    'merchantId' => $_ENV['PAYGLOCAL_MERCHANT_ID'] ?? '',
    'publicKeyId' => $_ENV['PAYGLOCAL_PUBLIC_KEY_ID'] ?? '',
    'privateKeyId' => $_ENV['PAYGLOCAL_PRIVATE_KEY_ID'] ?? '',
    'payglocalPublicKey' => $payglocalPublicKey,
    'merchantPrivateKey' => $merchantPrivateKey,
    'payglocalEnv' => $_ENV['PAYGLOCAL_Env_VAR'] ?? 'UAT',
    'logLevel' => $_ENV['PAYGLOCAL_LOG_LEVEL'] ?? 'info',
]);

// Helper functions
function respond(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}

function inputJson(): array {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

// Get request details
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
$query = [];
parse_str(parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_QUERY) ?? '', $query);
$input = inputJson();

// Example payload for JWT payment
$payload = [
    "merchantTxnId" => "TXN_" . time(),
    "paymentData" => [
        "totalAmount" => "100.00",
        "txnCurrency" => "INR",
        "billingData" => [
            "firstName" => "John",
            "lastName" => "Doe",
            "emailId" => "john.doe@example.com",
            "mobileNo" => "9876543210",
            "address1" => "123 Main Street",
            "city" => "Mumbai",
            "state" => "Maharashtra",
            "postalCode" => "400001",
            "country" => "IN"
        ]
    ],
    "merchantCallbackURL" => "https://your-domain.com/callback"
];

// Process JWT payment
try {
    echo "=== PayGlocal JWT Payment Example ===\n";
    echo "Payload: " . json_encode($payload, JSON_PRETTY_PRINT) . "\n\n";
    
    $payment = $client->initiateJwtPayment($payload);
    
    echo "=== SDK Response ===\n";
    echo json_encode($payment, JSON_PRETTY_PRINT) . "\n\n";
    
    $paymentLink = $payment['data']['redirectUrl'] ?? $payment['data']['redirect_url'] ?? $payment['data']['payment_link'] ?? $payment['data']['paymentLink'] ?? $payment['redirectUrl'] ?? $payment['redirect_url'] ?? $payment['payment_link'] ?? $payment['paymentLink'] ?? null;
    $gid = $payment['data']['gid'] ?? $payment['data']['transactionId'] ?? $payment['gid'] ?? $payment['transactionId'] ?? null;
    
    if (!$paymentLink || !$gid) {
        respond(500, [
            'status' => 'FAILURE',
            'message' => 'Payment initiation failed: missing payment link or transaction ID',
            'raw_response' => $payment
        ]);
    }
    
    respond(200, [
        'status' => 'SUCCESS',
        'message' => 'Payment initiated successfully',
        'payment_link' => $paymentLink,
        'gid' => $gid,
        'raw_response' => $payment
    ]);
    
} catch (\Exception $e) {
    echo "=== Error ===\n";
    echo "Error: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n\n";
    
    respond(500, [
        'status' => 'ERROR',
        'message' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
?>
```

## Environment Configuration (.env)

```env
# Server Configuration
PORT=3001

# PayGlocal Configuration
PAYGLOCAL_API_KEY=your_api_key_here
PAYGLOCAL_MERCHANT_ID=your_merchant_id_here
PAYGLOCAL_PUBLIC_KEY_ID=payglocal_public_key_id_here
PAYGLOCAL_PRIVATE_KEY_ID=your_private_key_id_here

# Key File Paths
PAYGLOCAL_PUBLIC_KEY=keys/payglocal_public_key
PAYGLOCAL_PRIVATE_KEY=keys/payglocal_private_key

# Environment (UAT or PROD)
PAYGLOCAL_Env_VAR=UAT

# Log Level
PAYGLOCAL_LOG_LEVEL=info
```

## Usage

1. Copy the `index.php` code above
2. Configure your `.env` file with PayGlocal credentials
3. Place PEM keys in `keys/` directory
4. Run: `./start-server.sh`
5. Open: `http://localhost:3001`

The example will automatically process a JWT payment and display the complete response in console and JSON format.

## Response

The server will return:
- Payment link for redirection
- Transaction ID (gid)
- Complete raw response from PayGlocal
- Console logs showing payload and response


