<?php
/**
 * PayGlocal Token Generator - Simple Example
 * 
 * This example shows how to generate JWE and JWS tokens
 * and use them to initiate a payment.
 */

require_once __DIR__ . '/vendor/autoload.php';

// Load configuration from environment or config file
$config = [
    'merchantId' => $_ENV['PAYGLOCAL_MERCHANT_ID'] ?? 'your_merchant_id',
    'publicKeyId' => $_ENV['PAYGLOCAL_PUBLIC_KEY_ID'] ?? 'your_public_key_id',
    'privateKeyId' => $_ENV['PAYGLOCAL_PRIVATE_KEY_ID'] ?? 'your_private_key_id',
    'payglocalPublicKey' => file_get_contents($_ENV['PAYGLOCAL_PUBLIC_KEY_PATH'] ?? __DIR__ . '/keys/payglocal_public_key.pem'),
    'merchantPrivateKey' => file_get_contents($_ENV['PAYGLOCAL_PRIVATE_KEY_PATH'] ?? __DIR__ . '/keys/merchant_private_key.pem'),
];

// Step 1: Prepare payment payload
$payload = [
    'merchantTxnId' => 'TXN_' . time(),
    'paymentData' => [
        'totalAmount' => '1000.00',
        'txnCurrency' => 'INR',
    ],
    'merchantCallbackURL' => 'https://yourwebsite.com/callback',
];

// Step 2: Generate tokens
try {
    echo "Generating tokens...\n";
    $tokens = generatePayGlocalTokens($payload, $config);
    
    $jwe = $tokens['jwe'];
    $jws = $tokens['jws'];
    
    echo "✅ Tokens generated successfully!\n";
    echo "JWE Token: " . substr($jwe, 0, 50) . "...\n";
    echo "JWS Token: " . substr($jws, 0, 50) . "...\n\n";
    
    // Step 3: Make payment initiation API call
    echo "Initiating payment...\n";
    $endpoint = 'https://api.uat.payglocal.in/gl/v1/payments/initiate/paycollect';
    
    $ch = curl_init($endpoint);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $jwe,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/jose',
            'X-GL-TOKEN-EXTERNAL: ' . $jws,
            'X-MERCHANT-ID: ' . $config['merchantId'],
        ],
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);
    
    if ($curlError) {
        throw new \Exception("cURL Error: $curlError");
    }
    
    if ($httpCode === 200) {
        $result = json_decode($response, true);
        echo "✅ Payment initiated successfully!\n";
        echo "Payment Link: " . ($result['data']['redirectUrl'] ?? 'N/A') . "\n";
        echo "Global ID (gid): " . ($result['gid'] ?? 'N/A') . "\n";
    } else {
        echo "❌ Payment initiation failed!\n";
        echo "HTTP Code: $httpCode\n";
        echo "Response: $response\n";
    }
    
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack Trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}

