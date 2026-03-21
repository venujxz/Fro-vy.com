# Fro-vy Backend Server

Node.js/Express backend server for handling PayHere payments and OCR ingredient analysis in the Fro-vy app (Sri Lanka).

## Prerequisites

- Node.js 18+ installed
- A PayHere merchant account (https://www.payhere.lk)
- A Google Cloud account with Vision API enabled
- Firebase Admin SDK service account key

## Setup

### 1. Install dependencies

```bash
cd backend
npm install
```

### 2. Configure Google Cloud Vision API

1. **Enable the Vision API**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the Cloud Vision API from APIs & Services

2. **Create a Service Account**:
   - Go to IAM & Admin > Service Accounts
   - Create a new service account
   - Grant it the "Cloud Vision AI User" role
   - Create and download a JSON key file

3. **Configure the key path**:
   - You can use the same `firebase-key.json` if it has Vision API permissions
   - Or place your Vision API key in the backend folder
   - Update `GOOGLE_VISION_KEY_PATH` in your `.env` file

### 3. Configure PayHere credentials

1. **For Testing (Sandbox)**:
   - Go to [PayHere Sandbox](https://sandbox.payhere.lk)
   - Create a sandbox account
   - Get your Merchant ID and Merchant Secret from Settings > API Keys

2. **For Production**:
   - Go to [PayHere](https://www.payhere.lk)
   - Complete merchant verification
   - Get your live credentials from Settings > API Keys

### 4. Create environment file

1. Create a `.env` file:

```bash
cp .env.example .env
```

2. Edit `.env` with your credentials:

```env
PAYHERE_MERCHANT_ID=YOUR_MERCHANT_ID
PAYHERE_MERCHANT_SECRET=YOUR_MERCHANT_SECRET
PAYHERE_SANDBOX=true
PORT=3000
GOOGLE_VISION_KEY_PATH=./firebase-key.json
```

### 5. Update Flutter app configuration

Open `lib/config/payhere_config.dart` and update:

```dart
static const String merchantId = 'YOUR_MERCHANT_ID';
static const bool isSandbox = true;  // false for production
```

### 6. Run the server

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

### Analyze Image (OCR)
```
POST /analyze-image
Content-Type: multipart/form-data

Body:
- image (file): The product label image

Response:
{
  "status": "Success",
  "extractedText": "Ingredients: Sugar, Milk, Wheat...",
  "safetyLevel": "Safe" | "Caution" | "Unsafe" | "Unknown",
  "analysis": "No harmful ingredients detected.",
  "harmfulIngredients": [],
  "allergens": ["milk", "wheat"],
  "ingredients": ["sugar", "milk", "wheat"]
}
```

**Safety Levels:**
- `Safe`: No harmful ingredients or allergens detected
- `Caution`: Contains common allergens
- `Unsafe`: Contains potentially harmful ingredients
- `Unknown`: No text detected in image

### Get User Subscription
```
GET /user/:userId/subscription

Response:
{
  "plan": "Pro",
  "isActive": true,
  "subscriptionEndDate": "2026-04-20T12:00:00.000Z",
  "scansPerMonth": -1,
  "hasUnlimitedScans": true,
  "hasBarcodeOCR": true,
  "hasDetailedInsights": true,
  "hasAIRecommendations": false,
  "hasDietitianConsult": false
}
```

**Note:** Returns Free plan defaults if user doesn't exist or subscription is expired.

### Search Ingredients
```
GET /ingredients/search?query=sugar&category=caution

Response:
{
  "query": "sugar",
  "count": 3,
  "results": [
    {
      "id": "abc123",
      "name": "Cane Sugar",
      "searchName": "cane sugar",
      "category": "caution",
      "reason": "A simple carbohydrate that provides...",
      "lastUpdated": "2026-02-17T11:51:23.144346"
    }
  ]
}
```

**Parameters:**
- `query` (required): Search term
- `category` (optional): Filter by category (beneficial, caution, avoid)

### Get All Ingredients
```
GET /ingredients/all?category=avoid&limit=100

Response:
{
  "count": 12,
  "results": [...]
}
```

**Parameters:**
- `category` (optional): Filter by category
- `limit` (optional): Maximum results (default: 50)

## Setting Up Ingredients Database

Before the ingredient search feature works, you need to populate Firestore:

```bash
cd backend
node populate-ingredients.js
```

This script will:
- Read from `IngredientDatabase/ingredients.json`
- Upload all ingredients to Firestore `ingredients` collection
- Create searchable entries with lowercase names

After running the script, create these indexes in Firebase Console:
1. Collection: `ingredients`
2. Fields: `searchName` (Ascending), `category` (Ascending)

## OCR & Ingredient Analysis Flow

1. User captures/selects a product label image in the app
2. App compresses the image to reduce bandwidth
3. App sends the image to `/analyze-image`
4. Backend uses Google Cloud Vision API to extract text
5. Backend analyzes ingredients for harmful substances and allergens
6. Backend returns safety analysis to the app
7. App displays results to the user

## PayHere Payment Flow

1. User selects a plan in the app
2. App calls `/payhere/generate-hash` to get secure hash
3. App opens PayHere payment SDK with the hash
   - `custom_1`: Plan name ('Pro' or 'Premium')
   - `custom_2`: User ID (required for subscription updates)
4. User completes payment on PayHere
5. PayHere sends notification to `/payhere/notify`
6. Backend updates user subscription in Firestore
7. App verifies payment via `/payhere/verify/:orderId`

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
