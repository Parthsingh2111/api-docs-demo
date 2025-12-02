using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using PayGlocal.SDK;
using System.Linq;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.UseRouting();

// Enable CORS
app.UseCors(policy => policy
    .AllowAnyOrigin()
    .AllowAnyMethod()
    .AllowAnyHeader()
);

// Add JSON parsing middleware
app.Use(async (context, next) =>
{
    if (context.Request.ContentType?.StartsWith("application/json") == true)
    {
        context.Request.EnableBuffering();
    }
    await next();
});

// Initialize PayGlocal client
var config = new PayGlocalConfig
{
    BaseUrl = "https://api.uat.payglocal.in",
    ApiKey = "your-api-key-here",
    PrivateKeyPath = "/Users/parthsingh/proj/payglocalCentraProject/centralproject/backendCsh/keys/payglocal_private_key",
    PublicKeyPath = "/Users/parthsingh/proj/payglocalCentraProject/centralproject/backendCsh/keys/payglocal_public_key",
    LogLevel = "debug"
};

var client = new PayGlocalClient(config);

Console.WriteLine($"Server is running on http://localhost:8000");

// JWT Payment endpoint
app.MapPost("/api/jwt-payment", async (HttpContext context) =>
{
    try
    {
        Console.WriteLine("Received request to initiate JWT payment");
        
        // Read request body
        string requestBodyJson;
        using (var reader = new StreamReader(context.Request.Body))
        {
            requestBodyJson = await reader.ReadToEndAsync();
        }

        // Parse JSON
        var requestBody = JsonSerializer.Deserialize<Dictionary<string, object>>(requestBodyJson, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (requestBody == null)
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Invalid JSON payload" }));
            return;
        }

        // Validate required fields
        var requiredFields = new[] { "merchantTxnId", "paymentData", "merchantCallbackURL" };
        var missingFields = requiredFields.Where(field => !requestBody.ContainsKey(field)).ToArray();
        
        if (missingFields.Any())
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { 
                error = "Missing required fields", 
                details = new { requiredFields = new[] { "merchantTxnId", "paymentData", "merchantCallbackURL" } }
            }));
            return;
        }

        Console.WriteLine($"Initiating JWT payment with payload: {JsonSerializer.Serialize(requestBody)}");

        var payment = await client.InitiateJwtPayment(requestBody);
        Console.WriteLine($"Raw SDK Response: {JsonSerializer.Serialize(payment)}");

        // Check if SDK response indicates error
        var paymentDict = payment as Dictionary<string, object>;
        if (paymentDict?.ContainsKey("status") == true && 
            (paymentDict["status"]?.ToString() == "REQUEST_ERROR" || paymentDict["status"]?.ToString() == "ERROR")) {
            throw new Exception($"PayGlocal SDK Error: {paymentDict.GetValueOrDefault("message", "Unknown error")}");
        }

        await context.Response.WriteAsync(JsonSerializer.Serialize(payment));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"JWT Payment failed: {ex.Message}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = ex.Message }));
    }
});

// SI Payment endpoint
app.MapPost("/api/si-payment", async (HttpContext context) =>
{
    try
    {
        Console.WriteLine("Received request to initiate SI payment");
        
        // Read request body
        string requestBodyJson;
        using (var reader = new StreamReader(context.Request.Body))
        {
            requestBodyJson = await reader.ReadToEndAsync();
        }

        // Parse JSON
        var requestBody = JsonSerializer.Deserialize<Dictionary<string, object>>(requestBodyJson, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (requestBody == null)
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Invalid JSON payload" }));
            return;
        }

        // Validate required fields
        var requiredFields = new[] { "merchantTxnId", "paymentData", "merchantCallbackURL", "standingInstruction" };
        var missingFields = requiredFields.Where(field => !requestBody.ContainsKey(field)).ToArray();
        
        if (missingFields.Any())
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { 
                error = "Missing required fields", 
                details = new { requiredFields = new[] { "merchantTxnId", "paymentData", "merchantCallbackURL", "standingInstruction" } }
            }));
            return;
        }

        Console.WriteLine($"Initiating SI payment with payload: {JsonSerializer.Serialize(requestBody)}");

        var payment = await client.InitiateSiPayment(requestBody);
        
        // Enhanced logging for full response
        Console.WriteLine("=== FULL SI PAYMENT RESPONSE ===");
        Console.WriteLine($"Response Type: {payment?.GetType().Name}");
        Console.WriteLine($"Response JSON: {JsonSerializer.Serialize(payment, new JsonSerializerOptions { WriteIndented = true })}");
        Console.WriteLine("=== END RESPONSE ===");

        // Check if SDK response indicates error
        var paymentDict = payment as Dictionary<string, object>;
        if (paymentDict?.ContainsKey("status") == true && 
            (paymentDict["status"]?.ToString() == "REQUEST_ERROR" || paymentDict["status"]?.ToString() == "ERROR")) {
            throw new Exception($"PayGlocal SDK Error: {paymentDict.GetValueOrDefault("message", "Unknown error")}");
        }

        await context.Response.WriteAsync(JsonSerializer.Serialize(payment));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"SI Payment failed: {ex.Message}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = ex.Message }));
    }
});

// Auth Payment endpoint
app.MapPost("/api/auth-payment", async (HttpContext context) =>
{
    try
    {
        Console.WriteLine("Received request to initiate Auth payment");
        
        // Read request body
        string requestBodyJson;
        using (var reader = new StreamReader(context.Request.Body))
        {
            requestBodyJson = await reader.ReadToEndAsync();
        }

        // Parse JSON
        var requestBody = JsonSerializer.Deserialize<Dictionary<string, object>>(requestBodyJson, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (requestBody == null)
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Invalid JSON payload" }));
            return;
        }

        // Validate required fields
        var requiredFields = new[] { "merchantTxnId", "paymentData", "merchantCallbackURL", "captureTxn" };
        var missingFields = requiredFields.Where(field => !requestBody.ContainsKey(field)).ToArray();
        
        if (missingFields.Any())
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { 
                error = "Missing required fields", 
                details = new { requiredFields = new[] { "merchantTxnId", "paymentData", "merchantCallbackURL", "captureTxn" } }
            }));
            return;
        }

        Console.WriteLine($"Initiating Auth payment with payload: {JsonSerializer.Serialize(requestBody)}");

        var payment = await client.InitiateAuthPayment(requestBody);
        Console.WriteLine($"Raw SDK Response: {JsonSerializer.Serialize(payment)}");

        // Check if SDK response indicates error
        var paymentDict = payment as Dictionary<string, object>;
        if (paymentDict?.ContainsKey("status") == true && 
            (paymentDict["status"]?.ToString() == "REQUEST_ERROR" || paymentDict["status"]?.ToString() == "ERROR")) {
            throw new Exception($"PayGlocal SDK Error: {paymentDict.GetValueOrDefault("message", "Unknown error")}");
        }

        await context.Response.WriteAsync(JsonSerializer.Serialize(payment));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Auth Payment failed: {ex.Message}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = ex.Message }));
    }
});

// Refund endpoint
app.MapPost("/api/refund", async (HttpContext context) =>
{
    try
    {
        Console.WriteLine(">>> /api/refund endpoint hit");
        
        // Read request body
        string requestBodyJson;
        using (var reader = new StreamReader(context.Request.Body))
        {
            requestBodyJson = await reader.ReadToEndAsync();
        }

        // Parse JSON
        var requestBody = JsonSerializer.Deserialize<Dictionary<string, object>>(requestBodyJson, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (requestBody == null)
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Invalid JSON payload" }));
            return;
        }

        Console.WriteLine($"Received refund request: {JsonSerializer.Serialize(requestBody)}");

        // Extract gid from request
        if (!requestBody.TryGetValue("gid", out var gidObj) || gidObj == null)
        {
            Console.WriteLine("Missing gid");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Missing required field: gid" }));
            return;
        }

        string gid = gidObj.ToString();

        // Extract paymentData for partial refund
        if (!requestBody.TryGetValue("paymentData", out var paymentDataObj) || paymentDataObj == null)
        {
            Console.WriteLine("Missing paymentData.totalAmount for partial refund");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Missing required field: paymentData" }));
            return;
        }

        var paymentData = paymentDataObj as Dictionary<string, object>;
        if (paymentData == null || !paymentData.ContainsKey("totalAmount"))
        {
            Console.WriteLine("Missing paymentData.totalAmount for partial refund");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Missing required field: paymentData.totalAmount" }));
            return;
        }

        // Create payload for refund
        var payload = new Dictionary<string, object>
        {
            ["gid"] = gid,
            ["refundAmount"] = paymentData["totalAmount"]
        };

        Console.WriteLine($"payload: {JsonSerializer.Serialize(payload)}");

        var refundDetail = await client.InitiateRefund(payload);
        Console.WriteLine($"Raw SDK Response: {JsonSerializer.Serialize(refundDetail)}");

        // Check if SDK response indicates error
        var refundDict = refundDetail as Dictionary<string, object>;
        if (refundDict?.ContainsKey("status") == true && 
            (refundDict["status"]?.ToString() == "REQUEST_ERROR" || refundDict["status"]?.ToString() == "ERROR")) {
            throw new Exception($"PayGlocal SDK Error: {refundDict.GetValueOrDefault("message", "Unknown error")}");
        }

        await context.Response.WriteAsync(JsonSerializer.Serialize(refundDetail));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Refund failed: {error}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = ex.Message }));
    }
});

// Capture endpoint
app.MapPost("/api/cap", async (HttpContext context) =>
{
    try
    {
        Console.WriteLine(">>> /api/cap endpoint hit");
        
        // Read request body
        string requestBodyJson;
        using (var reader = new StreamReader(context.Request.Body))
        {
            requestBodyJson = await reader.ReadToEndAsync();
        }

        // Parse JSON
        var requestBody = JsonSerializer.Deserialize<Dictionary<string, object>>(requestBodyJson, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (requestBody == null)
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Invalid JSON payload" }));
            return;
        }

        Console.WriteLine($"Received capture request: gid={gid}, captureType={captureType}, paymentData={JsonSerializer.Serialize(paymentData)}");

        // Extract gid from request
        if (!requestBody.TryGetValue("gid", out var gidObj) || gidObj == null)
        {
            Console.WriteLine("Missing gid");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Missing required field: gid" }));
            return;
        }

        string gid = gidObj.ToString();

        // Extract paymentData for partial capture
        if (!requestBody.TryGetValue("paymentData", out var paymentDataObj) || paymentDataObj == null)
        {
            Console.WriteLine("Missing paymentData.totalAmount for partial capture");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Missing required field: paymentData" }));
            return;
        }

        var paymentData = paymentDataObj as Dictionary<string, object>;
        if (paymentData == null || !paymentData.ContainsKey("totalAmount"))
        {
            Console.WriteLine("Missing paymentData.totalAmount for partial capture");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Missing required field: paymentData.totalAmount" }));
            return;
        }

        // Create payload for capture
        var payload = new Dictionary<string, object>
        {
            ["gid"] = gid,
            ["captureAmount"] = paymentData["totalAmount"]
        };

        var payment = await client.InitiateCapture(payload);
        Console.WriteLine($"Raw SDK Response: {JsonSerializer.Serialize(payment)}");

        // Check if SDK response indicates error
        var paymentDict = payment as Dictionary<string, object>;
        if (paymentDict?.ContainsKey("status") == true && 
            (paymentDict["status"]?.ToString() == "REQUEST_ERROR" || paymentDict["status"]?.ToString() == "ERROR")) {
            throw new Exception($"PayGlocal SDK Error: {paymentDict.GetValueOrDefault("message", "Unknown error")}");
        }

        await context.Response.WriteAsync(JsonSerializer.Serialize(payment));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Capture failed: {error}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = ex.Message }));
    }
});

// Auth Reversal endpoint
app.MapPost("/api/authreversal", async (HttpContext context) =>
{
    try
    {
        Console.WriteLine(">>> /api/authreversal endpoint hit");
        
        // Read request body
        string requestBodyJson;
        using (var reader = new StreamReader(context.Request.Body))
        {
            requestBodyJson = await reader.ReadToEndAsync();
        }

        // Parse JSON
        var requestBody = JsonSerializer.Deserialize<Dictionary<string, object>>(requestBodyJson, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (requestBody == null)
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Invalid JSON payload" }));
            return;
        }

        // Extract gid from request
        if (!requestBody.TryGetValue("gid", out var gidObj) || gidObj == null)
        {
            Console.WriteLine("Missing gid");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Missing required field: gid" }));
            return;
        }

        string gid = gidObj.ToString();

        // Create payload for auth reversal
        var payload = new Dictionary<string, object>
        {
            ["gid"] = gid
        };

        var payment = await client.InitiateAuthReversal(payload);
        Console.WriteLine($"Raw SDK Response: {JsonSerializer.Serialize(payment)}");

        // Check if SDK response indicates error
        var paymentDict = payment as Dictionary<string, object>;
        if (paymentDict?.ContainsKey("status") == true && 
            (paymentDict["status"]?.ToString() == "REQUEST_ERROR" || paymentDict["status"]?.ToString() == "ERROR")) {
            throw new Exception($"PayGlocal SDK Error: {paymentDict.GetValueOrDefault("message", "Unknown error")}");
        }

        await context.Response.WriteAsync(JsonSerializer.Serialize(payment));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Auth reversal failed: {error}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = ex.Message }));
    }
});

// Status endpoint
app.MapGet("/api/status", async (HttpContext context) =>
{
    try
    {
        Console.WriteLine(">>> /api/status endpoint hit");
        
        // Get gid from query parameters
        if (!context.Request.Query.TryGetValue("gid", out var gidValues) || !gidValues.Any())
        {
            Console.WriteLine("Missing gid");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Missing required parameter: gid" }));
            return;
        }

        string gid = gidValues.First();
        Console.WriteLine($"Received status check request: gid={gid}");

        // Create payload for status check
        var payload = new Dictionary<string, object>
        {
            ["gid"] = gid
        };

        var payment = await client.CheckStatus(payload);
        Console.WriteLine($"Raw SDK Response: {JsonSerializer.Serialize(payment)}");

        // Check if SDK response indicates error
        var paymentDict = payment as Dictionary<string, object>;
        if (paymentDict?.ContainsKey("status") == true && 
            (paymentDict["status"]?.ToString() == "REQUEST_ERROR" || paymentDict["status"]?.ToString() == "ERROR")) {
            throw new Exception($"PayGlocal SDK Error: {paymentDict.GetValueOrDefault("message", "Unknown error")}");
        }

        await context.Response.WriteAsync(JsonSerializer.Serialize(payment));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Status check failed: {error}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = ex.Message }));
    }
});

// SI Pause/Activate endpoint
app.MapPost("/api/si-pause-activate", async (HttpContext context) =>
{
    try
    {
        Console.WriteLine("Received request to initiate pause/activate SI");
        
        // Read request body
        string requestBodyJson;
        using (var reader = new StreamReader(context.Request.Body))
        {
            requestBodyJson = await reader.ReadToEndAsync();
        }

        // Parse JSON
        var requestBody = JsonSerializer.Deserialize<Dictionary<string, object>>(requestBodyJson, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (requestBody == null)
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Invalid JSON payload" }));
            return;
        }

        // Validate required fields
        var requiredFields = new[] { "siId", "action" };
        var missingFields = requiredFields.Where(field => !requestBody.ContainsKey(field)).ToArray();
        
        if (missingFields.Any())
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { 
                error = "Missing required fields", 
                details = new { requiredFields = new[] { "siId", "action" } }
            }));
            return;
        }

        // Extract action
        string action = requestBody["action"].ToString().ToLower();
        
        // Create payload based on action
        var payload = new Dictionary<string, object>
        {
            ["siId"] = requestBody["siId"]
        };

        Console.WriteLine($"Initiating SI with payload: {JsonSerializer.Serialize(payload)}");

        object response;
        if (action == "pause")
        {
            response = await client.PauseSi(payload);
        }
        else if (action == "activate")
        {
            response = await client.ActivateSi(payload);
        }
        else
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = "Invalid action. Must be 'pause' or 'activate'" }));
            return;
        }

        Console.WriteLine($"Raw SDK Response: {JsonSerializer.Serialize(response)}");

        // Check if SDK response indicates error
        var responseDict = response as Dictionary<string, object>;
        if (responseDict?.ContainsKey("status") == true && 
            (responseDict["status"]?.ToString() == "REQUEST_ERROR" || responseDict["status"]?.ToString() == "ERROR")) {
            throw new Exception($"PayGlocal SDK Error: {responseDict.GetValueOrDefault("message", "Unknown error")}");
        }

        await context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"SI pause/activate failed: {error}");
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = ex.Message }));
    }
});

app.Run();
