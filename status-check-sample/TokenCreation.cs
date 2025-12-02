using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using Jose;

namespace StatusCheckSample
{
    public static class TokenCreation
    {
        // Creates a JWS that signs the SHA-256 digest of the GET request path for status
        // Mirrors SDK behavior: payload includes base64 digest and algorithm; headers include alg, issued-by, kid, x-gl-merchantId, x-gl-enc, is-digested
        public static string CreateJwsForStatusDigest(
            string digestInput,
            string merchantId,
            string privateKeyId,
            string merchantPrivateKeyPem,
            int tokenExpirationMs = 300000 // default 5 minutes when 0 or not provided
        )
        {
            if (string.IsNullOrWhiteSpace(digestInput)) throw new ArgumentException("digestInput is required");
            if (string.IsNullOrWhiteSpace(merchantId)) throw new ArgumentException("merchantId is required");
            if (string.IsNullOrWhiteSpace(privateKeyId)) throw new ArgumentException("privateKeyId is required");
            if (string.IsNullOrWhiteSpace(merchantPrivateKeyPem)) throw new ArgumentException("merchantPrivateKeyPem is required");

            long iatMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            long expMs = iatMs + (tokenExpirationMs != 0 ? tokenExpirationMs : 300000);

            // Compute SHA-256 digest of the input string then base64 encode
            string digestBase64;
            using (var sha256 = SHA256.Create())
            {
                byte[] digestBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(digestInput));
                digestBase64 = Convert.ToBase64String(digestBytes);
            }

            // Payload (as JSON string) — we let Jose encode payload, but we pass a .NET object
            var payload = new
            {
                digest = digestBase64,
                digestAlgorithm = "SHA-256",
                exp = expMs,
                iat = iatMs.ToString()
            };

            // Headers per SDK
            var headers = new Dictionary<string, object>
            {
                { "alg", "RS256" },
                { "issued-by", merchantId },
                { "kid", privateKeyId },
                { "x-gl-merchantId", merchantId },
                { "x-gl-enc", "true" },
                { "is-digested", "true" }
            };

            // Import merchant private key (PKCS#8) from PEM
            using RSA privateKey = ImportPrivateKeyFromPkcs8Pem(merchantPrivateKeyPem);

            // Produce JWS (compact) with RS256
            string jws = JWT.Encode(payload, privateKey, JwsAlgorithm.RS256, extraHeaders: headers);
            return jws;
        }

        private static RSA ImportPrivateKeyFromPkcs8Pem(string pem)
        {
            // Accepts either raw PKCS#8 content or full PEM with BEGIN/END lines
            string normalized = pem?.Trim() ?? string.Empty;
            if (string.IsNullOrWhiteSpace(normalized)) throw new ArgumentException("Empty PEM");

            // If it contains PEM guards, strip them
            if (normalized.Contains("-----BEGIN PRIVATE KEY-----"))
            {
                normalized = normalized.Replace("-----BEGIN PRIVATE KEY-----", string.Empty)
                                       .Replace("-----END PRIVATE KEY-----", string.Empty)
                                       .Trim();
            }

            byte[] keyBytes = Convert.FromBase64String(normalized);
            RSA rsa = RSA.Create();
            rsa.ImportPkcs8PrivateKey(keyBytes, out _);
            return rsa;
        }
    }
}


