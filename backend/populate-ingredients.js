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

async function populateIngredients() {
  try {
    // Read the ingredients.json file
    const ingredientsPath = path.join(__dirname, '..', 'IngredientDatabase', 'ingredients.json');
    const data = fs.readFileSync(ingredientsPath, 'utf8');
    const ingredients = JSON.parse(data);

    console.log(`Found ${ingredients.length} ingredients to upload...`);

    // Use batch writes for efficiency (max 500 per batch)
    const batches = [];
    let batch = db.batch();
    let operationCount = 0;
    let totalCount = 0;

    for (const ingredient of ingredients) {
      const docRef = db.collection('ingredients').doc();

      // Create searchable name (lowercase for case-insensitive search)
      const searchName = ingredient.name.toLowerCase();

      batch.set(docRef, {
        name: ingredient.name,
        searchName: searchName,
        category: ingredient.category,
        reason: ingredient.reason,
        lastUpdated: ingredient.lastUpdated,
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
    console.log(`Writing ${totalCount} ingredients in ${batches.length} batch(es)...`);

    for (let i = 0; i < batches.length; i++) {
      await batches[i].commit();
      console.log(`Batch ${i + 1}/${batches.length} committed successfully`);
    }

    console.log('✅ All ingredients uploaded to Firestore successfully!');
    console.log(`📊 Total: ${totalCount} ingredients`);

    // Create indexes info
    console.log('\n📝 Next steps:');
    console.log('1. In Firebase Console, create a composite index for:');
    console.log('   Collection: ingredients');
    console.log('   Fields: searchName (Ascending), category (Ascending)');
    console.log('2. This will enable efficient search queries');

  } catch (error) {
    console.error('Error populating ingredients:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

// Run the script
populateIngredients();
