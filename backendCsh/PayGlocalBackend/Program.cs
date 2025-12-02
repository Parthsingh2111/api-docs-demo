using Microsoft.AspNetCore.Mvc;
using PayGlocal;
using Newtonsoft.Json.Linq;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Minimal services
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Configure PayGlocal client
builder.Services.AddSingleton<PayGlocalClient>(provider =>
{
    var configuration = provider.GetRequiredService<IConfiguration>();
    var payglocalConfig = configuration.GetSection("PayGlocal");

    string ReadKeyValue(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return string.Empty;
        try
        {
            if (System.IO.File.Exists(value))
            {
                return System.IO.File.ReadAllText(value);
            }
        }
        catch { }
        return value;
    }

    // Prefer environment variables when present
    string env(string key, string? fallback = null)
        => Environment.GetEnvironmentVariable(key) ?? fallback ?? string.Empty;

    var merchantId = env("PAYGLOCAL_MERCHANT_ID", payglocalConfig["merchantId"]);
    var apiKey = env("PAYGLOCAL_API_KEY", payglocalConfig["apiKey"]);
    var environmentName = env("PAYGLOCAL_ENV", payglocalConfig["payglocalEnv"]);
    var publicKeyId = env("PAYGLOCAL_PUBLIC_KEY_ID", payglocalConfig["publicKeyId"]);
    var privateKeyId = env("PAYGLOCAL_PRIVATE_KEY_ID", payglocalConfig["privateKeyId"]);

    var payglocalPublicKeyRaw = env("PAYGLOCAL_PUBLIC_KEY", payglocalConfig["payglocalPublicKey"]);
    var merchantPrivateKeyRaw = env("PAYGLOCAL_PRIVATE_KEY", payglocalConfig["merchantPrivateKey"]);

    var payglocalPublicKey = ReadKeyValue(payglocalPublicKeyRaw);
    var merchantPrivateKey = ReadKeyValue(merchantPrivateKeyRaw);

    var logLevel = env("PAYGLOCAL_LOG_LEVEL", payglocalConfig["logLevel"]);
    var tokenExpirationStr = env("PAYGLOCAL_TOKEN_EXPIRATION", payglocalConfig["tokenExpiration"]);
    var tokenExpiration = int.TryParse(tokenExpirationStr, out var te) ? te : 300000;

    return new PayGlocalClient(
        merchantId: merchantId,
        apiKey: apiKey,
        environment: environmentName,
        publicKeyId: publicKeyId,
        privateKeyId: privateKeyId,
        payglocalPublicKey: payglocalPublicKey,
        merchantPrivateKey: merchantPrivateKey,
        logLevel: logLevel,
        tokenExpiration: tokenExpiration
    );
});

var app = builder.Build();

app.UseCors("AllowAll");

static async Task<JToken> ReadJson(HttpRequest req)
{
    using var reader = new StreamReader(req.Body);
    var raw = await reader.ReadToEndAsync();
    if (string.IsNullOrWhiteSpace(raw)) return new JObject();
    return JToken.Parse(raw);
}

// Convert arbitrary SDK response (string/JsonElement/POCO) to JObject for safe token extraction
static JObject ToJObject(object value)
{
    if (value == null) return new JObject();
    if (value is JObject jo) return jo;
    if (value is JToken jt) return jt.Type == JTokenType.Object ? (JObject)jt : new JObject();
    if (value is string s)
    {
        try { var tok = JToken.Parse(s); return tok as JObject ?? new JObject(); } catch { return new JObject(); }
    }
    if (value is JsonElement je)
    {
        try
        {
            if (je.ValueKind == JsonValueKind.Object || je.ValueKind == JsonValueKind.Array)
            {
                var json = System.Text.Json.JsonSerializer.Serialize(je);
                var tok = JToken.Parse(json);
                return tok as JObject ?? new JObject();
            }
        }
        catch { }
        return new JObject();
    }
    try { return JObject.FromObject(value); } catch { return new JObject(); }
}

// Shared handler
static async Task<IResult> Handle(HttpContext http, PayGlocalClient client, string method)
{
    var payload = await ReadJson(http.Request);
    try
    {
        object result = method switch
        {
            "apikey" => await client.InitiateApiKeyPayment(payload),
            "si" => await client.InitiateSiPayment(payload),
            "auth" => await client.InitiateAuthPayment(payload),
            "capture" => await client.InitiateCapture(payload),
            "refund" => await client.InitiateRefund(payload),
            "status" => await client.InitiateCheckStatus(payload),
            "authreversal" => await client.InitiateAuthReversal(payload),
            _ => await client.InitiateJwtPayment(payload)
        };
        return Results.Ok(result);
    }
    catch (HttpRequestException hex)
    {
        var body = hex.Data.Contains("Body") ? hex.Data["Body"]?.ToString() : null;
        var status = hex.Data.Contains("StatusCode") ? hex.Data["StatusCode"] : null;
        int code = status is int s ? s : 502;
        return Results.Json(new { error = hex.Message, gatewayBody = body }, statusCode: code);
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }
}

// Helpers to format responses similar to Node backend
static string FindFirstValue(JObject p, params string[] jsonPaths)
{
    foreach (var path in jsonPaths)
    {
        var tok = p.SelectToken(path);
        if (tok != null && tok.Type != JTokenType.Null)
        {
            var s = tok.ToString();
            if (!string.IsNullOrWhiteSpace(s)) return s;
        }
    }
    return string.Empty;
}

static string FindRecursive(JObject p, params string[] fieldNames)
{
    foreach (var name in fieldNames)
    {
        var tokens = p.SelectTokens($"$..{name}");
        foreach (var tok in tokens)
        {
            if (tok != null && tok.Type != JTokenType.Null)
            {
                var s = tok.ToString();
                if (!string.IsNullOrWhiteSpace(s)) return s;
            }
        }
    }
    return string.Empty;
}

static object FormatPaymentInitiation(object payment)
{
    var p = ToJObject(payment);
    string paymentLink = FindFirstValue(
        p,
        "data.redirectUrl",
        "data.redirect_url",
        "data.payment_link",
        "redirectUrl",
        "redirect_url",
        "payment_link",
        "data.paymentLink",
        "paymentLink"
    );
    if (string.IsNullOrWhiteSpace(paymentLink))
    {
        paymentLink = FindRecursive(p, "redirectUrl", "redirect_url", "payment_link", "paymentLink");
    }

    string gid = FindFirstValue(
        p,
        "gid",
        "data.gid",
        "transactionId",
        "data.transactionId"
    );
    if (string.IsNullOrWhiteSpace(gid))
    {
        gid = FindRecursive(p, "gid", "transactionId");
    }

    return new
    {
        status = "SUCCESS",
        message = "Payment initiated successfully",
        payment_link = paymentLink,
        redirectUrl = paymentLink,
        gid = gid,
        raw_response = payment
    };
}

static object FormatCapture(object response)
{
    var p = ToJObject(response);
    string gid = p.SelectToken("gid")?.ToString() ?? p.SelectToken("data.gid")?.ToString() ?? p.SelectToken("transactionId")?.ToString() ?? p.SelectToken("data.transactionId")?.ToString() ?? string.Empty;
    string captureId = p.SelectToken("captureId")?.ToString() ?? p.SelectToken("data.captureId")?.ToString() ?? p.SelectToken("id")?.ToString() ?? p.SelectToken("data.id")?.ToString() ?? string.Empty;
    string status = p.SelectToken("status")?.ToString() ?? p.SelectToken("data.status")?.ToString() ?? p.SelectToken("result")?.ToString() ?? p.SelectToken("data.result")?.ToString() ?? string.Empty;

    return new
    {
        status = "SUCCESS",
        message = $"Capture {(string.IsNullOrEmpty(status) ? "initiated" : status.ToLower())} successfully",
        gid,
        captureId,
        transactionStatus = status,
        raw_response = response
    };
}

static object FormatRefund(object response)
{
    var p = ToJObject(response);
    string gid = p.SelectToken("gid")?.ToString() ?? p.SelectToken("data.gid")?.ToString() ?? p.SelectToken("transactionId")?.ToString() ?? p.SelectToken("data.transactionId")?.ToString() ?? string.Empty;
    string refundId = p.SelectToken("refundId")?.ToString() ?? p.SelectToken("data.refundId")?.ToString() ?? p.SelectToken("id")?.ToString() ?? p.SelectToken("data.id")?.ToString() ?? string.Empty;
    string status = p.SelectToken("status")?.ToString() ?? p.SelectToken("data.status")?.ToString() ?? p.SelectToken("result")?.ToString() ?? p.SelectToken("data.result")?.ToString() ?? string.Empty;

    return new
    {
        status = "SUCCESS",
        message = $"Refund {(string.IsNullOrEmpty(status) ? "initiated" : status.ToLower())} successfully",
        gid,
        refundId,
        transactionStatus = status,
        raw_response = response
    };
}

static object FormatAuthReversal(object response)
{
    var p = ToJObject(response);
    string gid = p.SelectToken("gid")?.ToString() ?? p.SelectToken("data.gid")?.ToString() ?? p.SelectToken("transactionId")?.ToString() ?? p.SelectToken("data.transactionId")?.ToString() ?? string.Empty;
    string reversalId = p.SelectToken("reversalId")?.ToString() ?? p.SelectToken("data.reversalId")?.ToString() ?? p.SelectToken("id")?.ToString() ?? p.SelectToken("data.id")?.ToString() ?? string.Empty;
    string status = p.SelectToken("status")?.ToString() ?? p.SelectToken("data.status")?.ToString() ?? p.SelectToken("result")?.ToString() ?? p.SelectToken("data.result")?.ToString() ?? string.Empty;

    return new
    {
        status = "SUCCESS",
        message = $"Auth reversal {(string.IsNullOrEmpty(status) ? "initiated" : status.ToLower())} successfully",
        gid,
        reversalId,
        transactionStatus = status,
        raw_response = response
    };
}

static object FormatSiPauseActivate(object response, string action)
{
    var p = ToJObject(response);
    string mandateId = p.SelectToken("mandateId")?.ToString() ?? p.SelectToken("data.mandateId")?.ToString() ?? p.SelectToken("standingInstruction.mandateId")?.ToString() ?? string.Empty;
    string status = p.SelectToken("status")?.ToString() ?? p.SelectToken("data.status")?.ToString() ?? p.SelectToken("result")?.ToString() ?? p.SelectToken("data.result")?.ToString() ?? string.Empty;

    return new
    {
        status = "SUCCESS",
        message = $"SI {action.ToUpper()} {(string.IsNullOrEmpty(status) ? "completed" : status.ToLower())} successfully",
        mandateId,
        action,
        transactionStatus = status,
        raw_response = response
    };
}

// Minimal single endpoint: POST /api/pg?method=jwt|apikey|si|auth|capture|refund|status|authreversal
app.MapPost("/api/pg", async (HttpContext http, PayGlocalClient client) =>
{
    string method = http.Request.Query["method"].ToString();
    method = string.IsNullOrWhiteSpace(method) ? "jwt" : method.ToLowerInvariant();
    return await Handle(http, client, method);
});

// Aliases to match Flutter frontend - return raw SDK responses
app.MapPost("/api/pay/jwt", async (HttpContext http, PayGlocalClient client) =>
{
    var payload = await ReadJson(http.Request);
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/pay/jwt endpoint hit");
    Console.WriteLine("PAYLOAD SENT TO SDK:");
    Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
    Console.WriteLine("===========================================");
    
    try
    {
        var payment = await client.InitiateJwtPayment(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (JWT Payment) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(payment, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        // Extract redirectUrl for frontend
        var p = ToJObject(payment);
        string redirectUrl = FindFirstValue(p, "data.redirectUrl", "data.redirect_url", "redirectUrl", "redirect_url", "data.paymentLink", "paymentLink");
        if (string.IsNullOrWhiteSpace(redirectUrl)) redirectUrl = FindRecursive(p, "redirectUrl", "redirect_url", "paymentLink");
        string gid = FindFirstValue(p, "gid", "data.gid", "transactionId", "data.transactionId");
        if (string.IsNullOrWhiteSpace(gid)) gid = FindRecursive(p, "gid", "transactionId");
        
        return Results.Ok(new { status = "SUCCESS", message = "Payment initiated successfully", redirectUrl, payment_link = redirectUrl, gid, raw_response = payment });
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"JWT Payment Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "Payment failed", error = ex.Message, code = "PAYMENT_ERROR" }, statusCode: 500);
    }
});









app.MapPost("/api/pay/apikey", async (HttpContext http, PayGlocalClient client)
    => await Handle(http, client, "apikey"));


app.MapPost("/api/pay/si", async (HttpContext http, PayGlocalClient client) =>
{
    var payload = await ReadJson(http.Request);
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/pay/si endpoint hit");
    Console.WriteLine("PAYLOAD SENT TO SDK:");
    Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
    Console.WriteLine("===========================================");
    
    try
    {
        var payment = await client.InitiateSiPayment(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (SI Payment) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(payment, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        // Extract redirectUrl, gid, and mandateId for frontend
        var p = ToJObject(payment);
        string redirectUrl = FindFirstValue(p, "data.redirectUrl", "data.redirect_url", "redirectUrl", "redirect_url", "data.paymentLink", "paymentLink");
        if (string.IsNullOrWhiteSpace(redirectUrl)) redirectUrl = FindRecursive(p, "redirectUrl", "redirect_url", "paymentLink");
        string gid = FindFirstValue(p, "gid", "data.gid", "transactionId", "data.transactionId");
        if (string.IsNullOrWhiteSpace(gid)) gid = FindRecursive(p, "gid", "transactionId");
        string mandateId = FindFirstValue(p, "mandateId", "data.mandateId", "standingInstruction.mandateId");
        if (string.IsNullOrWhiteSpace(mandateId)) mandateId = FindRecursive(p, "mandateId");
        
        return Results.Ok(new { status = "SUCCESS", message = "SI Payment initiated successfully", redirectUrl, payment_link = redirectUrl, gid, mandateId, raw_response = payment });
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"SI Payment Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "Payment failed", error = ex.Message, code = "PAYMENT_ERROR" }, statusCode: 500);
    }
});


app.MapPost("/api/pay/auth", async (HttpContext http, PayGlocalClient client) =>
{
    var payload = await ReadJson(http.Request);
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/pay/auth endpoint hit");
    Console.WriteLine("PAYLOAD SENT TO SDK:");
    Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
    Console.WriteLine("===========================================");
    
    try
    {
        var payment = await client.InitiateAuthPayment(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (Auth Payment) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(payment, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        // Extract redirectUrl for frontend
        var p = ToJObject(payment);
        string redirectUrl = FindFirstValue(p, "data.redirectUrl", "data.redirect_url", "redirectUrl", "redirect_url", "data.paymentLink", "paymentLink");
        if (string.IsNullOrWhiteSpace(redirectUrl)) redirectUrl = FindRecursive(p, "redirectUrl", "redirect_url", "paymentLink");
        string gid = FindFirstValue(p, "gid", "data.gid", "transactionId", "data.transactionId");
        if (string.IsNullOrWhiteSpace(gid)) gid = FindRecursive(p, "gid", "transactionId");
        
        return Results.Ok(new { status = "SUCCESS", message = "Auth Payment initiated successfully", redirectUrl, payment_link = redirectUrl, gid, raw_response = payment });
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"Auth Payment Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "Payment failed", error = ex.Message, code = "PAYMENT_ERROR" }, statusCode: 500);
    }
});




app.MapPost("/api/pay/alt", async (HttpContext http, PayGlocalClient client)
    => await Handle(http, client, "jwt"));

// Node uses GET with query gid
app.MapGet("/api/status", async (HttpContext http, PayGlocalClient client) =>
{
    var gid = http.Request.Query["gid"].ToString();
    var payload = new JObject { ["gid"] = gid };
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/status endpoint hit");
    Console.WriteLine($"Query GID: {gid}");
    Console.WriteLine($"Payload being sent to SDK: {payload}");
    Console.WriteLine("===========================================");
    
    try
    {
        var payment = await client.InitiateCheckStatus(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (Status Check) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(payment, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        return Results.Ok(payment);
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"Status Check Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "Status check failed", error = ex.Message, code = "STATUS_CHECK_ERROR" }, statusCode: 500);
    }
});

app.MapPost("/api/refund", async (HttpContext http, PayGlocalClient client) =>
{
    var body = await ReadJson(http.Request);
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/refund endpoint hit");
    Console.WriteLine($"Request Body: {body}");
    
    try
    {
        var gid = body["gid"]?.ToString();
        var refundType = body["refundType"]?.ToString() ?? "F";
        var paymentData = body["paymentData"];
        
        if (string.IsNullOrWhiteSpace(gid))
        {
            return Results.Json(new { status = "error", message = "Missing gid", code = "VALIDATION_ERROR", details = new { requiredFields = new[] { "gid" } } }, statusCode: 400);
        }
        
        if (refundType == "P" && (paymentData == null || paymentData["totalAmount"] == null))
        {
            return Results.Json(new { status = "error", message = "Missing paymentData.totalAmount for partial refund", code = "VALIDATION_ERROR", details = new { requiredFields = new[] { "paymentData.totalAmount" } } }, statusCode: 400);
        }
        
        var merchantTxnId = body["merchantTxnId"]?.ToString() ?? $"REFUND_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
        
        JObject payload = new JObject
        {
            ["refundType"] = refundType,
            ["gid"] = gid,
            ["merchantTxnId"] = merchantTxnId,
            ["paymentData"] = refundType == "F" ? new JObject { ["totalAmount"] = "0" } : new JObject { ["totalAmount"] = paymentData["totalAmount"]?.ToString() ?? "0" }
        };
        
        Console.WriteLine("PAYLOAD SENT TO SDK:");
        Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
        Console.WriteLine("===========================================");
        
        var refund = await client.InitiateRefund(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (Refund) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(refund, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        return Results.Ok(refund);
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"Refund Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "Refund failed", error = ex.Message, code = "REFUND_ERROR" }, statusCode: 500);
    }
});

app.MapPost("/api/cap", async (HttpContext http, PayGlocalClient client) =>
{
    var body = await ReadJson(http.Request);
    var gid = http.Request.Query["gid"].ToString();
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/cap endpoint hit");
    Console.WriteLine($"Query GID: {gid}");
    Console.WriteLine($"Request Body: {body}");
    
    try
    {
        if (string.IsNullOrWhiteSpace(gid))
        {
            return Results.Json(new { status = "error", message = "Missing gid", code = "VALIDATION_ERROR", details = new { requiredFields = new[] { "gid" } } }, statusCode: 400);
        }

        var captureType = body["captureType"]?.ToString() ?? "F";
        var merchantTxnId = body["merchantTxnId"]?.ToString() ?? $"CAPTURE_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";

        if (captureType == "P")
        {
            var amount = body.SelectToken("paymentData.totalAmount")?.ToString();
            if (string.IsNullOrWhiteSpace(amount))
            {
                return Results.Json(new { status = "error", message = "Missing paymentData.totalAmount for partial capture", code = "VALIDATION_ERROR", details = new { requiredFields = new[] { "paymentData.totalAmount" } } }, statusCode: 400);
            }
        }

        JObject payload = captureType == "F"
            ? new JObject { ["captureType"] = "F", ["gid"] = gid, ["merchantTxnId"] = merchantTxnId }
            : new JObject { ["captureType"] = "P", ["gid"] = gid, ["merchantTxnId"] = merchantTxnId, ["paymentData"] = new JObject { ["totalAmount"] = body.SelectToken("paymentData.totalAmount")?.ToString() ?? "" } };

        Console.WriteLine("PAYLOAD SENT TO SDK:");
        Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
        Console.WriteLine("===========================================");
        
        var capture = await client.InitiateCapture(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (Capture) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(capture, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        return Results.Ok(capture);
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"Capture Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "Capture failed", error = ex.Message, code = "CAPTURE_ERROR" }, statusCode: 500);
    }
});

app.MapPost("/api/authreversal", async (HttpContext http, PayGlocalClient client) =>
{
    var body = await ReadJson(http.Request);
    var gid = http.Request.Query["gid"].ToString();
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/authreversal endpoint hit");
    Console.WriteLine($"Query GID: {gid}");
    Console.WriteLine($"Request Body: {body}");
    
    try
    {
        if (string.IsNullOrWhiteSpace(gid))
        {
            return Results.Json(new { status = "error", message = "Missing gid", code = "VALIDATION_ERROR", details = new { requiredFields = new[] { "gid" } } }, statusCode: 400);
        }
        var merchantTxnId = body["merchantTxnId"]?.ToString() ?? $"REVERSAL_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
        var payload = new JObject { ["gid"] = gid, ["merchantTxnId"] = merchantTxnId };
        
        Console.WriteLine("PAYLOAD SENT TO SDK:");
        Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
        Console.WriteLine("===========================================");
        
        var reversal = await client.InitiateAuthReversal(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (Auth Reversal) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(reversal, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        return Results.Ok(reversal);
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"Auth Reversal Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "Auth reversal failed", error = ex.Message, code = "AUTH_REVERSAL_ERROR" }, statusCode: 500);
    }
});

app.MapPost("/api/pauseActivate", async (HttpContext http, PayGlocalClient client) =>
{
    var payload = await ReadJson(http.Request);
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/pauseActivate endpoint hit");
    Console.WriteLine("PAYLOAD SENT TO SDK (before normalization):");
    Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
    
    // Mirror index.js: ensure required fields and auto-generate merchantTxnId when absent
    var standingInstruction = payload["standingInstruction"] as JObject;
    if (standingInstruction == null)
    {
        return Results.Json(new { status = "error", message = "Missing standingInstruction", code = "VALIDATION_ERROR", details = new { requiredFields = new[] { "standingInstruction" } } }, statusCode: 400);
    }
    var actionRaw = standingInstruction["action"]?.ToString();
    var mandateId = standingInstruction["mandateId"]?.ToString();
    if (string.IsNullOrWhiteSpace(actionRaw) || string.IsNullOrWhiteSpace(mandateId))
    {
        return Results.Json(new { status = "error", message = "Missing action or mandateId in standingInstruction", code = "VALIDATION_ERROR", details = new { requiredFields = new[] { "standingInstruction.action", "standingInstruction.mandateId" } } }, statusCode: 400);
    }
    // Auto-generate merchantTxnId if missing (same as Node)
    if (payload["merchantTxnId"] == null || string.IsNullOrWhiteSpace(payload["merchantTxnId"]?.ToString()))
    {
        payload["merchantTxnId"] = $"SI_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
    }

    Console.WriteLine("NORMALIZED PAYLOAD SENT TO SDK:");
    Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
    Console.WriteLine("===========================================");
    
    try
    {
        var action = actionRaw.ToLowerInvariant();
        object result = (action == "activate")
            ? await client.InitiateActivateSI(payload)
            : await client.InitiatePauseSI(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (SI Pause/Activate) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(result, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        return Results.Ok(result);
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"SI Pause/Activate Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "SI pause/activate failed", error = ex.Message, code = "SI_ERROR" }, statusCode: 500);
    }
});

// SI On-Demand and SI Status
app.MapPost("/api/siOnDemand", async (HttpContext http, PayGlocalClient client) =>
{
    var payload = await ReadJson(http.Request);
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/siOnDemand endpoint hit");
    Console.WriteLine("PAYLOAD SENT TO SDK (before normalization):");
    Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
    
    try
    {
        // Auto-generate merchantTxnId if missing (same as other endpoints)
        if (payload["merchantTxnId"] == null || string.IsNullOrWhiteSpace(payload["merchantTxnId"]?.ToString()))
        {
            payload["merchantTxnId"] = $"SI_SALE_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
        }
        
        bool hasAmount = payload.SelectToken("paymentData.totalAmount") != null;
        Console.WriteLine($"SI On-Demand type: {(hasAmount ? "Variable" : "Fixed")}");
        Console.WriteLine("NORMALIZED PAYLOAD SENT TO SDK:");
        Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
        Console.WriteLine("===========================================");
        
        object result = hasAmount
            ? await client.InitiateSiOnDemandVariable(payload)
            : await client.InitiateSiOnDemandFixed(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (SI On-Demand) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(result, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        // Extract redirectUrl and gid for frontend
        var p = ToJObject(result);
        string redirectUrl = FindFirstValue(p, "data.redirectUrl", "data.redirect_url", "redirectUrl", "redirect_url", "data.paymentLink", "paymentLink");
        if (string.IsNullOrWhiteSpace(redirectUrl)) redirectUrl = FindRecursive(p, "redirectUrl", "redirect_url", "paymentLink");
        string gid = FindFirstValue(p, "gid", "data.gid", "transactionId", "data.transactionId");
        if (string.IsNullOrWhiteSpace(gid)) gid = FindRecursive(p, "gid", "transactionId");
        
        return Results.Ok(new { status = "SUCCESS", message = "SI on-demand initiated", redirectUrl, payment_link = redirectUrl, gid, raw_response = result });
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"SI On-Demand Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "SI on-demand failed", error = ex.Message, code = "SI_ONDEMAND_ERROR" }, statusCode: 500);
    }
});

app.MapPost("/api/siStatus", async (HttpContext http, PayGlocalClient client) =>
{
    var payload = await ReadJson(http.Request);
    
    Console.WriteLine("===========================================");
    Console.WriteLine(">>> /api/siStatus endpoint hit");
    Console.WriteLine("PAYLOAD SENT TO SDK (before normalization):");
    Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
    
    try
    {
        // Auto-generate merchantTxnId if missing (same as other endpoints)
        if (payload["merchantTxnId"] == null || string.IsNullOrWhiteSpace(payload["merchantTxnId"]?.ToString()))
        {
            payload["merchantTxnId"] = $"SI_STATUS_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
        }
        
        Console.WriteLine("NORMALIZED PAYLOAD SENT TO SDK:");
        Console.WriteLine(payload.ToString(Newtonsoft.Json.Formatting.Indented));
        Console.WriteLine("===========================================");
        
        var result = await client.InitiateSiStatusCheck(payload);
        
        Console.WriteLine("===========================================");
        Console.WriteLine("=== RAW SDK RESPONSE (SI Status) ===");
        Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(result, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine("=== END RAW RESPONSE ===");
        Console.WriteLine("===========================================");
        
        return Results.Ok(result);
    }
    catch (Exception ex)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine($"SI Status Error: {ex.Message}");
        Console.WriteLine("===========================================");
        return Results.Json(new { status = "ERROR", message = "SI status check failed", error = ex.Message, code = "SI_STATUS_ERROR" }, statusCode: 500);
    }
});

app.Run();


