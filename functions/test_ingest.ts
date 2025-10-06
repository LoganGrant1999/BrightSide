/**
 * Manual test script for ingestion pipeline
 *
 * Usage:
 * 1. Start emulators: npm run serve
 * 2. Seed sources: FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/seed_sources.ts
 * 3. Update at least one source to have active: true and a real RSS URL
 * 4. Run this test: FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node test_ingest.ts
 */

import * as admin from "firebase-admin";
import {runIngest} from "./src/ingest";

// Point to emulator
process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";

admin.initializeApp({projectId: "brightside-test"});

async function test() {
  const metro = process.argv[2] || "slc";

  console.log(`\n🚀 Testing ingestion for metro: ${metro}\n`);
  console.log("=" .repeat(60));

  try {
    await runIngest(metro);

    console.log("\n" + "=".repeat(60));
    console.log("✅ Ingestion completed successfully!");

    // Query articles to verify
    const snapshot = await admin
      .firestore()
      .collection("articles")
      .where("metroId", "==", metro)
      .orderBy("publishedAt", "desc")
      .limit(10)
      .get();

    console.log(`\n📰 Articles in Firestore (showing up to 10):\n`);

    if (snapshot.empty) {
      console.log("  No articles found. Check that:");
      console.log("  1. Sources are seeded and active");
      console.log("  2. RSS URLs are valid");
      console.log("  3. RSS items pass positivity filter");
    } else {
      snapshot.docs.forEach((doc, index) => {
        const data = doc.data();
        console.log(`  ${index + 1}. ${data.title}`);
        console.log(`     Source: ${data.sourceName}`);
        console.log(`     URL: ${data.sourceUrl}`);
        console.log(`     Published: ${data.publishedAt.toDate().toISOString()}`);
        console.log(`     Body (should be empty): "${data.body}"`);
        console.log("");
      });
    }

    console.log("\n🎉 Test complete! Check emulator UI at http://localhost:4000\n");
  } catch (error) {
    console.error("\n❌ Ingestion failed:", error);
    process.exit(1);
  }
}

test()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Test script failed:", error);
    process.exit(1);
  });
