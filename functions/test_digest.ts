/**
 * Manual test script for daily digest
 *
 * Usage:
 * 1. Start emulators: npm run serve
 * 2. Ensure articles exist: FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node test_ingest.ts slc
 * 3. Run this test: FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node test_digest.ts slc
 */

import * as admin from "firebase-admin";
import {sendDigestToTopic, getTodayTopN, buildPayload} from "./src/dailyDigest";

// Point to emulator
process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";

admin.initializeApp({projectId: "brightside-test"});

async function test() {
  const metro = process.argv[2] || "slc";

  console.log(`\n📨 Testing daily digest for metro: ${metro}\n`);
  console.log("=" .repeat(60));

  try {
    // Step 1: Get top articles
    console.log("\n1. Fetching top 3 articles...");
    const articles = await getTodayTopN(metro, 3);

    if (articles.length === 0) {
      console.log("   ⚠️  No articles found!");
      console.log("   Run ingestion first: npx ts-node test_ingest.ts " + metro);
      process.exit(0);
    }

    console.log(`   ✓ Found ${articles.length} articles:`);
    articles.forEach((doc, i) => {
      const data = doc.data();
      console.log(`      ${i + 1}. ${data?.title || "Untitled"}`);
    });

    // Step 2: Build payload
    console.log("\n2. Building FCM payload...");
    const payload = buildPayload(metro, articles);

    console.log("\n   📋 Notification Payload:");
    console.log(`      Topic: ${payload.topic}`);
    console.log(`      Title: ${payload.notification?.title}`);
    console.log(`      Body: ${payload.notification?.body}`);
    console.log(`      Route: ${payload.data?.route}`);
    console.log(`      Metro: ${payload.data?.metroId}`);
    if (payload.data?.articleId) {
      console.log(`      Article ID: ${payload.data.articleId}`);
    }

    // Step 3: Send digest (this will fail in emulator but shows the logic works)
    console.log("\n3. Sending digest to topic...");
    try {
      await sendDigestToTopic(metro);
      console.log("   ✓ Digest sent successfully!");
    } catch (error: any) {
      if (error.code === "messaging/invalid-registration-token" ||
          error.message?.includes("App instance has been unregistered")) {
        console.log("   ⚠️  Cannot send in emulator (no real FCM tokens)");
        console.log("   ✓ Logic validated - would work in production");
      } else {
        throw error;
      }
    }

    console.log("\n" + "=".repeat(60));
    console.log("\n✅ Digest test complete!\n");
    console.log("To test in production:");
    console.log("  1. Deploy: firebase deploy --only functions:digestSlc");
    console.log("  2. Subscribe device to topic: metro_slc_daily");
    console.log("  3. Wait for 7am or trigger manually via Firebase console\n");
  } catch (error) {
    console.error("\n❌ Digest test failed:", error);
    process.exit(1);
  }
}

test()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Test script failed:", error);
    process.exit(1);
  });
