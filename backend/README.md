# Fro-vy PayHere Payment Backend

Node.js/Express backend server for handling PayHere payments in the Fro-vy app (Sri Lanka).

## Prerequisites

- Node.js 18+ installed
- A PayHere merchant account (https://www.payhere.lk)

## Setup

### 1. Install dependencies

```bash
cd backend
npm install
```

### 2. Configure PayHere credentials

1. **For Testing (Sandbox)**:
   - Go to [PayHere Sandbox](https://sandbox.payhere.lk)
   - Create a sandbox account
   - Get your Merchant ID and Merchant Secret from Settings > API Keys

2. **For Production**:
   - Go to [PayHere](https://www.payhere.lk)
   - Complete merchant verification
   - Get your live credentials from Settings > API Keys

3. Create a `.env` file:

```bash
cp .env.example .env
```

4. Edit `.env` with your credentials:

```env
PAYHERE_MERCHANT_ID=YOUR_MERCHANT_ID
PAYHERE_MERCHANT_SECRET=YOUR_MERCHANT_SECRET
PAYHERE_SANDBOX=true
PORT=3000
```

### 3. Update Flutter app configuration

Open `lib/config/payhere_config.dart` and update:

```dart
static const String merchantId = 'YOUR_MERCHANT_ID';
static const bool isSandbox = true;  // false for production
```

### 4. Run the server

Development (with auto-reload):
```bash
npm run dev
```

Production:
```bash
npm start
```

## API Endpoints

### Health Check
```
GET /health
```

### Generate Payment Hash
```
POST /payhere/generate-hash
Content-Type: application/json

{
  "orderId": "FROVY_123456789",
  "amount": "900.00",
  "currency": "LKR"
}

Response:
{
  "hash": "ABC123DEF456..."
}
```

### Payment Notification (IPN)
```
POST /payhere/notify
Content-Type: application/x-www-form-urlencoded

(PayHere sends this automatically after payment)
```

### Verify Payment
```
GET /payhere/verify/:orderId

Response:
{
  "verified": true,
  "orderId": "FROVY_123456789",
  "paymentId": "320012345678",
  "planName": "Pro",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### List All Payments (Debug)
```
GET /payhere/payments
```

## PayHere Payment Flow

1. User selects a plan in the app
2. App calls `/payhere/generate-hash` to get secure hash
3. App opens PayHere payment SDK with the hash
4. User completes payment on PayHere
5. PayHere sends notification to `/payhere/notify`
6. App verifies payment via `/payhere/verify/:orderId`

## Payment Status Codes

| Code | Status |
|------|--------|
| 2 | Success |
| 0 | Pending |
| -1 | Canceled |
| -2 | Failed |
| -3 | Chargedback |

## Testing

### Sandbox Test Cards

Use these test cards in sandbox mode:

**Successful Payment:**
- Card Number: `4916217501611292`
- Expiry: Any future date
- CVV: Any 3 digits
- Name: Any name

**Failed Payment:**
- Card Number: `4242424242424242`

## Production Deployment

1. Update `PAYHERE_SANDBOX=false` in `.env`
2. Use your live Merchant ID and Secret
3. Update `lib/config/payhere_config.dart`:
   ```dart
   static const bool isSandbox = false;
   ```
4. Set up HTTPS for your server
5. Configure the notify URL in PayHere dashboard to point to your live server

## Supported Payment Methods in Sri Lanka

- Visa / Mastercard (Credit & Debit)
- AMEX
- Local bank transfers
- FriMi, iPay, and other mobile wallets
- Dialog/Mobitel mobile billing

## iOS Configuration

Add URL scheme to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>frovy</string>
        </array>
    </dict>
</array>
```

## Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="frovy" />
</intent-filter>
```

## Pricing in LKR

The app shows prices in USD for reference, but PayHere charges in LKR:

| Plan | USD | LKR (approx) |
|------|-----|--------------|
| Pro | $2.99 | LKR 900 |
| Premium | $6.99 | LKR 2,100 |

Update these values in `lib/config/payhere_config.dart` based on current exchange rates.
