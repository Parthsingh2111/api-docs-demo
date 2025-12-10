<?php
/**
 * PayGlocal Token Generator for PHP 7.2+
 * 
 * Minimal lightweight token generator for payment initiation.
 * Only generates JWE and JWS tokens - no other dependencies.
 * 
 * Usage:
 *   $tokens = generatePayGlocalTokens($payload, $config);
 *   $jwe = $tokens['jwe'];
 *   $jws = $tokens['jws'];
 */

// Check PHP version
if (version_compare(PHP_VERSION, '7.2.0', '<')) {
    throw new \RuntimeException('PayGlocal Token Generator requires PHP 7.2 or higher. Current version: ' . PHP_VERSION);
}

// Check required extensions
if (!extension_loaded('openssl')) {
    throw new \RuntimeException('OpenSSL extension is required');
}
if (!extension_loaded('json')) {
    throw new \RuntimeException('JSON extension is required');
}

/**
 * Generate JWE and JWS tokens for PayGlocal payment initiation
 * 
 * @param array $payload Payment payload array
 * @param array $config Configuration array with:
 *   - merchantId: string (required)
 *   - publicKeyId: string (required)
 *   - privateKeyId: string (required)
 *   - payglocalPublicKey: string (PEM format, required)
 *   - merchantPrivateKey: string (PEM format, required)
 *   - tokenExpiration: int (optional, default: 300000 milliseconds = 5 minutes)
 * 
 * @return array Returns ['jwe' => string, 'jws' => string]
 * @throws \Exception
 */
function generatePayGlocalTokens(array $payload, array $config): array
{
    // Validate required config
    $required = ['merchantId', 'publicKeyId', 'privateKeyId', 'payglocalPublicKey', 'merchantPrivateKey'];
    foreach ($required as $key) {
        if (empty($config[$key])) {
            throw new \InvalidArgumentException("Missing required config: $key");
        }
    }

    $merchantId = $config['merchantId'];
    $publicKeyId = $config['publicKeyId'];
    $privateKeyId = $config['privateKeyId'];
    $payglocalPublicKey = $config['payglocalPublicKey'];
    $merchantPrivateKey = $config['merchantPrivateKey'];
    $tokenExpiration = $config['tokenExpiration'] ?? 300000; // 5 minutes default

    // Generate JWE token
    $jwe = generateJWE($payload, [
        'merchantId' => $merchantId,
        'publicKeyId' => $publicKeyId,
        'payglocalPublicKey' => $payglocalPublicKey,
        'tokenExpiration' => $tokenExpiration,
    ]);

    // Generate JWS token (using JWE as input)
    $jws = generateJWS($jwe, [
        'merchantId' => $merchantId,
        'privateKeyId' => $privateKeyId,
        'merchantPrivateKey' => $merchantPrivateKey,
        'tokenExpiration' => $tokenExpiration,
    ]);

    return [
        'jwe' => $jwe,
        'jws' => $jws,
    ];
}

/**
 * Generate JWE (JSON Web Encryption) token
 * Uses RSA-OAEP-256 for key encryption and A128CBC-HS256 for content encryption
 * 
 * @param array $payload Payload to encrypt
 * @param array $config Configuration
 * @return string JWE token in compact format
 * @throws \Exception
 */
function generateJWE(array $payload, array $config): string
{
    // Load JWT Framework classes if available (composer autoload)
    if (!class_exists('Jose\\Component\\Core\\AlgorithmManager')) {
        throw new \RuntimeException(
            'JWT Framework not found. Please install: composer require web-token/jwt-framework:^2.1'
        );
    }

    $iat = time() * 1000; // milliseconds
    $exp = $iat + $config['tokenExpiration'];

    // Parse public key
    $publicKeyPem = $config['payglocalPublicKey'];
    if (empty($publicKeyPem) || strpos($publicKeyPem, '-----BEGIN') === false) {
        throw new \InvalidArgumentException('Invalid PayGlocal public key format');
    }

    try {
        // Use JWT Framework v2.x (PHP 7.2 compatible)
        $keyEncryptionAlgorithmManager = new \Jose\Component\Core\AlgorithmManager([
            new \Jose\Component\Encryption\Algorithm\KeyEncryption\RSAOAEP256(),
        ]);
        
        $contentEncryptionAlgorithmManager = new \Jose\Component\Core\AlgorithmManager([
            new \Jose\Component\Encryption\Algorithm\ContentEncryption\A128CBCHS256(),
        ]);

        $jweBuilder = new \Jose\Component\Encryption\JWEBuilder(
            $keyEncryptionAlgorithmManager,
            $contentEncryptionAlgorithmManager
        );

        // Create JWK from PEM
        $publicKey = \Jose\Component\KeyManagement\JWKFactory::createFromKey($publicKeyPem);

        // Build JWE
        $jwe = $jweBuilder
            ->create()
            ->withPayload(json_encode($payload))
            ->withSharedProtectedHeader([
                'alg' => 'RSA-OAEP-256',
                'enc' => 'A128CBC-HS256',
                'iat' => (string)$iat,
                'exp' => (string)$exp,
                'kid' => $config['publicKeyId'],
                'issued-by' => $config['merchantId'],
            ])
            ->addRecipient($publicKey)
            ->build();

        // Serialize to compact format
        $serializer = new \Jose\Component\Encryption\Serializer\CompactSerializer();
        return $serializer->serialize($jwe, 0);

    } catch (\Exception $e) {
        throw new \RuntimeException('JWE generation failed: ' . $e->getMessage(), 0, $e);
    }
}

/**
 * Generate JWS (JSON Web Signature) token
 * Uses RS256 (RSA signature with SHA-256)
 * 
 * @param string $toDigest Input string to sign (typically the JWE token)
 * @param array $config Configuration
 * @return string JWS token in compact format
 * @throws \Exception
 */
function generateJWS(string $toDigest, array $config): string
{
    // Load JWT Framework classes if available
    if (!class_exists('Jose\\Component\\Core\\AlgorithmManager')) {
        throw new \RuntimeException(
            'JWT Framework not found. Please install: composer require web-token/jwt-framework:^2.1'
        );
    }

    $iat = time() * 1000; // milliseconds
    $exp = $iat + $config['tokenExpiration'];

    // Create digest
    $digest = base64_encode(hash('sha256', $toDigest, true));
    $digestObject = [
        'digest' => $digest,
        'digestAlgorithm' => 'SHA-256',
        'exp' => $exp,
        'iat' => (string)$iat,
    ];

    // Parse private key
    $privateKeyPem = $config['merchantPrivateKey'];
    if (empty($privateKeyPem) || strpos($privateKeyPem, '-----BEGIN') === false) {
        throw new \InvalidArgumentException('Invalid merchant private key format');
    }

    try {
        // Use JWT Framework v2.x (PHP 7.2 compatible)
        $algorithmManager = new \Jose\Component\Core\AlgorithmManager([
            new \Jose\Component\Signature\Algorithm\RS256(),
        ]);

        $jwsBuilder = new \Jose\Component\Signature\JWSBuilder($algorithmManager);

        // Create JWK from PEM
        $privateKey = \Jose\Component\KeyManagement\JWKFactory::createFromKey($privateKeyPem);

        // Build JWS
        $jws = $jwsBuilder
            ->create()
            ->withPayload(json_encode($digestObject))
            ->addSignature($privateKey, [
                'issued-by' => $config['merchantId'],
                'alg' => 'RS256',
                'kid' => $config['privateKeyId'],
                'x-gl-merchantId' => $config['merchantId'],
                'x-gl-enc' => 'true',
                'is-digested' => 'true',
            ])
            ->build();

        // Serialize to compact format
        $serializer = new \Jose\Component\Signature\Serializer\CompactSerializer();
        return $serializer->serialize($jws, 0);

    } catch (\Exception $e) {
        throw new \RuntimeException('JWS generation failed: ' . $e->getMessage(), 0, $e);
    }
}

