# Payment Integration Guide

## Overview

GOGOMARKET supports two payment gateways for Uzbekistan:
- **Payme** (JSON-RPC based)
- **Click** (HTTP POST callbacks)

## Configuration

Add to `.env`:

```env
# Payme
PAYME_MERCHANT_ID=your_merchant_id
PAYME_SECRET_KEY=your_secret_key
PAYME_BASE_URL=https://checkout.paycom.uz/api

# Click
CLICK_MERCHANT_ID=your_merchant_id
CLICK_SERVICE_ID=your_service_id
CLICK_SECRET_KEY=your_secret_key
CLICK_BASE_URL=https://my.click.uz/services/pay

# Platform
PLATFORM_COMMISSION_RATE=0.1
```

## API Endpoints

### Create Payment Link
```http
POST /api/payments/create-link
Authorization: Bearer <token>

{
  "orderId": "uuid",
  "provider": "payme" | "click",
  "returnUrl": "https://app.gogomarket.uz/orders/success"
}

Response:
{
  "paymentLink": "https://checkout.paycom.uz/..."
}
```

### Get Order Transactions
```http
GET /api/payments/order/:orderId
Authorization: Bearer <token>
```

### Payme Webhook (JSON-RPC)
```http
POST /api/payments/payme/callback
Authorization: Basic <base64(Paycom:SECRET_KEY)>

{
  "jsonrpc": "2.0",
  "id": 123,
  "method": "CreateTransaction",
  "params": {
    "id": "transaction_id",
    "time": 1234567890,
    "amount": 1000000,
    "account": {
      "order_id": "uuid"
    }
  }
}
```

### Click Webhooks
```http
POST /api/payments/click/prepare
POST /api/payments/click/complete

{
  "click_trans_id": "123",
  "service_id": "456",
  "merchant_trans_id": "order_uuid",
  "amount": "10000",
  "action": "0",
  "sign_time": "2024-01-01 12:00:00",
  "sign_string": "md5_hash"
}
```

## Payment Flow

### 1. User initiates payment
```
Mobile App → POST /api/payments/create-link
API → Generate payment link
API → Return link to app
App → Redirect user to payment gateway
```

### 2. User completes payment
```
Payment Gateway → POST /api/payments/payme/callback (or click/prepare)
API → Verify signature
API → Create transaction
API → Return success

Payment Gateway → POST /api/payments/payme/callback (PerformTransaction)
API → Mark transaction as PAID
API → Update order payment status
API → Trigger order confirmation
```

### 3. User returns to app
```
Payment Gateway → Redirect to returnUrl
App → Show success page
App → Refresh order status
```

## Payme Methods

1. **CheckPerformTransaction** - Validate order before payment
2. **CreateTransaction** - Create pending transaction
3. **PerformTransaction** - Confirm payment
4. **CancelTransaction** - Cancel payment
5. **CheckTransaction** - Get transaction status

## Click Flow

1. **Prepare** - Validate order and amount
2. **Complete** - Confirm payment and update order

## Security

- All callbacks verify signatures
- Payme uses Basic Auth with secret key
- Click uses MD5 signature verification
- Transaction IDs are unique and tracked

## Testing

### Payme Test Cards
```
Card: 8600 4954 7331 6478
Expiry: 03/99
SMS Code: 666666
```

### Click Test
Use Click's test environment and credentials

## Error Codes

### Payme Errors
- `-32504` - Invalid signature
- `-32601` - Method not found
- `-31050` - Order not found
- `-31001` - Insufficient amount

### Click Errors
- `-1` - Invalid signature
- `-5` - Order not found
- `-9` - Transaction cancelled

## Webhooks Setup

Configure these URLs in payment gateway admin panels:

**Payme:**
- Callback URL: `https://api.gogomarket.uz/api/payments/payme/callback`

**Click:**
- Prepare URL: `https://api.gogomarket.uz/api/payments/click/prepare`
- Complete URL: `https://api.gogomarket.uz/api/payments/click/complete`

## Commission

Platform takes 10% commission (configurable via `PLATFORM_COMMISSION_RATE`).
Calculated on order creation and stored in `order.platformFee`.
