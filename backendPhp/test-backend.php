<!-- // JWT based payment method (matches Node.js exactly)
function createJwtPayment($client) {
    try {
        $response = $client->initiateJwtPayment([
            'merchantTxnId' => 'TXN_' . time(),
            'paymentData' => [
                'totalAmount' => '100.00',
                'txnCurrency' => 'INR',
                'billingData' => [
                    'emailId' => 'customer@example.com'
                ]
            ],
            'merchantCallbackURL' => 'https://your-domain.com/payment/callback'
        ]);

        echo " response received Successfully\n";
        echo "Response: " . json_encode($response) . "\n";
        return $response;
    } catch (Exception $e) {
        echo "Error: Response not received: " . $e->getMessage() . "\n";
        throw $e;
    }
}

// createJwtPayment($client);

// API key based payment method (matches Node.js exactly)
function createApiKeyPayment($client) {
    try {
        $response = $client->initiateApiKeyPayment([
            'merchantTxnId' => 'TXN_' . time(),
            'paymentData' => [
                'totalAmount' => '500.00',
                'txnCurrency' => 'INR',
                'billingData' => [
                    'emailId' => 'customer@example.com'
                ]
            ],
            'merchantCallbackURL' => 'https://your-domain.com/payment/callback'
        ]);

        echo " response received Successfully\n";
        echo "Response: " . json_encode($response) . "\n";
        return $response;
    } catch (Exception $e) {
        echo "Error: Response not received: " . $e->getMessage() . "\n";
        throw $e;
    }
}

// createApiKeyPayment($client);

// SI payment method (matches Node.js exactly)
function createSiPayment($client) {
    try {
        $response = $client->initiateSiPayment([
            'merchantTxnId' => 'SI_TXN_' . time(),
            'paymentData' => [
                'totalAmount' => '1000.00',
                'txnCurrency' => 'INR',
                'billingData' => [
                    'emailId' => 'customer@example.com'
                ]
            ],
            'standingInstruction' => [
                'data' => [
                    'numberOfPayments' => '12',
                    'frequency' => 'MONTHLY',
                    'type' => 'FIXED',
                    'amount' => '1000.00',
                    'startDate' => '2025-09-01'
                ]
            ],
            'merchantCallbackURL' => 'https://your-domain.com/payment/callback'
        ]);

        echo "SI Payment Created\n";
        echo "response: " . json_encode($response) . "\n";
        return $response;
    } catch (Exception $e) {
        echo "SI Payment Failed: " . $e->getMessage() . "\n";
        throw $e;
    }
}

// createSiPayment($client);

// Auth payment method (matches Node.js exactly)
function createAuthPayment($client) {
    try {
        $response = $client->initiateAuthPayment([
            'merchantTxnId' => 'AUTH_TXN_' . time(),
            'paymentData' => [
                'totalAmount' => '2000.00',
                'txnCurrency' => 'INR',
                'billingData' => [
                    'emailId' => 'customer@example.com',
                    'firstName' => 'John',
                    'lastName' => 'Doe'
                ]
            ],
            'captureTxn' => false,
            'merchantCallbackURL' => 'https://your-domain.com/payment/callback'
        ]);

        echo "Auth Payment Created\n";
        echo "response: " . json_encode($response) . "\n";
        return $response;
    } catch (Exception $e) {
        echo "Auth Payment Failed: " . $e->getMessage() . "\n";
        throw $e;
    }
}

if (!$IS_HTTP) {
    // createAuthPayment($client);
}

// Transaction service methods

// Check status method (matches Node.js exactly)
function checkPaymentStatus($client, $gid) {
    try {
        $response = $client->initiateCheckStatus(['gid' => $gid]);
        
        echo "Status Retrieved\n";
        echo "Status: " . ($response['status'] ?? 'N/A') . "\n";
        echo "GID: " . ($response['gid'] ?? 'N/A') . "\n";
        echo "Message: " . ($response['message'] ?? 'N/A') . "\n";
        echo "Raw Response: " . json_encode($response) . "\n";
        
        return $response;
    } catch (Exception $e) {
        echo "Status Check Failed: " . $e->getMessage() . "\n";
        throw $e;
    }
}

// checkPaymentStatus($client, 'gl_o-96b613c2e75e8016fgv40ZrX2');

// Check refund method (matches Node.js exactly)
function refundPayment($client, $gid, $amount = null) {
    try {
        $response = $client->initiateRefund([
            'gid' => $gid,
            'merchantTxnId' => 'REFUND_' . time(),
            'refundType' => $amount ? 'P' : 'F', // P = Partial, F = Full
            'paymentData' => $amount ? ['totalAmount' => $amount] : null
        ]);
 
        echo "Payment Refunded\n";
        echo "Status: " . ($response['status'] ?? 'N/A') . "\n";
        echo "raw response: " . json_encode($response) . "\n";
        return $response;
    } catch (Exception $e) {
        echo "Refund Failed: " . $e->getMessage() . "\n";
        throw $e;
    }
}

// refundPayment($client, 'gl_o-96b613c2e75e8016fgv40ZrX2'); // Replace with actual GID and amount for partial refund

// Auth reversal method (matches Node.js exactly)
function reverseAuth($client, $gid) {
    try {
        $response = $client->initiateAuthReversal([
            'gid' => $gid,
            'merchantTxnId' => 'REVERSAL_' . time()
        ]);

        echo "Auth Reversed\n";
        echo "Status: " . ($response['status'] ?? 'N/A') . "\n";
        echo "response: " . json_encode($response) . "\n";
        
        return $response;
    } catch (Exception $e) {
        echo "Auth Reversal Failed: " . $e->getMessage() . "\n";
        throw $e;
    }
}

// reverseAuth($client, "gl_o-9628ffff042675e9b30Yyv7X2"); // Replace with actual GID

// SI service methods

// SI pause method (matches Node.js exactly)
// IMPORTANT: This method is used to pause the standing instruction, it can be used to pause the SI for a specific date or indefinitely. 
// If you want to pause the SI for a specific date, you can pass the startDate parameter, otherwise you can leave it empty to pause indefinitely.
function pauseStandingInstruction($client, $mandateId, $startDate = null) {
    try {
        $standingInstruction = [
            'action' => 'PAUSE',
            'mandateId' => $mandateId
        ];

        if ($startDate) {
            $standingInstruction['data'] = ['startDate' => $startDate];
        }

        $response = $client->initiatePauseSI([
            'merchantTxnId' => 'PAUSE_SI_' . time(),
            'standingInstruction' => $standingInstruction
        ]);

        echo "SI Paused\n";
        echo "Status: " . ($response['status'] ?? 'N/A') . "\n";
        echo "Raw Response: " . json_encode($response) . "\n";
        return $response;
    } catch (Exception $e) {
        echo "SI Pause Failed: " . $e->getMessage() . "\n";
        throw $e;
    }
}

// pauseStandingInstruction($client, "md_87c381eb-46a9-4936-b05b-7403d02f8758", '20250901'); // Replace with actual Mandate ID and start date

// SI activate method (matches Node.js exactly)
function activateStandingInstruction($client, $mandateId) {
    try {
        $response = $client->initiateActivateSI([
            'merchantTxnId' => 'ACTIVATE_SI_' . time(),
            'standingInstruction' => [
                'action' => 'ACTIVATE',
                'mandateId' => $mandateId
            ]
        ]);

        echo "SI Activated\n";
        echo "Status: " . ($response['status'] ?? 'N/A') . "\n";
        echo "Raw Response: " . json_encode($response) . "\n";
        return $response;
    } catch (Exception $e) {
        echo "SI Activation Failed: " . $e->getMessage() . "\n";
        throw $e;
    }
}

// activateStandingInstruction($client, 'md_87c381eb-46a9-4936-b05b-7403d02f8758'); -->
