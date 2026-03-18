require('dotenv').config();
const express = require('express');
const cors = require('cors');
const crypto = require('crypto');

const app = express();

// CORS configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type'],
}));

// Parse JSON bodies (except for webhooks)
app.use((req, res, next) => {
  if (req.originalUrl === '/payhere/notify') {
    express.urlencoded({ extended: true })(req, res, next);
  } else {
    express.json()(req, res, next);
  }
});

// In-memory storage for payments (use a database in production)
const payments = new Map();

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Generate PayHere hash for secure payment
// Hash formula: MD5(merchant_id + order_id + amount + currency + MD5(merchant_secret).toUpperCase())
app.post('/payhere/generate-hash', (req, res) => {
  try {
    const { orderId, amount, currency } = req.body;

    if (!orderId || !amount || !currency) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const merchantId = process.env.PAYHERE_MERCHANT_ID;
    const merchantSecret = process.env.PAYHERE_MERCHANT_SECRET;

    if (!merchantId || !merchantSecret) {
      return res.status(500).json({ error: 'PayHere credentials not configured' });
    }

    // Generate hash according to PayHere specification
    const secretHash = crypto
      .createHash('md5')
      .update(merchantSecret)
      .digest('hex')
      .toUpperCase();

    const hashString = merchantId + orderId + amount + currency + secretHash;

    const hash = crypto
      .createHash('md5')
      .update(hashString)
      .digest('hex')
      .toUpperCase();

    console.log('Generated hash for order:', orderId);

    res.json({ hash });

  } catch (error) {
    console.error('Error generating hash:', error);
    res.status(500).json({ error: error.message });
  }
});

// PayHere payment notification endpoint (IPN - Instant Payment Notification)
app.post('/payhere/notify', (req, res) => {
  try {
    const {
      merchant_id,
      order_id,
      payment_id,
      payhere_amount,
      payhere_currency,
      status_code,
      md5sig,
      custom_1,
      custom_2,
    } = req.body;

    console.log('PayHere notification received:', {
      order_id,
      payment_id,
      status_code,
      amount: payhere_amount,
    });

    // Verify the MD5 signature
    const merchantSecret = process.env.PAYHERE_MERCHANT_SECRET;
    const secretHash = crypto
      .createHash('md5')
      .update(merchantSecret)
      .digest('hex')
      .toUpperCase();

    const localSig = crypto
      .createHash('md5')
      .update(
        merchant_id +
        order_id +
        payhere_amount +
        payhere_currency +
        status_code +
        secretHash
      )
      .digest('hex')
      .toUpperCase();

    if (localSig !== md5sig) {
      console.error('Invalid signature for order:', order_id);
      return res.status(400).send('Invalid signature');
    }

    // Store payment status
    payments.set(order_id, {
      orderId: order_id,
      paymentId: payment_id,
      amount: payhere_amount,
      currency: payhere_currency,
      statusCode: status_code,
      planName: custom_1,
      timestamp: new Date().toISOString(),
      verified: status_code === '2', // 2 = success
    });

    // Status codes:
    // 2 = success
    // 0 = pending
    // -1 = canceled
    // -2 = failed
    // -3 = chargedback

    if (status_code === '2') {
      console.log('Payment successful for order:', order_id);
      // Here you would typically:
      // 1. Update your database
      // 2. Activate the user's subscription
      // 3. Send confirmation email
    } else {
      console.log('Payment not successful. Status:', status_code);
    }

    res.send('OK');

  } catch (error) {
    console.error('Error processing notification:', error);
    res.status(500).send('Error');
  }
});

// Verify payment status
app.get('/payhere/verify/:orderId', (req, res) => {
  const { orderId } = req.params;
  const payment = payments.get(orderId);

  if (!payment) {
    return res.json({ verified: false, error: 'Payment not found' });
  }

  res.json({
    verified: payment.verified,
    orderId: payment.orderId,
    paymentId: payment.paymentId,
    planName: payment.planName,
    timestamp: payment.timestamp,
  });
});

// Get all payments (for admin/debugging)
app.get('/payhere/payments', (req, res) => {
  const allPayments = Array.from(payments.values());
  res.json(allPayments);
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Fro-vy PayHere server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Sandbox mode: ${process.env.PAYHERE_SANDBOX === 'true' ? 'ENABLED' : 'DISABLED'}`);
});
