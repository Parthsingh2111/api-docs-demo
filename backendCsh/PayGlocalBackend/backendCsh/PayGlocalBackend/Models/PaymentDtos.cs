namespace PayGlocalBackend.Models
{
    public class PaymentPayload
    {
        public string merchantTxnId { get; set; } = string.Empty;
        public PaymentData paymentData { get; set; } = new PaymentData();
        public string merchantCallbackURL { get; set; } = string.Empty;
        public bool? captureTxn { get; set; }
        public object? riskData { get; set; }
        public StandingInstruction? standingInstruction { get; set; }
        public string? merchantUniqueId { get; set; }
        public object? selectedPaymentMethod { get; set; }
    }

    public class PaymentData
    {
        public string totalAmount { get; set; } = string.Empty;
        public string txnCurrency { get; set; } = string.Empty;
        public CardData? cardData { get; set; }
        public BillingData? billingData { get; set; }
    }

    public class CardData
    {
        public string number { get; set; } = string.Empty;
        public string expiryMonth { get; set; } = string.Empty;
        public string expiryYear { get; set; } = string.Empty;
        public string securityCode { get; set; } = string.Empty;
        public string? type { get; set; }
    }

    public class BillingData
    {
        public string? firstName { get; set; }
        public string? lastName { get; set; }
        public string? addressStreet1 { get; set; }
        public string? addressStreet2 { get; set; }
        public string? addressCity { get; set; }
        public string? addressState { get; set; }
        public string? addressPostalCode { get; set; }
        public string? addressCountry { get; set; }
        public string? emailId { get; set; }
        public string? callingCode { get; set; }
        public string? phoneNumber { get; set; }
    }

    public class StandingInstruction
    {
        public StandingInstructionData? data { get; set; }
        public string? action { get; set; }
        public string? mandateId { get; set; }
    }

    public class StandingInstructionData
    {
        public string? amount { get; set; }
        public string? maxAmount { get; set; }
        public string? numberOfPayments { get; set; }
        public string? frequency { get; set; }
        public string? type { get; set; }
        public string? startDate { get; set; }
    }
}
