using System;
using System.Net.Http;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace StatusCheckSample
{
    internal class Program
    {
        private static async Task<int> Main(string[] args)
        {
            try
            {
                // Inputs: prefer environment variables; allow CLI overrides as positional args
                // Args (optional): 0=BaseUrl, 1=Gid, 2=MerchantId, 3=PrivateKeyId, 4=PrivateKeyPEM, 5=TokenExpMs
                string baseUrl = GetArg(args, 0) ?? GetEnvOrThrow("PAYGLOCAL_BASE_URL");
                string gid = GetArg(args, 1) ?? GetEnvOrThrow("PAYGLOCAL_GID");
                string merchantId = GetArg(args, 2) ?? GetEnvOrThrow("PAYGLOCAL_MERCHANT_ID");
                string privateKeyId = GetArg(args, 3) ?? GetEnvOrThrow("PAYGLOCAL_PRIVATE_KEY_ID");

                // Private key: inline PEM via env or file path via PAYGLOCAL_PRIVATE_KEY_PATH
                string pem = GetArg(args, 4);
                if (string.IsNullOrWhiteSpace(pem))
                {
                    string pemPath = Environment.GetEnvironmentVariable("PAYGLOCAL_PRIVATE_KEY_PATH");
                    if (!string.IsNullOrWhiteSpace(pemPath))
                    {
                        pem = System.IO.File.ReadAllText(pemPath);
                    }
                }
                if (string.IsNullOrWhiteSpace(pem))
                {
                    pem = GetEnvOrThrow("PAYGLOCAL_PRIVATE_KEY");
                }

                int tokenExpMs = 0;
                string expStr = GetArg(args, 5) ?? Environment.GetEnvironmentVariable("PAYGLOCAL_TOKEN_EXPIRATION");
                if (!string.IsNullOrWhiteSpace(expStr) && int.TryParse(expStr, out int parsed))
                {
                    tokenExpMs = parsed;
                }

                // Build the status endpoint path to be signed and requested
                string endpointPathTemplate = "/gl/v1/payments/{gid}/status";
                string endpointPath = endpointPathTemplate.Replace("{gid}", gid ?? string.Empty);

                // Create JWS token that signs the endpoint path (digest)
                string jws = TokenCreation.CreateJwsForStatusDigest(
                    digestInput: endpointPath,
                    merchantId: merchantId,
                    privateKeyId: privateKeyId,
                    merchantPrivateKeyPem: pem,
                    tokenExpirationMs: tokenExpMs
                );

                // Prepare HTTP request
                string fullUrl = CombineUrl(baseUrl, endpointPath);
                using var httpClient = new HttpClient();
                using var req = new HttpRequestMessage(HttpMethod.Get, fullUrl);
                req.Headers.Add("x-gl-token-external", jws);
                req.Headers.TryAddWithoutValidation("Content-Type", "text/plain");

                using HttpResponseMessage resp = await httpClient.SendAsync(req);
                string body = await resp.Content.ReadAsStringAsync();

                Console.WriteLine($"HTTP {(int)resp.StatusCode} {resp.StatusCode}");
                Console.WriteLine(body);
                return resp.IsSuccessStatusCode ? 0 : 1;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("Status check failed: " + ex.Message);
                Console.Error.WriteLine(ex.ToString());
                return 2;
            }
        }

        private static string GetEnvOrThrow(string name)
        {
            var value = Environment.GetEnvironmentVariable(name);
            if (string.IsNullOrWhiteSpace(value))
            {
                throw new ArgumentException($"Missing required environment variable: {name}");
            }
            return value;
        }

        private static string GetArg(string[] args, int index)
        {
            if (args == null || index < 0 || index >= args.Length) return null;
            return string.IsNullOrWhiteSpace(args[index]) ? null : args[index];
        }

        private static string CombineUrl(string baseUrl, string path)
        {
            if (string.IsNullOrWhiteSpace(baseUrl)) return path ?? string.Empty;
            if (string.IsNullOrWhiteSpace(path)) return baseUrl;
            if (baseUrl.EndsWith("/")) baseUrl = baseUrl.TrimEnd('/');
            return baseUrl + path;
        }
    }
}


