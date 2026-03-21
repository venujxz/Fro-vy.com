# Fro-vy Backend API Documentation

## 🚀 Server Status
- **Base URL:** `http://localhost:3000`
- **Status:** ✅ Running
- **Database:** Firebase Firestore
- **Products:** 156 loaded
- **Ingredients:** 171 loaded

## 📋 Table of Contents
1. [Text Analysis](#text-analysis)
2. [User Profile](#user-profile)
3. [Scan History](#scan-history)
4. [Products](#products)
5. [Ingredients](#ingredients)
6. [Health Check](#health-check)

---

## 🔍 Text Analysis

### POST `/analyze-text`
Analyze manually entered ingredient text with personalized health analysis.

**Request:**
```json
{
  "text": "Sugar, Milk, Wheat Flour, Artificial Color",
  "userId": "optional-user-id"  // Optional for personalized analysis
}
```

**Response:**
```json
{
  "status": "Success",
  "extractedText": "Sugar, Milk, Wheat Flour, Artificial Color",
  "safetyLevel": "Avoid",  // Safe, Caution, or Avoid
  "analysis": "Contains potentially harmful ingredients: artificial color",
  "harmfulIngredients": ["artificial color"],
  "allergens": ["milk", "wheat"],
  "personalWarnings": [
    {
      "type": "allergy",
      "ingredient": "Milk",
      "severity": "high",
      "message": "Contains Milk - You are allergic to this!"
    }
  ],
  "ingredients": [],
  "ingredientRatings": [],
  "isPersonalized": true
}
```

**Features:**
- ✅ Detects harmful ingredients
- ✅ Identifies common allergens
- ✅ Personalized warnings based on user allergies
- ✅ Medical condition interactions (diabetes, hypertension, etc.)
- ✅ Severity levels (high, medium, low)

---

## 👤 User Profile

### GET `/user/:userId/profile`
Get user's health profile.

**Response:**
```json
{
  "userId": "user-123",
  "name": "John Doe",
  "email": "john@example.com",
  "allergies": ["Milk", "Peanuts"],
  "medicalConditions": ["Diabetes"],
  "otherSensitivities": ["Lactose"],
  "subscription": {
    "plan": "Free",
    "isActive": true
  }
}
```

### PUT `/user/:userId/profile`
Update user's health profile.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "allergies": ["Milk", "Peanuts"],
  "medicalConditions": ["Diabetes", "Hypertension"],
  "otherSensitivities": ["Lactose"]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

---

## 📜 Scan History

### POST `/user/:userId/history`
Save a scan to user's history.

**Request:**
```json
{
  "productName": "Kotmale Chocolate Milk",
  "extractedText": "Milk, Sugar, Cocoa...",
  "safetyLevel": "Caution",
  "analysis": "Contains allergens...",
  "ingredients": ["Milk", "Sugar"],
  "harmfulIngredients": [],
  "allergens": ["Milk"],
  "personalWarnings": []
}
```

**Response:**
```json
{
  "success": true,
  "scanId": "scan-abc123"
}
```

### GET `/user/:userId/history?limit=50`
Get user's scan history.

**Response:**
```json
{
  "totalScans": 42,
  "history": [
    {
      "id": "scan-abc123",
      "productName": "Kotmale Chocolate Milk",
      "safetyLevel": "Caution",
      "scannedAt": "2026-03-21T05:30:00.000Z"
    }
  ]
}
```

### DELETE `/user/:userId/history/:scanId`
Delete a single scan.

### DELETE `/user/:userId/history`
Clear all scan history.

---

## 🛍️ Products

### GET `/products/search?query=kotmale&category=dairy&limit=20`
Search products by name or brand.

**Parameters:**
- `query` (required): Search term
- `category` (optional): dairy, bakery, beverages, snacks, etc.
- `limit` (optional): Default 20

**Response:**
```json
{
  "query": "kotmale",
  "count": 3,
  "results": [
    {
      "id": "prod-123",
      "productName": "Chocolate milk",
      "brandName": "Kotmale",
      "category": "dairy",
      "ingredients": ["Milk", "Sugar", "Cocoa Powder"],
      "ingredientCount": 12
    }
  ]
}
```

### GET `/products/all?category=dairy&limit=50`
Get all products, optionally filtered by category.

### GET `/products/:productId?userId=user-123`
Get product details with optional personalized analysis.

**Response:**
```json
{
  "id": "prod-123",
  "productName": "Chocolate milk",
  "brandName": "Kotmale",
  "ingredients": ["Milk", "Sugar"],
  "personalizedAnalysis": {
    "safetyLevel": "Avoid",
    "analysis": "PERSONAL ALERT: Contains Milk - You are allergic to this!",
    "personalWarnings": [...]
  }
}
```

---

## 🧪 Ingredients

### GET `/ingredients/search?query=sugar&category=caution&limit=20`
Search ingredients database.

**Response:**
```json
{
  "query": "sugar",
  "count": 3,
  "results": [
    {
      "id": "ing-123",
      "name": "Sugar",
      "category": "caution",  // beneficial, caution, or avoid
      "reason": "Simple carbohydrates that can lead to blood sugar spikes..."
    }
  ]
}
```

### GET `/ingredients/all?category=avoid&limit=50`
Get all ingredients, optionally filtered by category.

---

## ❤️ Health Check

### GET `/health`
Check if backend is running.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2026-03-21T05:30:00.000Z"
}
```

---

## 🧬 Personalized Analysis Features

The backend provides intelligent personalized analysis that:

### 1. **Allergy Detection**
- Checks ingredients against user's specific allergies
- High severity warnings for allergic ingredients
- Example: "Contains Milk - You are allergic to this!"

### 2. **Medical Condition Warnings**
- **Diabetes:** Warns about sugar, glucose, fructose, corn syrup
- **Hypertension:** Warns about sodium, salt, MSG
- **Heart Disease:** Warns about trans fats, saturated fats
- **Kidney Disease:** Warns about sodium, potassium, phosphorus
- **Celiac:** Warns about wheat, barley, rye, gluten
- **IBS:** Warns about lactose, fructose, FODMAPs
- **Gout:** Warns about purines, organ meats

### 3. **Sensitivity Tracking**
- Custom sensitivities from user profile
- Low severity warnings
- Example: "Contains Lactose - You noted sensitivity to this"

### 4. **Safety Levels**
- **Safe:** No harmful ingredients or personal concerns
- **Caution:** Contains common allergens or moderate concerns
- **Avoid:** Contains personal allergens or harmful ingredients

---

## 🔧 Setup Instructions

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment
Create `.env` file:
```env
PAYHERE_MERCHANT_ID=your-merchant-id
PAYHERE_MERCHANT_SECRET=your-secret
PAYHERE_SANDBOX=true
PORT=3000
```

### 3. Add Firebase Service Account
Place `firebase-key.json` in the backend folder.

### 4. Populate Databases
```bash
# Upload ingredients (171 ingredients)
npm run populate:ingredients

# Upload products (156 products)
npm run populate:products

# Or upload both
npm run populate:all
```

### 5. Start Server
```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start
```

### 6. Verify Server
```bash
curl http://localhost:3000/health
```

---

## 📊 Database Statistics

- **Products:** 156 items
  - Kotmale, Anchor, Maliban, Munchee, Nestle, and more
  - Categories: dairy, bakery, beverages, snacks, etc.

- **Ingredients:** 171 items
  - Categories: beneficial, caution, avoid
  - Includes detailed health reasons for each

---

## 🔐 Security Features

- ✅ Helmet.js for HTTP headers
- ✅ CORS protection
- ✅ Rate limiting (100 requests per 15 minutes)
- ✅ Input validation
- ✅ Firebase authentication ready

---

## 🎯 Next Steps for Production

1. **Firebase Indexes:** Create composite indexes in Firebase Console
2. **Environment Variables:** Set production values in `.env`
3. **SSL Certificate:** Use HTTPS in production
4. **Error Logging:** Add logging service (e.g., Sentry)
5. **Monitoring:** Add uptime monitoring
6. **Backup:** Schedule Firestore backups

---

## 📞 Support

For issues or questions:
- Check server logs for errors
- Verify Firebase connection
- Test with `/health` endpoint
- Check Firestore data in Firebase Console
