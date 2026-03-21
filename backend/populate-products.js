require('dotenv').config();
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccount = require('./firebase-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Category mapping based on product type
function inferCategory(productName, brandName, ingredients) {
  const productLower = productName.toLowerCase();
  const ingredientsLower = ingredients.join(' ').toLowerCase();

  if (productLower.includes('milk') || productLower.includes('curd') ||
      productLower.includes('yogurt') || productLower.includes('cheese') ||
      productLower.includes('butter') || ingredientsLower.includes('milk')) {
    return 'dairy';
  }
  if (productLower.includes('biscuit') || productLower.includes('cookie') ||
      productLower.includes('cake') || productLower.includes('bread') ||
      productLower.includes('cream cracker') || productLower.includes('wafer')) {
    return 'bakery';
  }
  if (productLower.includes('juice') || productLower.includes('drink') ||
      productLower.includes('nectar') || productLower.includes('cordial') ||
      productLower.includes('tea') || productLower.includes('coffee')) {
    return 'beverages';
  }
  if (productLower.includes('chips') || productLower.includes('snack') ||
      productLower.includes('cracker') || productLower.includes('murukku') ||
      productLower.includes('mixture')) {
    return 'snacks';
  }
  if (productLower.includes('noodles') || productLower.includes('pasta') ||
      productLower.includes('rice') || productLower.includes('flour')) {
    return 'grains';
  }
  if (productLower.includes('sauce') || productLower.includes('ketchup') ||
      productLower.includes('mayo') || productLower.includes('chutney')) {
    return 'condiments';
  }
  if (productLower.includes('chocolate') || productLower.includes('candy') ||
      productLower.includes('sweet') || productLower.includes('toffee')) {
    return 'confectionery';
  }

  return 'other';
}

async function populateProducts() {
  try {
    // Read the products.json file
    const productsPath = path.join(__dirname, '..', 'lib', 'assets', 'database', 'products.json');

    if (!fs.existsSync(productsPath)) {
      console.error('Products file not found at:', productsPath);
      process.exit(1);
    }

    let data = fs.readFileSync(productsPath, 'utf8');

    // Fix common JSON issues (missing commas between objects)
    data = data.replace(/\}\s*\{/g, '},{');

    let products;
    try {
      products = JSON.parse(data);
    } catch (parseError) {
      console.error('Error parsing JSON:', parseError.message);
      console.log('Attempting to fix JSON...');

      // More aggressive fix
      data = data
        .replace(/,\s*\]/g, ']')  // Remove trailing commas
        .replace(/,\s*,/g, ',')   // Remove double commas
        .replace(/\}\s*\n\s*\{/g, '},\n{'); // Add missing commas

      try {
        products = JSON.parse(data);
      } catch (e) {
        console.error('Failed to parse JSON even after fixes. Please check the file manually.');
        process.exit(1);
      }
    }

    console.log(`Found ${products.length} products to upload...`);

    // Use batch writes for efficiency (max 500 per batch)
    const batches = [];
    let batch = db.batch();
    let operationCount = 0;
    let totalCount = 0;

    for (const product of products) {
      if (!product.productName || !product.brandName) {
        console.warn('Skipping invalid product:', product);
        continue;
      }

      const docRef = db.collection('products').doc();

      // Create searchable names (lowercase for case-insensitive search)
      const searchName = product.productName.toLowerCase();
      const searchBrand = product.brandName.toLowerCase();

      // Infer category
      const category = inferCategory(product.productName, product.brandName, product.ingredients || []);

      batch.set(docRef, {
        productName: product.productName,
        brandName: product.brandName,
        searchName: searchName,
        searchBrand: searchBrand,
        category: category,
        ingredients: product.ingredients || [],
        ingredientCount: (product.ingredients || []).length,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      operationCount++;
      totalCount++;

      // Firestore batches can only handle 500 operations
      if (operationCount === 500) {
        batches.push(batch);
        batch = db.batch();
        operationCount = 0;
      }
    }

    // Add the last batch if it has any operations
    if (operationCount > 0) {
      batches.push(batch);
    }

    // Commit all batches
    console.log(`Writing ${totalCount} products in ${batches.length} batch(es)...`);

    for (let i = 0; i < batches.length; i++) {
      await batches[i].commit();
      console.log(`Batch ${i + 1}/${batches.length} committed successfully`);
    }

    console.log('All products uploaded to Firestore successfully!');
    console.log(`Total: ${totalCount} products`);

    // Create indexes info
    console.log('\nNext steps:');
    console.log('1. In Firebase Console, create composite indexes for:');
    console.log('   Collection: products');
    console.log('   Index 1: searchName (Ascending), category (Ascending)');
    console.log('   Index 2: searchBrand (Ascending), category (Ascending)');
    console.log('   Index 3: category (Ascending), productName (Ascending)');
    console.log('2. This will enable efficient search queries');

  } catch (error) {
    console.error('Error populating products:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

// Run the script
populateProducts();
