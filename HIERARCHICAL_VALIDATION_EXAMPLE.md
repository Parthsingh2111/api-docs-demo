# Hierarchical Validation Examples

This document demonstrates how the new hierarchical validation works in both pg-client-sdk and pgpd-client-sdk.

## What It Does

The hierarchical validation ensures that objects in the payload are placed in their correct hierarchical positions. If an object is not in its expected place, it generates a **warning** but still allows the payload to work.

## Example 1: Correctly Structured Payload

```javascript
// ✅ This payload will pass without warnings
{
  "merchantTxnId": "123",
  "merchantCallbackURL": "https://example.com/callback",
  "paymentData": {
    "totalAmount": "100.00",
    "txnCurrency": "USD",
    "cardData": {
      "number": "4111111111111111",
      "expiryMonth": "12",
      "expiryYear": "2025",
      "securityCode": "123",
      "type": "VISA"
    }
  }
}
```

## Example 2: Misplaced Object (Will Generate Warning)

```javascript
// ⚠️ This payload will work but generate warnings
{
  "merchantTxnId": "123",
  "merchantCallbackURL": "https://example.com/callback",
  "paymentData": {
    "totalAmount": "100.00",
    "txnCurrency": "USD"
  },
  // ⚠️ WARNING: cardData is at root level but should be inside paymentData
  "cardData": {
    "number": "4111111111111111",
    "expiryMonth": "12",
    "expiryYear": "2025",
    "securityCode": "123",
    "type": "VISA"
  }
}
```

**Warning Generated:**
```
Hierarchical Warning: Object "cardData" at path "cardData" might be misplaced. Expected at level: paymentData
```

## Example 3: Deeply Nested Misplacement

```javascript
// ⚠️ This payload will work but generate multiple warnings
{
  "merchantTxnId": "123",
  "merchantCallbackURL": "https://example.com/callback",
  "paymentData": {
    "totalAmount": "100.00",
    "txnCurrency": "USD"
  },
  "riskData": {
    "orderData": [
      {
        "productDescription": "Product 1",
        "productSKU": "SKU001",
        "productType": "PHYSICAL",
        "itemUnitPrice": "50.00",
        "itemQuantity": "2"
      }
    ]
  },
  // ⚠️ WARNING: passengerData is at root level but should be inside riskData.flightData
  "passengerData": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "dateOfBirth": "1990-01-01",
      "type": "ADULT",
      "email": "john@example.com"
    }
  ]
}
```

**Warnings Generated:**
```
Hierarchical Warning: Object "passengerData" at path "passengerData" might be misplaced. Expected at level: riskData
```

## Example 4: Complex Misplacement Scenario

```javascript
// ⚠️ This payload will work but generate multiple warnings
{
  "merchantTxnId": "123",
  "merchantCallbackURL": "https://example.com/callback",
  "paymentData": {
    "totalAmount": "100.00",
    "txnCurrency": "USD",
    // ⚠️ WARNING: billingData fields are mixed with paymentData fields
    "fullName": "John Doe",
    "emailId": "john@example.com"
  },
  // ⚠️ WARNING: billingData is at root level but should be inside paymentData
  "billingData": {
    "firstName": "John",
    "lastName": "Doe",
    "addressStreet1": "123 Main St",
    "addressCity": "New York",
    "addressState": "NY",
    "addressPostalCode": "10001",
    "addressCountry": "US"
  }
}
```

**Warnings Generated:**
```
Hierarchical Warning: Object "fullName" at path "paymentData.fullName" might be misplaced. Expected at level: paymentData
Hierarchical Warning: Object "emailId" at path "paymentData.emailId" might be misplaced. Expected at level: paymentData
Hierarchical Warning: Object "billingData" at path "billingData" might be misplaced. Expected at level: paymentData
```

## How to Use the Validation

### 1. Basic Usage

```javascript
const { validatePaycollectPayload } = require('./lib/utils/schemaValidator');

try {
  const result = validatePaycollectPayload(payload);
  
  if (result.warningCount > 0) {
    console.log(`⚠️  ${result.warningCount} hierarchical warnings detected`);
    result.hierarchicalWarnings.forEach(warning => {
      console.log(`   - ${warning.message}`);
    });
  } else {
    console.log('✅ No hierarchical warnings');
  }
  
  console.log('✅ Payload is valid and ready for processing');
} catch (error) {
  console.error('❌ Schema validation failed:', error.message);
}
```

### 2. Accessing Warnings Programmatically

```javascript
const result = validatePaycollectPayload(payload);

// Check if there are warnings
if (result.hierarchicalWarnings && result.hierarchicalWarnings.length > 0) {
  // Process warnings
  result.hierarchicalWarnings.forEach(warning => {
    console.log(`Warning: ${warning.message}`);
    console.log(`  Current Path: ${warning.currentPath}`);
    console.log(`  Expected Level: ${warning.expectedPath}`);
    console.log(`  Object Type: ${warning.objectType}`);
  });
}
```

## Expected Hierarchy Structure

### Root Level
- `merchantTxnId`
- `merchantUniqueId`
- `merchantCallbackURL`
- `captureTxn`
- `gpiTxnTimeout`
- `paymentData`
- `standingInstruction`
- `riskData`

### paymentData Level
- `totalAmount`
- `txnCurrency`
- `cardData`
- `tokenData`
- `billingData`

### riskData Level
- `orderData`
- `customerData`
- `shippingData`
- `flightData`
- `trainData`
- `busData`
- `shipData`
- `cabData`
- `lodgingData`

## Benefits

1. **Non-Breaking**: Warnings don't stop payload processing
2. **Educational**: Developers learn the correct structure
3. **Flexible**: Allows payloads to work even with structural issues
4. **Debugging**: Helps identify placement problems
5. **Documentation**: Serves as live documentation of expected structure

## Best Practices

1. **Fix Warnings**: Address hierarchical warnings for cleaner code
2. **Follow Structure**: Use the documented hierarchy for best results
3. **Monitor Logs**: Check for warnings in production logs
4. **Document Changes**: Update hierarchy if API structure changes
5. **Test Scenarios**: Test with various payload structures

## Conclusion

The hierarchical validation provides a balance between flexibility and guidance. It allows developers to send payloads that work while educating them about the proper structure. This approach improves developer experience without breaking existing integrations. 