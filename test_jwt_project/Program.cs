using System;
using System.Threading.Tasks;
using PayGlocal;

class Program
{
    static async Task Main(string[] args)
    {
        try
        {
            // Create a test client with debug logging
            var client = new PayGlocalClient(logLevel: "debug");
            
            // Test payload
            var payload = new
            {
                merchantTxnId = "test123",
                paymentData = new
                {
                    totalAmount = "100.00",
                    txnCurrency = "INR"
                },
                merchantCallbackURL = "https://api.uat.payglocal.in/gl/v1/payments/merchantCallback"
            };
            
            Console.WriteLine("Testing JWT generation...");
            var result = await client.InitiateJwtPayment(payload);
            Console.WriteLine("Success!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
            Console.WriteLine($"Stack Trace: {ex.StackTrace}");
        }
    }
}
