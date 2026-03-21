require('dotenv').config();
const express  = require('express');
const cors     = require('cors');
const crypto   = require('crypto');
const helmet   = require('helmet');
const rateLimit = require('express-rate-limit');
const multer   = require('multer');
const vision   = require('@google-cloud/vision');

// ─── 1. FIREBASE SETUP ───────────────────────────────────────────────────────
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-key.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

// ─── 2. ENVIRONMENT VALIDATION ───────────────────────────────────────────────
const requiredEnvVars = ['PAYHERE_MERCHANT_ID', 'PAYHERE_MERCHANT_SECRET'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.error(`CRITICAL ERROR: Missing ${envVar} in .env file.`);
    process.exit(1);
  }
}

const MERCHANT_ID     = process.env.PAYHERE_MERCHANT_ID;
const MERCHANT_SECRET = process.env.PAYHERE_MERCHANT_SECRET;

// ─── 3. MIDDLEWARE ────────────────────────────────────────────────────────────
const app    = express();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } });

app.use(helmet());
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? process.env.ALLOWED_ORIGIN : '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

const apiLimiter    = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 });
const notifyLimiter = rateLimit({ windowMs: 1  * 60 * 1000, max: 10  });

app.use('/payhere/', apiLimiter);

app.use((req, res, next) => {
  if (req.originalUrl === '/payhere/notify') {
    express.urlencoded({ extended: true })(req, res, next);
  } else {
    express.json()(req, res, next);
  }
});

// ─── 4. HEALTH CHECK ─────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ─── 5. INGREDIENT ANALYSIS HELPERS ──────────────────────────────────────────

// Load ingredient database from Firestore (cached after first load)
let _ingredientCache = null;
async function getIngredientDb() {
  if (_ingredientCache) return _ingredientCache;
  const snap = await db.collection('ingredients').get();
  _ingredientCache = {};
  snap.docs.forEach(doc => {
    const d = doc.data();
    if (d.name) _ingredientCache[d.name.toLowerCase().trim()] = d;
  });
  return _ingredientCache;
}

// Classify a list of ingredient strings against the DB
async function classifyIngredients(ingredientList) {
  const db_map = await getIngredientDb();
  const beneficial = [], caution = [], avoid = [], unknown = [];

  for (const raw of ingredientList) {
    const key = raw.trim().toLowerCase();
    if (!key) continue;

    let found = db_map[key];
    if (!found) {
      // Partial match fallback
      for (const dbKey of Object.keys(db_map)) {
        if (key.includes(dbKey) || dbKey.includes(key)) {
          found = db_map[dbKey];
          break;
        }
      }
    }

    if (found) {
      switch ((found.category || '').toLowerCase()) {
        case 'beneficial': beneficial.push(found); break;
        case 'caution':    caution.push(found);    break;
        case 'avoid':      avoid.push(found);      break;
        default:           unknown.push(raw.trim());
      }
    } else {
      unknown.push(raw.trim());
    }
  }

  const total = beneficial.length + caution.length + avoid.length + unknown.length;
  const safetyLevel = avoid.length > 0 ? 'Avoid' : caution.length > 0 ? 'Caution' : 'Safe';

  return { beneficial, caution, avoid, unknown, total, safetyLevel };
}

// Get user allergies and conditions from Firestore
async function getUserHealthProfile(userId) {
  if (!userId) return null;
  try {
    const doc = await db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    const data = doc.data();
    return {
      allergies:   data.healthProfile?.allergies  || [],
      conditions:  data.healthProfile?.conditions || [],
    };
  } catch (e) {
    return null;
  }
}

// Build personalised warnings based on user's health profile
function buildPersonalWarnings(result, userProfile) {
  if (!userProfile) return [];
  const warnings = [];
  const { allergies, conditions } = userProfile;

  const allFlagged = [...result.avoid, ...result.caution];

  for (const ing of allFlagged) {
    const ingName = ing.name.toLowerCase();

    // Check allergies
    for (const allergy of allergies) {
      if (ingName.includes(allergy.toLowerCase()) ||
          allergy.toLowerCase().includes(ingName)) {
        warnings.push({
          type: 'allergy',
          ingredient: ing.name,
          severity: result.avoid.includes(ing) ? 'high' : 'medium',
          message: `Contains ${ing.name} — you have a listed allergy to this.`,
        });
      }
    }

    // Check common medical condition interactions
    const condLower = conditions.map(c => c.toLowerCase());
    if (condLower.some(c => c.includes('diabet')) &&
        ['sugar', 'fructose', 'glucose', 'corn syrup'].some(s => ingName.includes(s))) {
      warnings.push({
        type: 'condition',
        ingredient: ing.name,
        severity: 'medium',
        message: `${ing.name} may affect blood sugar — relevant to your diabetes profile.`,
      });
    }
    if (condLower.some(c => c.includes('hypertension') || c.includes('blood pressure')) &&
        ['sodium', 'salt', 'msg'].some(s => ingName.includes(s))) {
      warnings.push({
        type: 'condition',
        ingredient: ing.name,
        severity: 'medium',
        message: `${ing.name} is high in sodium — relevant to your hypertension profile.`,
      });
    }
  }

  return warnings;
}

// ─── 6. TEXT ANALYSIS ────────────────────────────────────────────────────────
app.post('/analyze-text', async (req, res) => {
  try {
    const { text, userId } = req.body;
    if (!text || text.trim().length === 0) {
      return res.status(400).json({ error: 'text is required' });
    }

    // Parse comma/newline/semicolon separated ingredient list
    const ingredientList = text
      .split(/[,;\n]+/)
      .map(s => s.trim())
      .filter(s => s.length > 0);

    const result      = await classifyIngredients(ingredientList);
    const userProfile = await getUserHealthProfile(userId);
    const warnings    = buildPersonalWarnings(result, userProfile);

    res.json({
      status:              'Success',
      extractedText:       text,
      safetyLevel:         result.safetyLevel,
      analysis:            `Found ${result.total} ingredients: ${result.beneficial.length} beneficial, ${result.caution.length} caution, ${result.avoid.length} to avoid.`,
      beneficial:          result.beneficial.map(i => ({ name: i.name, reason: i.reason })),
      cautionIngredients:  result.caution.map(i => ({ name: i.name, reason: i.reason })),
      harmfulIngredients:  result.avoid.map(i => i.name),
      unknownIngredients:  result.unknown,
      personalWarnings:    warnings,
      isPersonalized:      !!userProfile,
      ingredientCount:     result.total,
    });
  } catch (error) {
    console.error('analyze-text error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ─── 7. IMAGE ANALYSIS (OCR via Google Vision) ───────────────────────────────
app.post('/analyze-image', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image uploaded' });
    }

    const { userId } = req.body;

    // Extract text from the image using Google Cloud Vision
    const visionClient = new vision.ImageAnnotatorClient();
    const [visionResult] = await visionClient.textDetection({
      image: { content: req.file.buffer.toString('base64') },
    });

    const detections  = visionResult.textAnnotations;
    const extractedText = detections.length > 0 ? detections[0].description : '';

    if (!extractedText.trim()) {
      return res.json({
        status:        'Success',
        extractedText: '',
        safetyLevel:   'Unknown',
        analysis:      'No text could be detected in the image. Please try a clearer photo.',
        beneficial:    [],
        cautionIngredients: [],
        harmfulIngredients: [],
        unknownIngredients: [],
        personalWarnings:   [],
        isPersonalized:     false,
        ingredientCount:    0,
      });
    }

    // Parse the extracted text into ingredient list
    const ingredientList = extractedText
      .split(/[,;\n]+/)
      .map(s => s.trim())
      .filter(s => s.length > 1);

    const result      = await classifyIngredients(ingredientList);
    const userProfile = await getUserHealthProfile(userId);
    const warnings    = buildPersonalWarnings(result, userProfile);

    res.json({
      status:              'Success',
      extractedText,
      safetyLevel:         result.safetyLevel,
      analysis:            `Found ${result.total} ingredients: ${result.beneficial.length} beneficial, ${result.caution.length} caution, ${result.avoid.length} to avoid.`,
      beneficial:          result.beneficial.map(i => ({ name: i.name, reason: i.reason })),
      cautionIngredients:  result.caution.map(i => ({ name: i.name, reason: i.reason })),
      harmfulIngredients:  result.avoid.map(i => i.name),
      unknownIngredients:  result.unknown,
      personalWarnings:    warnings,
      isPersonalized:      !!userProfile,
      ingredientCount:     result.total,
    });
  } catch (error) {
    console.error('analyze-image error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ─── 8. USER PROFILE ─────────────────────────────────────────────────────────
app.get('/user/:userId/profile', async (req, res) => {
  try {
    const { userId } = req.params;
    const doc = await db.collection('users').doc(userId).get();
    if (!doc.exists) return res.status(404).json({ error: 'User not found' });
    const data = doc.data();
    res.json({
      userId,
      name:             data.profile?.userName     || '',
      email:            data.profile?.email        || '',
      gender:           data.profile?.gender       || '',
      allergies:        data.healthProfile?.allergies   || [],
      conditions:       data.healthProfile?.conditions  || [],
      concerns:         data.healthProfile?.concerns    || [],
      skinType:         data.healthProfile?.skinType    || '',
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/user/:userId/profile', async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, email, gender, allergies, conditions, concerns, skinType } = req.body;

    const updates = {};
    if (name    !== undefined) updates['profile.userName']               = name;
    if (email   !== undefined) updates['profile.email']                  = email;
    if (gender  !== undefined) updates['profile.gender']                 = gender;
    if (allergies   !== undefined) updates['healthProfile.allergies']    = allergies;
    if (conditions  !== undefined) updates['healthProfile.conditions']   = conditions;
    if (concerns    !== undefined) updates['healthProfile.concerns']     = concerns;
    if (skinType    !== undefined) updates['healthProfile.skinType']     = skinType;

    await db.collection('users').doc(userId).update(updates);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/user/:userId/subscription', async (req, res) => {
  try {
    const { userId } = req.params;
    const doc = await db.collection('users').doc(userId).get();
    if (!doc.exists) return res.status(404).json({ error: 'User not found' });
    const plan = doc.data().subscription?.plan || 'Free';
    res.json({ userId, plan, active: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ─── 9. SCAN HISTORY ─────────────────────────────────────────────────────────
app.post('/user/:userId/history', async (req, res) => {
  try {
    const { userId } = req.params;
    const scanData = { ...req.body, scannedAt: admin.firestore.FieldValue.serverTimestamp() };
    const ref = await db.collection('users').doc(userId).collection('scanHistory').add(scanData);
    res.json({ success: true, scanId: ref.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/user/:userId/history', async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    const snap = await db.collection('users').doc(userId)
      .collection('scanHistory')
      .orderBy('scannedAt', 'desc')
      .limit(limit)
      .get();
    const scans = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json({ success: true, scans, count: scans.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/user/:userId/history/:scanId', async (req, res) => {
  try {
    const { userId, scanId } = req.params;
    await db.collection('users').doc(userId).collection('scanHistory').doc(scanId).delete();
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/user/:userId/history', async (req, res) => {
  try {
    const { userId } = req.params;
    const snap = await db.collection('users').doc(userId).collection('scanHistory').get();
    const batch = db.batch();
    snap.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    res.json({ success: true, deleted: snap.size });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ─── 10. PRODUCTS ─────────────────────────────────────────────────────────────
app.get('/products/search', async (req, res) => {
  try {
    const { query, category, limit = '20' } = req.query;
    if (!query) return res.status(400).json({ error: 'query is required' });

    const snap = await db.collection('products').get();
    const lq   = query.toLowerCase().trim();

    let results = snap.docs
      .map(doc => ({ id: doc.id, ...doc.data() }))
      .filter(p => {
        const nameMatch  = (p.productName || '').toLowerCase().includes(lq);
        const brandMatch = (p.brandName   || '').toLowerCase().includes(lq);
        const catMatch   = !category || category === 'all' || p.category === category;
        return (nameMatch || brandMatch) && catMatch;
      })
      .slice(0, parseInt(limit));

    res.json({ success: true, results, count: results.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/products/all', async (req, res) => {
  try {
    const { category, limit = '50' } = req.query;
    let query = db.collection('products');
    if (category && category !== 'all') query = query.where('category', '==', category);
    const snap    = await query.limit(parseInt(limit)).get();
    const results = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json({ success: true, results, count: results.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/products/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    const { userId }    = req.query;

    const doc = await db.collection('products').doc(productId).get();
    if (!doc.exists) return res.status(404).json({ error: 'Product not found' });

    const product     = { id: doc.id, ...doc.data() };
    const ingredients = product.ingredients || [];
    const result      = await classifyIngredients(ingredients);
    const userProfile = await getUserHealthProfile(userId);
    const warnings    = buildPersonalWarnings(result, userProfile);

    res.json({
      ...product,
      analysis: {
        safetyLevel:   result.safetyLevel,
        beneficial:    result.beneficial.map(i => ({ name: i.name, reason: i.reason })),
        caution:       result.caution.map(i => ({ name: i.name, reason: i.reason })),
        avoid:         result.avoid.map(i => ({ name: i.name, reason: i.reason })),
        unknown:       result.unknown,
        personalWarnings: warnings,
        isPersonalized:   !!userProfile,
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ─── 11. INGREDIENTS ──────────────────────────────────────────────────────────
app.get('/ingredients/search', async (req, res) => {
  try {
    const { query, category, limit = '20' } = req.query;
    if (!query) return res.status(400).json({ error: 'query is required' });

    const snap = await db.collection('ingredients').get();
    const lq   = query.toLowerCase().trim();

    let results = snap.docs
      .map(doc => ({ id: doc.id, ...doc.data() }))
      .filter(i => {
        const nameMatch = (i.name || '').toLowerCase().includes(lq);
        const catMatch  = !category || category === 'all' || i.category === category;
        return nameMatch && catMatch;
      })
      .slice(0, parseInt(limit));

    res.json({ success: true, results, count: results.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/ingredients/all', async (req, res) => {
  try {
    const { category, limit = '50' } = req.query;
    let query = db.collection('ingredients');
    if (category && category !== 'all') query = query.where('category', '==', category);
    const snap    = await query.limit(parseInt(limit)).get();
    const results = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json({ success: true, results, count: results.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ─── 12. PAYHERE PAYMENT ROUTES ───────────────────────────────────────────────
app.post('/payhere/generate-hash', (req, res) => {
  try {
    const { orderId, amount, currency } = req.body;
    if (!orderId || !amount || !currency) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    const secretHash = crypto.createHash('md5').update(MERCHANT_SECRET).digest('hex').toUpperCase();
    const hashString = MERCHANT_ID + orderId + amount + currency + secretHash;
    const hash       = crypto.createHash('md5').update(hashString).digest('hex').toUpperCase();
    res.json({ hash });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/payhere/notify', notifyLimiter, async (req, res) => {
  try {
    const { merchant_id, order_id, payment_id, payhere_amount, payhere_currency, status_code, md5sig, custom_1 } = req.body;

    const secretHash = crypto.createHash('md5').update(MERCHANT_SECRET).digest('hex').toUpperCase();
    const localSig   = crypto.createHash('md5')
      .update(merchant_id + order_id + payhere_amount + payhere_currency + status_code + secretHash)
      .digest('hex').toUpperCase();

    if (localSig !== md5sig) {
      return res.status(400).send('Invalid signature');
    }

    await db.collection('payments').doc(order_id).set({
      orderId: order_id, paymentId: payment_id,
      amount: payhere_amount, currency: payhere_currency,
      statusCode: status_code, planName: custom_1,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      verified: status_code === '2',
    });

    res.send('OK');
  } catch (error) {
    res.status(500).send('Error');
  }
});

app.get('/payhere/verify/:orderId', async (req, res) => {
  try {
    const doc = await db.collection('payments').doc(req.params.orderId).get();
    if (!doc.exists) return res.status(404).json({ verified: false, error: 'Payment not found' });
    const p = doc.data();
    res.json({
      verified: p.verified, orderId: p.orderId, paymentId: p.paymentId,
      planName: p.planName,
      timestamp: p.timestamp ? p.timestamp.toDate().toISOString() : null,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ─── 13. START ────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n🚀 Fro-vy Backend running on port ${PORT}`);
  console.log(`📊 Endpoints ready:`);
  console.log(`   POST /analyze-text`);
  console.log(`   POST /analyze-image`);
  console.log(`   GET/PUT /user/:id/profile`);
  console.log(`   GET /user/:id/subscription`);
  console.log(`   GET/POST/DELETE /user/:id/history`);
  console.log(`   GET /products/search  /products/all  /products/:id`);
  console.log(`   GET /ingredients/search  /ingredients/all`);
  console.log(`   POST /payhere/generate-hash`);
  console.log(`   POST /payhere/notify`);
  console.log(`   GET  /payhere/verify/:orderId`);
  console.log(`\n🔒 Sandbox mode: ${process.env.PAYHERE_SANDBOX === 'true' ? 'ENABLED' : 'DISABLED'}`);
});
