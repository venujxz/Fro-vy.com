require('dotenv').config();
const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// --- 1. FIREBASE SETUP ---
const admin = require('firebase-admin');
// Load the private key you just downloaded
const serviceAccount = require('./firebase-key.json');

// Initialize the Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Create a shortcut to the Firestore database
const db = admin.firestore();

// --- 2. ENVIRONMENT VALIDATION ---
const requiredEnvVars = ['PAYHERE_MERCHANT_ID', 'PAYHERE_MERCHANT_SECRET'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.error(`CRITICAL ERROR: Missing ${envVar} in .env file.`);
    process.exit(1); 
  }
}

const app = express();

// --- 3. SECURITY MIDDLEWARE ---
app.use(helmet()); 
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? process.env.ALLOWED_ORIGIN : '*',
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, 
  max: 100, 
  message: { error: 'Too many requests from this IP.' }
});

const notifyLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, 
  max: 10, 
  message: 'Too many webhook attempts'
});

app.use('/payhere/', apiLimiter);

app.use((req, res, next) => {
  if (req.originalUrl === '/payhere/notify') {
    express.urlencoded({ extended: true })(req, res, next);
  } else {
    express.json()(req, res, next);
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// --- 4. ROUTES ---

app.post('/payhere/generate-hash', (req, res) => {
  try {
    const { orderId, amount, currency } = req.body;

    if (!orderId || !amount || !currency) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const merchantId = process.env.PAYHERE_MERCHANT_ID;
    const merchantSecret = process.env.PAYHERE_MERCHANT_SECRET;

    const secretHash = crypto.createHash('md5').update(merchantSecret).digest('hex').toUpperCase();
    const hashString = merchantId + orderId + amount + currency + secretHash;
    const hash = crypto.createHash('md5').update(hashString).digest('hex').toUpperCase();

    console.log('Generated hash for order:', orderId);
    res.json({ hash });

  } catch (error) {
    console.error('Error generating hash:', error);
    res.status(500).json({ error: error.message });
  }
});

// Make this route 'async' so we can await database writes
app.post('/payhere/notify', notifyLimiter, async (req, res) => {
  try {
    const {
      merchant_id, order_id, payment_id, payhere_amount, payhere_currency, status_code, md5sig, custom_1,
    } = req.body;

    const merchantSecret = process.env.PAYHERE_MERCHANT_SECRET;
    const secretHash = crypto.createHash('md5').update(merchantSecret).digest('hex').toUpperCase();
    
    const localSig = crypto.createHash('md5')
      .update(merchant_id + order_id + payhere_amount + payhere_currency + status_code + secretHash)
      .digest('hex').toUpperCase();

    if (localSig !== md5sig) {
      console.error('CRITICAL: Invalid signature attempt for order:', order_id);
      return res.status(400).send('Invalid signature');
    }

    // Prepare the data to save to Firestore
    const paymentData = {
      orderId: order_id,
      paymentId: payment_id,
      amount: payhere_amount,
      currency: payhere_currency,
      statusCode: status_code,
      planName: custom_1, // This holds 'Pro' or 'Premium'
      timestamp: admin.firestore.FieldValue.serverTimestamp(), // Firebase handles the exact time
      verified: status_code === '2', 
    };

    // Save directly to a new 'payments' collection in Firestore!
    await db.collection('payments').doc(order_id).set(paymentData);

    if (status_code === '2') {
      console.log('Payment successful & saved to DB for order:', order_id);
      // TODO (Step 3): We will add logic here to update the user's specific account limits next!
    } else {
      console.log('Payment failed, but recorded. Status:', status_code);
    }

    res.send('OK');

  } catch (error) {
    console.error('Error processing notification:', error);
    res.status(500).send('Error');
  }
});

// Make this route 'async' so we can await database reads
app.get('/payhere/verify/:orderId', async (req, res) => {
  try {
    const { orderId } = req.params;
    
    // Look up the payment in Firestore
    const paymentDoc = await db.collection('payments').doc(orderId).get();

    if (!paymentDoc.exists) {
      return res.status(404).json({ verified: false, error: 'Payment not found' });
    }

    const payment = paymentDoc.data();

    res.json({
      verified: payment.verified,
      orderId: payment.orderId,
      paymentId: payment.paymentId,
      planName: payment.planName,
      // Convert Firebase timestamp to readable string
      timestamp: payment.timestamp ? payment.timestamp.toDate().toISOString() : null,
    });
  } catch (error) {
    console.error('Error verifying payment:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/payhere/payments', async (req, res) => {
  try {
    // Fetch all payments from Firestore
    const snapshot = await db.collection('payments').orderBy('timestamp', 'desc').get();
    const allPayments = snapshot.docs.map(doc => doc.data());
    
    res.json(allPayments);
  } catch (error) {
    console.error('Error fetching payments:', error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Fro-vy PayHere Secure Server running on port ${PORT}`);
  console.log(`Firebase connected successfully! 🔥`);
  console.log(`Sandbox mode: ${process.env.PAYHERE_SANDBOX === 'true' ? 'ENABLED' : 'DISABLED'}`);
});