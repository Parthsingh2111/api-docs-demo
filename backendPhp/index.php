<?php

require_once __DIR__ . '/pg-client-sdk-php/vendor/autoload.php';

use PayGlocal\PgClientSdk\PayGlocalClient;

// ------- CORS (simple) -------
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin, ngrok-skip-browser-warning');
header('Content-Type: application/json');
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// ------- Env -------
$envPath = __DIR__ . '/.env';
if (file_exists($envPath)) {
    foreach (file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (strpos($line, '=') !== false && strpos(ltrim($line), '#') !== 0) {
            [$k, $v] = explode('=', $line, 2);
            $_ENV[trim($k)] = trim($v);
        }
    }
}

// ------- Keys -------
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
$merchantPrivateKey2 = readPemFromEnv($_ENV['PAYGLOCAL_PRIVATE_KEY2'] ?? '', __DIR__);
// ------- SDK Client -------
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
// for si variable test
$client2 = new PayGlocalClient([
    'apiKey' => $_ENV['PAYGLOCAL_API_KEY2'] ?? '',
    'merchantId' => $_ENV['PAYGLOCAL_MERCHANT_ID2'] ?? '',
    'publicKeyId' => $_ENV['PAYGLOCAL_PUBLIC_KEY_ID2'] ?? '',
    'privateKeyId' => $_ENV['PAYGLOCAL_PRIVATE_KEY_ID2'] ?? '',
    'payglocalPublicKey' => $payglocalPublicKey,
    'merchantPrivateKey' => $merchantPrivateKey2,
    'payglocalEnv' => $_ENV['PAYGLOCAL_Env_VAR2'] ?? 'UAT',
    'logLevel' => $_ENV['PAYGLOCAL_LOG_LEVEL2'] ?? 'info',
]);


// ------- Helpers -------
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

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
$query = [];
parse_str(parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_QUERY) ?? '', $query);
$input = inputJson();

try {
    // ----- POST /api/pay/jwt -----
    if ($method === 'POST' && $path === '/api/pay/jwt') {
        $merchantTxnId = $input['merchantTxnId'] ?? null;
        $paymentData = $input['paymentData'] ?? null;
        $merchantCallbackURL = $input['merchantCallbackURL'] ?? null;
        if (!$merchantTxnId || !$paymentData || !$merchantCallbackURL) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing required fields',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['merchantTxnId', 'paymentData', 'merchantCallbackURL'] ]
            ]);
        }
        $payload = [
            'merchantTxnId' => $merchantTxnId,
            'paymentData' => $paymentData,
            'merchantCallbackURL' => $merchantCallbackURL,
        ];
        $payment = $client->initiateJwtPayment($payload);
        $paymentLink = $payment['data']['redirectUrl']
            ?? ($payment['data']['redirect_url'] ?? ($payment['data']['payment_link']
            ?? ($payment['redirectUrl'] ?? ($payment['redirect_url'] ?? ($payment['payment_link']
            ?? ($payment['data']['paymentLink'] ?? ($payment['paymentLink'] ?? null)))))));
        $gid = $payment['gid'] ?? ($payment['data']['gid'] ?? ($payment['transactionId'] ?? ($payment['data']['transactionId'] ?? null)));
        respond(200, [
            'status' => 'SUCCESS',
            'message' => 'Payment initiated successfully',
            'payment_link' => $paymentLink,
            'gid' => $gid,
            'raw_response' => $payment,
        ]);
    }

    // ----- POST /api/pay/si -----
    if ($method === 'POST' && $path === '/api/pay/si') {
        $merchantTxnId = $input['merchantTxnId'] ?? null;
        $paymentData = $input['paymentData'] ?? null;
        $merchantCallbackURL = $input['merchantCallbackURL'] ?? null;
        $standingInstruction = $input['standingInstruction'] ?? null;
        if (!$merchantTxnId || !$paymentData || !$merchantCallbackURL || !$standingInstruction) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing required fields',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['merchantTxnId', 'paymentData', 'merchantCallbackURL', 'standingInstruction'] ]
            ]);
        }
        $payload = [
            'merchantTxnId' => $merchantTxnId,
            'paymentData' => $paymentData,
            'standingInstruction' => $standingInstruction,
            'merchantCallbackURL' => $merchantCallbackURL,
        ];

        // Choose client based on SI data (Variable vs Fixed)
        $siData = $standingInstruction['data'] ?? [];
        $useClient2ForVariable = is_array($siData) && array_key_exists('maxAmount', $siData) && trim((string)$siData['maxAmount']) !== '';
        $payment = $useClient2ForVariable
            ? $client2->initiateSiPayment($payload)
            : $client->initiateSiPayment($payload);

        $paymentLink = $payment['data']['redirectUrl']
            ?? ($payment['data']['redirect_url'] ?? ($payment['data']['payment_link']
            ?? ($payment['redirectUrl'] ?? ($payment['redirect_url'] ?? ($payment['payment_link']
            ?? ($payment['data']['paymentLink'] ?? ($payment['paymentLink'] ?? null)))))));
        $gid = $payment['gid'] ?? ($payment['data']['gid'] ?? ($payment['transactionId'] ?? ($payment['data']['transactionId'] ?? null)));
        $mandateId = $payment['mandateId'] ?? ($payment['data']['mandateId'] ?? ($payment['standingInstruction']['mandateId'] ?? null));
        respond(200, [
            'status' => 'SUCCESS',
            'message' => 'SI Payment initiated successfully',
            'payment_link' => $paymentLink,
            'gid' => $gid,
            'mandateId' => $mandateId,
            'raw_response' => $payment,
        ]);
    }

    // ----- POST /api/pay/auth -----
    if ($method === 'POST' && $path === '/api/pay/auth') {
        $merchantTxnId = $input['merchantTxnId'] ?? null;
        $paymentData = $input['paymentData'] ?? null;
        $merchantCallbackURL = $input['merchantCallbackURL'] ?? null;
        $captureTxn = $input['captureTxn'] ?? null;
        $riskData = $input['riskData'] ?? null;
        if (!$merchantTxnId || !$paymentData || !$merchantCallbackURL) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing required fields',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['merchantTxnId', 'paymentData', 'merchantCallbackURL'] ]
            ]);
        }
        $payload = [
            'merchantTxnId' => $merchantTxnId,
            'paymentData' => $paymentData,
            'captureTxn' => $captureTxn,
            'riskData' => $riskData,
            'merchantCallbackURL' => $merchantCallbackURL,
        ];
        $payment = $client->initiateAuthPayment($payload);
        $paymentLink = $payment['data']['redirectUrl']
            ?? ($payment['data']['redirect_url'] ?? ($payment['data']['payment_link']
            ?? ($payment['redirectUrl'] ?? ($payment['redirect_url'] ?? ($payment['payment_link']
            ?? ($payment['data']['paymentLink'] ?? ($payment['paymentLink'] ?? null)))))));
        $gid = $payment['gid'] ?? ($payment['data']['gid'] ?? ($payment['transactionId'] ?? ($payment['data']['transactionId'] ?? null)));
        respond(200, [
            'status' => 'SUCCESS',
            'message' => 'Auth Payment initiated successfully',
            'payment_link' => $paymentLink,
            'gid' => $gid,
            'raw_response' => $payment,
        ]);
    }

    // ----- POST /api/refund -----
    if ($method === 'POST' && $path === '/api/refund') {
        $gid = $input['gid'] ?? null;
        $refundType = $input['refundType'] ?? null;
        $paymentData = $input['paymentData'] ?? null;
        if (!$gid) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing gid',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['gid'] ]
            ]);
        }
        if ($refundType === 'P' && (!isset($paymentData['totalAmount']) || $paymentData['totalAmount'] === '')) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing paymentData.totalAmount for partial refund',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['paymentData.totalAmount'] ]
            ]);
        }
        $merchantTxnId = $input['merchantTxnId'] ?? ('REFUND_' . time());
        $payload = [
            'refundType' => $refundType ?? 'F',
            'gid' => $gid,
            'merchantTxnId' => $merchantTxnId,
            'paymentData' => ($refundType === 'F') ? [ 'totalAmount' => 0 ] : [ 'totalAmount' => $paymentData['totalAmount'] ]
        ];
        $refundDetail = $client->initiateRefund($payload);
        $refundGid = $refundDetail['gid'] ?? ($refundDetail['data']['gid'] ?? ($refundDetail['transactionId'] ?? ($refundDetail['data']['transactionId'] ?? null)));
        $refundId = $refundDetail['refundId'] ?? ($refundDetail['data']['refundId'] ?? ($refundDetail['id'] ?? ($refundDetail['data']['id'] ?? null)));
        $status = $refundDetail['status'] ?? ($refundDetail['data']['status'] ?? ($refundDetail['result'] ?? ($refundDetail['data']['result'] ?? null)));
        respond(200, [
            'status' => 'SUCCESS',
            'message' => 'Refund ' . ($status ? strtolower($status) : 'initiated') . ' successfully',
            'gid' => $refundGid,
            'refundId' => $refundId,
            'transactionStatus' => $status,
            'raw_response' => $refundDetail,
        ]);
    }

    // ----- POST /api/cap -----
    if ($method === 'POST' && $path === '/api/cap') {
        $gid = $query['gid'] ?? null;
        $captureType = $input['captureType'] ?? null;
        $paymentData = $input['paymentData'] ?? null;
        if (!$gid) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing gid',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['gid'] ]
            ]);
        }
        if ($captureType === 'P' && (!isset($paymentData['totalAmount']) || $paymentData['totalAmount'] === '')) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing paymentData.totalAmount for partial capture',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['paymentData.totalAmount'] ]
            ]);
        }
        $merchantTxnId = $input['merchantTxnId'] ?? ('CAPTURE_' . time());
        $payload = ($captureType === 'F')
            ? [ 'captureType' => 'F', 'gid' => $gid, 'merchantTxnId' => $merchantTxnId ]
            : [ 'captureType' => 'P', 'gid' => $gid, 'merchantTxnId' => $merchantTxnId, 'paymentData' => [ 'totalAmount' => $paymentData['totalAmount'] ] ];
        $payment = $client->initiateCapture($payload);
        respond(200, [
            'status' => 'SUCCESS',
            'transactionStatus' => $captureStatus,
            'raw_response' => $payment,
        ]);
    }

    // ----- POST /api/authreversal -----
    if ($method === 'POST' && $path === '/api/authreversal') {
        $gid = $query['gid'] ?? null;
        if (!$gid) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing gid',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['gid'] ]
            ]);
        }
        $payload = [ 'gid' => $gid, 'merchantTxnId' => ($input['merchantTxnId'] ?? ('REVERSAL_' . time())) ];
        $payment = $client->initiateAuthReversal($payload);
        respond(200, [
            'status' => 'SUCCESS',
            'raw_response' => $payment,
        ]);
    }

    // ----- GET /api/status -----
    if ($method === 'GET' && $path === '/api/status') {
        $gid = $query['gid'] ?? null;
        if (!$gid) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing gid',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['gid'] ]
            ]);
        }
        $payment = $client->initiateCheckStatus([ 'gid' => $gid ]);
        respond(200, [
            'status' => 'SUCCESS',
            'raw_response' => $payment,
        ]);
    }

    // ----- POST /api/pauseActivate -----
    if ($method === 'POST' && $path === '/api/pauseActivate') {
        $standingInstruction = $input['standingInstruction'] ?? null;
        if (!$standingInstruction) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing standingInstruction',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['standingInstruction'] ]
            ]);
        }

        if (!isset($standingInstruction['action']) || !isset($standingInstruction['mandateId'])) {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing action or mandateId in standingInstruction',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['standingInstruction.action', 'standingInstruction.mandateId'] ]
            ]);
        }

        $payload = [
            'merchantTxnId' => $input['merchantTxnId'] ?? '1100pauseActivate011',
            'standingInstruction' => $standingInstruction,
        ];

        error_log('payload: ' . json_encode($payload));
        echo 'payload: ' . json_encode($payload);
          

        $action = strtoupper($standingInstruction['action']);
        if ($action === 'PAUSE') {
            $response = $client->initiatePauseSI($payload);
        } elseif ($action === 'ACTIVATE') {
            $response = $client->initiateActivateSI($payload);
        } else {
            respond(400, [
                'status' => 'error',
                'message' => 'Unsupported action: ' . $standingInstruction['action'],
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'supportedActions' => ['PAUSE', 'ACTIVATE'] ]
            ]);
        }

        $siMandateId = $response['mandateId'] ?? ($response['data']['mandateId'] ?? ($response['standingInstruction']['mandateId'] ?? null));
        $siStatus = $response['status'] ?? ($response['data']['status'] ?? ($response['result'] ?? ($response['data']['result'] ?? null)));

        respond(200, [
            'status' => 'SUCCESS',
            'message' => 'SI ' . $action . ' ' . ($siStatus ? strtolower($siStatus) : 'completed') . ' successfully',
            'mandateId' => $siMandateId,
            'action' => $standingInstruction['action'],
            'transactionStatus' => $siStatus,
            'raw_response' => $response,
        ]);
    }

    // ----- POST /api/siOnDemand -----
    if ($method === 'POST' && $path === '/api/siOnDemand') {
        $paymentData = $input['paymentData'] ?? [];
        $standingInstruction = $input['standingInstruction'] ?? null;

        if (!$standingInstruction || !isset($standingInstruction['mandateId']) || $standingInstruction['mandateId'] === '') {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing required fields',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['standingInstruction.mandateId'] ]
            ]);
        }

        $hasAmount = is_array($paymentData)
            && array_key_exists('totalAmount', $paymentData)
            && trim((string)$paymentData['totalAmount']) !== '';

        $payload = $hasAmount
            ? [
                'merchantTxnId' => 'SI_ON_DEMAND_' . time(),
                'paymentData' => [ 'totalAmount' => $paymentData['totalAmount'] ],
                'standingInstruction' => [ 'mandateId' => $standingInstruction['mandateId'] ],
            ]
            : [
                'merchantTxnId' => 'SI_ON_DEMAND_' . time(),
                'standingInstruction' => [ 'mandateId' => $standingInstruction['mandateId'] ],
            ];

        // Call appropriate SDK method
        if ($hasAmount) {
            $response = $client2->initiateSiOnDemandVariable($payload);
        } else {
            $response = $client->initiateSiOnDemandFixed($payload);
        }

        $status = $response['status']
            ?? ($response['data']['status'] ?? ($response['result'] ?? ($response['data']['result'] ?? 'SUCCESS')));
        $respMandateId = $response['mandateId']
            ?? ($response['data']['mandateId'] ?? ($standingInstruction['mandateId'] ?? null));

        respond(200, [
            'status' => 'SUCCESS',
            'message' => 'SI on-demand ' . strtolower((string)$status),
            'mandateId' => $respMandateId,
            'raw_response' => $response,
        ]);
    }

    // ----- POST /api/siStatus -----
    if ($method === 'POST' && $path === '/api/siStatus') {
        $standingInstruction = $input['standingInstruction'] ?? null;
        if (!$standingInstruction || !isset($standingInstruction['mandateId']) || $standingInstruction['mandateId'] === '') {
            respond(400, [
                'status' => 'error',
                'message' => 'Missing required fields',
                'code' => 'VALIDATION_ERROR',
                'details' => [ 'requiredFields' => ['standingInstruction.mandateId'] ]
            ]);
        }

        $payload = [
            'merchantTxnId' => 'SI_Status_' . time(),
            'standingInstruction' => [ 'mandateId' => $standingInstruction['mandateId'] ]
        ];
        $response = $client->initiateSiStatusCheck($payload);

        $siMandateId = $response['mandateId']
            ?? ($response['data']['mandateId'] ?? ($standingInstruction['mandateId'] ?? null));
        $siStatus = $response['status']
            ?? ($response['data']['status'] ?? ($response['result'] ?? ($response['data']['result'] ?? null)));

        $formatted = [
            'status' => 'SUCCESS',
            'message' => 'SI status ' . ($siStatus ? strtolower((string)$siStatus) : 'retrieved'),
            'mandateId' => $siMandateId,
            'transactionStatus' => $siStatus,
            'raw_response' => $response,
        ];

        error_log('SI status response: ' . json_encode($formatted));
        respond(200, $formatted);
    }

    respond(404, [ 'status' => 'error', 'message' => 'Not Found' ]);
} catch (Throwable $e) {
    respond(500, [ 'status' => 'error', 'message' => $e->getMessage() ]);
}




// $payload = [
//     "merchantTxnId" => "TXN_1757006600853",
//     "paymentData"  => [
//         "totalAmount" => "999.00",
//         "txnCurrency" => "INR",
//         "tokenData" => [
//             "altId" => "true",
//             "number" => "4039073788299302",
//             "expiryMonth" => "07",
//             "expiryYear" => "2026",
//             "securityCode" => "322",
//             "cryptogram" => "BASE64_CRYPTOGRAM_SAMPLE",
//             "requestorID" => "REQ123456",
//             "hashOfFirstSix" => "HASH123ABC",
//             "firstSix" => "403907",
//             "lastFour" => "9302",
//             "cardBrand" => "visa",
//             "cardCountryCode" => "USA",
//             "cardIssuerName" => "HDFC Bank",
//             "cardType" => "Debit",
//             "cardCategory" => "Classic"
//         ],
//         "billingData" => [
//             "firstName" => "John",
//             "lastName" => "Denver",
//             "emailId" => "john.denver@example.com",
//             "mobileNo" => "9008018469",
//             "address1" => "Rowley street 1",
//             "address2" => "Punctuality lane",
//             "city" => "Bangalore",
//             "state" => "Karnataka",
//             "postalCode" => "560094",
//             "country" => "IN"
//         ]
//     ],
//     "merchantCallbackURL" => "https://your-domain.com/callback"
// ];



// $payload = [
//     "merchantTxnId" => "1756728697873338303",
//     "captureTxn" => false,
//     "paymentData" => [
//         "totalAmount" => "117800.00",
//         "txnCurrency" => "INR"
//     ],
//     "riskData" => [
//         "flightData" => [
//             [
//                 "journeyType" => "ONEWAY",
//                 "reservationDate" => "20250901",
//                 "legData" => [
//                     [
//                         "routeId" => "1",
//                         "legId" => "1",
//                         "flightNumber" => "BA112",
//                         "departureAirportCode" => "BLR",
//                         "departureCity" => "Bengaluru",
//                         "departureDate" => "2025-09-01T03:45:00Z",
//                         "arrivalAirportCode" => "LAX",
//                         "arrivalCity" => "Los Angeles",
//                         "arrivalDate" => "2025-09-01T13:15:00Z",
//                         "carrierCode" => "B7",
//                         "serviceClass" => "ECONOMY"
//                     ]
//                 ],
//                 "passengerData" => [
//                     [
//                         "firstName" => "Sam",
//                         "lastName" => "Thomas"
//                     ]
//                 ]
//             ]
//         ]
//     ],
//     "merchantCallbackURL" => "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// ];



// $payload = [
//     "merchantTxnId" => "1756728697873338303",
//     "captureTxn" => false,
//     "paymentData" => [
//         "totalAmount" => "117800.00",
//         "txnCurrency" => "INR"
//     ],
//     "riskData" => [
//         "flightData" => [
//             [
//                 "journeyType" => "ONEWAY",
//                 "reservationDate" => "20250901",
//                 "legData" => [
//                     [
//                         "routeId" => "1",
//                         "legId" => "1",
//                         "flightNumber" => "BA112",
//                         "departureAirportCode" => "BLR",
//                         "departureCity" => "Bengaluru",
//                         "departureDate" => "2025-09-01T03:45:00Z",
//                         "arrivalAirportCode" => "LAX",
//                         "arrivalCity" => "Los Angeles",
//                         "arrivalDate" => "2025-09-01T13:15:00Z",
//                         "carrierCode" => "B7",
//                         "serviceClass" => "ECONOMY"
//                     ]
//                 ],
//                 "passengerData" => [
//                     [
//                         "firstName" => "Sam",
//                         "lastName" => "Thomas"
//                     ]
//                 ]
//             ]
//         ]
//     ],
//     "merchantCallbackURL" => "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// ];



// $payload = [
//     "merchantTxnId" => "TXN_1756806272401",
//     "paymentData" => [
//         "totalAmount" => "12000.00",
//         "txnCurrency" => "INR"
//     ],
//     "merchantCallbackURL" => "https://your-domain.com/callback",
//     "riskData" => [
//         "lodgingData" => [
//             [
//                 "checkInDate" => "20250104",
//                 "checkOutDate" => "20250106",
//                 "city" => "Mumbai",
//                 "country" => "IN",
//                 "lodgingType" => "Hotel",
//                 "lodgingName" => "Lake View",
//                 "rating" => "4",
//                 "cancellationPolicy" => "NC",
//                 "bookingPersonFirstName" => "John",
//                 "bookingPersonLastName" => "Bell",
//                 "bookingPersonEmailId" => "john.bell@example.com",
//                 "bookingPersonPhoneNumber" => "2011915716",
//                 "bookingPersonCallingCode" => "+91",
//                 "rooms" => [
//                     [
//                         "numberOfGuests" => "2",
//                         "roomType" => "Twin",
//                         "roomCategory" => "Deluxe",
//                         "numberOfNights" => "2",
//                         "roomPrice" => "3200",
//                         "guestFirstName" => "Ricky",
//                         "guestLastName" => "Martin",
//                         "guestEmail" => "ricky.martin@example.com"
//                     ]
//                 ]
//             ]
//         ]
//     ]
// ];



// $payload = [
//     "merchantTxnId" => "1756728697873338303",
//     "captureTxn" => false,
//     "paymentData" => [
//         "totalAmount" => "117800.00",
//         "txnCurrency" => "INR"
//     ],
//     "riskData" => [
//         "cabData" => [
//             [
//                 "legData" => [
//                     [
//                         "routeId" => "1",
//                         "legId" => "1",
//                         "pickupDate" => "2023-03-20T09:01:56Z"
//                     ]
//                 ],
//                 "passengerData" => [
//                     [
//                         "firstName" => "Sam",
//                         "lastName" => "Thomas"
//                     ]
//                 ]
//             ]
//         ]
//     ],
//     "legData" => [
//         [
//             "routeId" => "1",
//             "legId" => "1",
//             "pickupDate" => "2023-03-20T09:01:56Z"
//         ]
//     ],
//     "merchantCallbackURL" => "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// ];



// $payload = [
//     "merchantTxnId" => "1756728697873338303",
//     "captureTxn" => false,
//     "paymentData" => [
//         "totalAmount" => "117800.00",
//         "txnCurrency" => "INR"
//     ],
//     "riskData" => [
//         "passengerData" => [
//             [
//                 "firstName" => "Sam",
//                 "lastName" => "Thomas",
//                 "dateOfBirth" => "19980320",
//                 "passportCountry" => "IN"
//             ]
//             ]
//     ],


//         "trainData" => [
//             [
//                 "ticketNumber" => "ticket12346",
//                 "reservationDate" => "20230220",
//                 "legData" => [
//                     [
//                         "routeId" => "1",
//                         "legId" => "1",
//                         "trainNumber" => "train123",
//                         "departureCity" => "Kannur",
//                         "departureCountry" => "IN",
//                         "departureDate" => "2023-03-20T09:01:56Z",
//                         "arrivalCity" => "Coimbatore",
//                         "arrivalCountry" => "IN",
//                         "arrivalDate" => "2023-03-21T09:01:56Z"
//                     ]
//                 ],
                
//             ]
//             ],


//     "merchantCallbackURL" => "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// ];


// $payload = [
//     "merchantTxnId" => "1756728757520948273",
//     "paymentData" => [
//         "totalAmount" => "499.00",
//         "txnCurrency" => "INR"
//     ],
//     "standingInstruction" => [
//         "data" => [
//             "amount" => "499.00",
//             "numberOfPayments" => "12",
//             "frequency" => "MONTHLY",
//             "type" => "FIXED",
//             "startDate" => "20251001"
//         ]
//     ],
//     "merchantCallbackURL" => "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// ];



// $payload = [
//     "merchantTxnId" => "23AEE8CB6B62EE2AF07",
//     "paymentData" => [
//         "totalAmount" => "15",
//         "txnCurrency" => "USD",
//         "billingData" => [
//             "firstName" => "John",
//             "lastName" => "Denver",
//             "addressStreet1" => "Test123",
//             "addressStreet2" => "Punctuality lane",
//             "addressCity" => "Bangalore",
//             "addressState" => "Karnataka",
//             "addressPostalCode" => "560094",
//             "addressCountry" => "IN",
//             "emailId" => "johndenver@myemail.com"
//         ]
//     ],


//     // "shippingData" => [
//     //     "firstName" => "John",
//     //     "lastName" => "Denver",
//     //     "addressStreet1" => "Test123",
//     //     "addressStreet2" => "Punctuality lane",
//     //     "addressCity" => "Bangalore",
//     //     "addressState" => "Karnataka",
//     //     "addressPostalCode" => "560094",
//     //     "addressCountry" => "IN",
//     //     "emailId" => "johndenver@myemail.com",
//     //     "callingCode" => "+91",
//     //     "phoneNumber" => "9008018469"
//     // ],


// //     "riskData" => [
// //         "shippingData" => [
// //             "firstName" => "John",
// //             "lastName" => "Denver",
// //             "addressStreet1" => "Test123",
// //             "addressStreet2" => "Punctuality lane",
// //             "addressCity" => "Bangalore",
// //             "addressState" => "Karnataka",
// //             "addressPostalCode" => "560094",
// //             "addressCountry" => "IN",
// //             "emailId" => "johndenver@myemail.com",
// //             "callingCode" => "+91",
// //             "phoneNumber" => "9008018469"
// //         ]
// //     ],
// //     "merchantCallbackURL" => "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// // ];



// // // ------- Initiate Payment -------
// // try {
// //     $payment = $client->initiateJwtPayment($payload);

// //     // Debug log if needed
// //     // file_put_contents('payment_debug.log', print_r($payment, true));

// //     $paymentLink = $payment['data']['redirectUrl'] ?? $payment['data']['redirect_url'] ?? $payment['data']['payment_link'] ?? $payment['data']['paymentLink'] ?? $payment['redirectUrl'] ?? $payment['redirect_url'] ?? $payment['payment_link'] ?? $payment['paymentLink'] ?? null;

// //     $gid = $payment['data']['gid'] ?? $payment['data']['transactionId'] ?? $payment['gid'] ?? $payment['transactionId'] ?? null;

// //     if (!$paymentLink || !$gid) {
// //         respond(500, [
// //             'status' => 'FAILURE',
// //             'message' => 'Payment initiation failed: missing payment link or transaction ID',
// //             'raw_response' => $payment
// //         ]);
// //     }

// //     respond(200, [
// //         'raw_response' => $payment
// //     ]);

// // } catch (\Exception $e) {
// //     respond(500, [
// //         'status' => 'ERROR',
// //         'message' => $e->getMessage(),
// //         'trace' => $e->getTraceAsString()
// //     ]);
// // }




// initiatePauseSI


// $payload = [
//     "merchantTxnId" => "1756728757520948273",
    
//     // "paymentData" => [
//     //     "totalAmount" => "499.00",
//     //     "txnCurrency" => "INR"
//     // ],
//     "standingInstruction" => [
//         "action" => "PAUSE",
//         "mandateId" => "md_5a66cb71-9fa2-4152-9d2a-4e16e932c751"
//     ],
//     // "merchantCallbackURL" => "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
// ];

//     const standingInstruction = {
//       action: 'PAUSE',
//       mandateId
//     };

//     if (startDate) {
//       standingInstruction.data = { startDate };
//     }

//     const response = await client.initiatePauseSI({
//       merchantTxnId: 'PAUSE_SI_' + Date.now(),
//       standingInstruction
//     });




// ------- Initiate Payment -------
// try {
//     $client->initiatePauseSI($payload);

//     // Debug log if needed
//     // file_put_contents('payment_debug.log', print_r($payment, true));

//     // $paymentLink = $payment['data']['redirectUrl'] ?? $payment['data']['redirect_url'] ?? $payment['data']['payment_link'] ?? $payment['data']['paymentLink'] ?? $payment['redirectUrl'] ?? $payment['redirect_url'] ?? $payment['payment_link'] ?? $payment['paymentLink'] ?? null;

//     // $gid = $payment['data']['gid'] ?? $payment['data']['transactionId'] ?? $payment['gid'] ?? $payment['transactionId'] ?? null;

//     // if (!$paymentLink || !$gid) {
//     //     respond(500, [
//     //         'status' => 'FAILURE',
//     //         'message' => 'Payment initiation failed: missing payment link or transaction ID',
// //             'raw_response' => $payment
// //         ]);
// //     }

//     respond(200, [
//         'raw_response' => $client
//     ]);

// } catch (\Exception $e) {
//     respond(500, [
//         'status' => 'ERROR',
//         'message' => $e->getMessage(),
//         'trace' => $e->getTraceAsString()
//     ]);
// }






