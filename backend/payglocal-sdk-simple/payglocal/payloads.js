/**
 * =============================================================================
 * PAYLOAD STRUCTURES  —  REFERENCE ONLY
 * =============================================================================
 *
 * This file does nothing. It is here to answer one question:
 *
 *      "What payload structure do I need to send to initiate()?"
 *
 * Find the structure that matches your business below, copy it into your own
 * application, fill it with your real values, and pass it to initiate():
 *
 *      import { initiate } from './payglocal/initiate.js';
 *
 *      const payload = { ...your payload, built from a template below... };
 *      const payment = await initiate(payload);
 *
 *      res.redirect(payment.paymentUrl);
 *
 * The SDK sends whatever you give it. It does not inspect, rebuild, or second
 * guess your payload — it only handles authentication, encryption and the API
 * request. So the structure below is the structure PayGlocal receives.
 *
 * The values in here are examples. Replace all of them.
 *
 *
 * ----------------------------------------------------------------------------
 * WHICH STRUCTURE DO I NEED?
 * ----------------------------------------------------------------------------
 *
 *   1. SERVICE     nothing is shipped: software, subscriptions, consulting
 *   2. GOODS       something physical is shipped
 *   3. RECURRING   the customer is charged again on a schedule
 *   4. AIRLINE     flight tickets, one way
 *   5. AIRLINE     flight tickets, return
 *
 *
 * ----------------------------------------------------------------------------
 * RULES THAT APPLY TO EVERY STRUCTURE
 * ----------------------------------------------------------------------------
 *
 *   Amounts            TEXT, never a number: "15", "499.00". Both are valid.
 *                      Text because 0.1 + 0.2 is 0.30000000000000004.
 *   txnCurrency        Three uppercase letters: "INR", "USD".
 *   merchantTxnId      Your own order id. Must be DIFFERENT for every attempt,
 *                      including a retry of the same cart. PayGlocal sends it
 *                      back to you in the callback and the webhook.
 *   Country codes      Two letters: "IN", "US", "AE".
 *   callingCode        WITH the plus sign: "+91".
 *
 *   riskData           TOP LEVEL, beside paymentData. It is NOT inside it.
 *                      This is the single most common mistake.
 *
 *   merchantCallbackURL
 *                      Where PayGlocal returns the customer's browser. Include
 *                      it in the payload as shown. If you leave it out, the SDK
 *                      falls back to config.callbackUrl.
 *
 *   TWO DIFFERENT DATE FORMATS. Mixing them up is the second most common mistake:
 *
 *      startDate, reservationDate      "20251001"               YYYYMMDD
 *      departureDate, arrivalDate      "2025-03-20T09:01:56Z"   ISO 8601 UTC
 */

// =============================================================================
// 1. SERVICE  —  nothing is shipped
// =============================================================================
// The customer is described by paymentData.billingData.

export const servicePayload = {
  merchantTxnId: '23AEE8CB6B62EE2AF07',
  paymentData: {
    totalAmount: '15',
    txnCurrency: 'USD',
    billingData: {
      firstName: 'John',
      lastName: 'Denver',
      addressStreet1: 'Test123',
      addressStreet2: 'Punctuality lane',
      addressCity: 'Bangalore',
      addressState: 'Karnataka',
      addressPostalCode: '560094',
      addressCountry: 'IN',
      emailId: 'johndenver@myemail.com',
    },
  },
  merchantCallbackURL: 'https://your-site.com/payglocal/callback',
};

// =============================================================================
// 2. GOODS  —  something physical is shipped
// =============================================================================
// The customer is described by riskData.shippingData instead, and riskData sits
// at the TOP LEVEL. paymentData carries only the amount and currency.
// Add paymentData.billingData as well only if PayGlocal asks you for both.

export const goodsPayload = {
  merchantTxnId: '23AEE8CB6B62EE2AF07',
  paymentData: {
    totalAmount: '15',
    txnCurrency: 'USD',
  },
  riskData: {
    shippingData: {
      firstName: 'John',
      lastName: 'Denver',
      addressStreet1: 'Test123',
      addressStreet2: 'Punctuality lane',
      addressCity: 'Bangalore',
      addressState: 'Karnataka',
      addressPostalCode: '560094',
      addressCountry: 'IN',
      emailId: 'johndenver@myemail.com',
      callingCode: '+91',
      phoneNumber: '9008018469',
    },
  },
  merchantCallbackURL: 'https://your-site.com/payglocal/callback',
};

// =============================================================================
// 3. RECURRING  —  standing instruction, charged on a schedule
// =============================================================================
// Adds a top-level standingInstruction block.
//
//   amount            TEXT. The recurring charge. Usually equal to totalAmount.
//   numberOfPayments  TEXT, not a number: "12".
//   frequency         "MONTHLY". Ask PayGlocal for the full list you may use.
//   type              "FIXED", every charge is the same amount.
//                     For amounts that vary, ask PayGlocal for the exact fields.
//   startDate         "20251001"  YYYYMMDD, no dashes.

export const recurringPayload = {
  merchantTxnId: '1756728757520948273',
  paymentData: {
    totalAmount: '499.00',
    txnCurrency: 'INR',
  },
  standingInstruction: {
    data: {
      amount: '499.00',
      numberOfPayments: '12',
      frequency: 'MONTHLY',
      type: 'FIXED',
      startDate: '20251001',
    },
  },
  merchantCallbackURL: 'https://your-site.com/payglocal/callback',
};

// =============================================================================
// 4. AIRLINE  —  one way
// =============================================================================
// Adds riskData.flightData, an ARRAY of journeys. Each journey has the itinerary
// in legData and everyone travelling in passengerData.
//
//   journeyType           "ONEWAY"
//   ticketNumber          your ticket reference
//   reservationDate       "20251201"  YYYYMMDD  <- not the ISO format below
//
//   Each leg:
//   routeId               "1" outbound, "2" return
//   legId                 "1", "2", ... within that route
//   flightNumber          "flight123"
//   departureAirportCode  IATA code, "AUH"
//   departureCity         "Abu Dhabi"
//   departureCountry      "AE"
//   departureDate         "2023-03-20T09:01:56Z"  ISO 8601 UTC
//   arrivalAirportCode    "BLR"
//   arrivalCity           "Bangalore"
//   arrivalCountry        "IN"
//   arrivalDate           "2023-03-21T09:01:56Z"  ISO 8601 UTC
//   carrierCode           "AAL"
//   airlineServiceClass   "ECONOMY"

export const airlineOneWayPayload = {
  merchantTxnId: '23AEE8CB6B62EE2AF07',
  paymentData: {
    totalAmount: '101',
    txnCurrency: 'INR',
    billingData: {
      firstName: 'Sam',
      lastName: 'Thomas',
      addressStreet1: 'Apartment 9B,235 East,43rd Street',
      addressCity: 'New York',
      addressState: 'New York',
      addressCountry: 'US',
      emailId: 'sam.thomas@gmail.com',
    },
  },
  riskData: {
    flightData: [
      {
        journeyType: 'ONEWAY',
        ticketNumber: 'ticket12345',
        reservationDate: '20251201',
        legData: [
          {
            routeId: '1',
            legId: '1',
            flightNumber: 'flight123',
            departureAirportCode: 'AUH',
            departureCity: 'Abu Dhabi',
            departureCountry: 'AE',
            departureDate: '2023-03-20T09:01:56Z',
            arrivalAirportCode: 'BLR',
            arrivalCity: 'Bangalore',
            arrivalCountry: 'IN',
            arrivalDate: '2023-03-21T09:01:56Z',
            carrierCode: 'AAL',
            airlineServiceClass: 'ECONOMY',
          },
        ],
        passengerData: [
          {
            firstName: 'Sam',
            lastName: 'Thomas',
          },
        ],
      },
    ],
  },
  merchantCallbackURL: 'https://your-site.com/payglocal/callback',
};

// =============================================================================
// 5. AIRLINE  —  return
// =============================================================================
// Same shape as one way. Three differences:
//
//   journeyType is "RETURN".
//
//   legData lists EVERY flight in the trip. routeId groups them: routeId "1" is
//   the outbound journey, routeId "2" is the way back. legId numbers the flights
//   within one route, so a trip with a connection each way is
//   routeId 1/legId 1, routeId 1/legId 2, routeId 2/legId 1, routeId 2/legId 2.
//
//   passengerData lists every traveller, not only the person paying.
//
// This example also carries an extra riskData.billingData holding just the email.
// Include it if PayGlocal asks you to.

export const airlineReturnPayload = {
  merchantTxnId: '23AEE8CB6B62EE2AF08',
  paymentData: {
    totalAmount: '2902',
    txnCurrency: 'INR',
    billingData: {
      firstName: 'Roy',
      lastName: 'Thomas',
      addressStreet1: 'Apartment 9B, 235 East, 43rd Street',
      addressCity: 'New York',
      addressState: 'New York',
      addressCountry: 'US',
      emailId: 'sam.thomas@gmail.com',
    },
  },
  riskData: {
    billingData: {
      emailId: 'sam.thomas@gmail.com',
    },
    flightData: [
      {
        journeyType: 'RETURN',
        ticketNumber: 'ticket56789',
        reservationDate: '20250601',
        legData: [
          // Outbound: New York -> Abu Dhabi -> Bangalore
          {
            routeId: '1',
            legId: '1',
            flightNumber: 'NY123',
            departureAirportCode: 'JFK',
            departureCity: 'New York',
            departureCountry: 'US',
            departureDate: '2024-06-10T08:00:00Z',
            arrivalAirportCode: 'AUH',
            arrivalCity: 'Abu Dhabi',
            arrivalCountry: 'AE',
            arrivalDate: '2024-06-10T20:00:00Z',
            carrierCode: 'AAL',
            airlineServiceClass: 'ECONOMY',
          },
          {
            routeId: '1',
            legId: '2',
            flightNumber: 'AUH456',
            departureAirportCode: 'AUH',
            departureCity: 'Abu Dhabi',
            departureCountry: 'AE',
            departureDate: '2024-06-11T02:00:00Z',
            arrivalAirportCode: 'BLR',
            arrivalCity: 'Bangalore',
            arrivalCountry: 'IN',
            arrivalDate: '2024-06-11T08:00:00Z',
            carrierCode: 'AAL',
            airlineServiceClass: 'ECONOMY',
          },
          // Return: Bangalore -> Abu Dhabi -> New York
          {
            routeId: '2',
            legId: '1',
            flightNumber: 'BLR789',
            departureAirportCode: 'BLR',
            departureCity: 'Bangalore',
            departureCountry: 'IN',
            departureDate: '2024-06-20T10:00:00Z',
            arrivalAirportCode: 'AUH',
            arrivalCity: 'Abu Dhabi',
            arrivalCountry: 'AE',
            arrivalDate: '2024-06-20T16:00:00Z',
            carrierCode: 'AAL',
            airlineServiceClass: 'ECONOMY',
          },
          {
            routeId: '2',
            legId: '2',
            flightNumber: 'AUH321',
            departureAirportCode: 'AUH',
            departureCity: 'Abu Dhabi',
            departureCountry: 'AE',
            departureDate: '2024-06-21T00:00:00Z',
            arrivalAirportCode: 'JFK',
            arrivalCity: 'New York',
            arrivalCountry: 'US',
            arrivalDate: '2024-06-21T10:00:00Z',
            carrierCode: 'AAL',
            airlineServiceClass: 'ECONOMY',
          },
        ],
        passengerData: [
          {
            firstName: 'Sam',
            lastName: 'Thomas',
          },
          {
            firstName: 'John',
            lastName: 'Denver',
          },
        ],
      },
    ],
  },
  merchantCallbackURL: 'https://your-site.com/payglocal/callback',
};
