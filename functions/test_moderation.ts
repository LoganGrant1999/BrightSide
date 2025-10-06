/**
 * Manual test script for submission moderation
 *
 * Usage:
 * 1. Start emulators: npm run serve
 * 2. Create test submission via Firestore UI or this script
 * 3. Set admin claim: node set_admin_claim.js <USER_UID>
 * 4. Run approve: FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node test_moderation.ts approve <SUBMISSION_ID>
 * 5. Or reject: FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node test_moderation.ts reject <SUBMISSION_ID>
 */

import * as admin from "firebase-admin";

// Point to emulator
process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";

admin.initializeApp({projectId: "brightside-test"});

const db = admin.firestore();

async function createTestSubmission(): Promise<string> {
  const submissionId = `test-submission-${Date.now()}`;

  const submission = {
    id: submissionId,
    submittedByUid: "test-user-123",
    title: "Community Garden Opens Downtown",
    desc: "Local volunteers have created a beautiful new community garden in the heart of downtown, bringing fresh produce and green space to the neighborhood. Families gathered for the grand opening celebration.",
    city: "Salt Lake City",
    state: "UT",
    when: admin.firestore.Timestamp.now(),
    photoUrl: "https://example.com/garden.jpg",
    status: "pending",
    createdAt: admin.firestore.Timestamp.now(),
  };

  await db.collection("submissions").doc(submissionId).set(submission);

  console.log(`✓ Created test submission: ${submissionId}`);
  return submissionId;
}

async function checkSubmission(submissionId: string) {
  const doc = await db.collection("submissions").doc(submissionId).get();

  if (!doc.exists) {
    console.log(`❌ Submission ${submissionId} not found`);
    return null;
  }

  const data = doc.data();
  console.log("\n📋 Submission Details:");
  console.log(`   ID: ${submissionId}`);
  console.log(`   Title: ${data?.title}`);
  console.log(`   Status: ${data?.status}`);
  console.log(`   City/State: ${data?.city}, ${data?.state}`);

  if (data?.status === "approved") {
    console.log(`   ✓ Approved by: ${data.moderatorId}`);
    console.log(`   ✓ Article ID: ${data.approvedArticleId}`);
  } else if (data?.status === "rejected") {
    console.log(`   ✗ Rejected by: ${data.moderatorId}`);
    console.log(`   ✗ Reason: ${data.moderatorNote}`);
  }

  return data;
}

async function checkArticle(articleId: string) {
  const doc = await db.collection("articles").doc(articleId).get();

  if (!doc.exists) {
    console.log(`❌ Article ${articleId} not found`);
    return;
  }

  const data = doc.data();
  console.log("\n📰 Article Created:");
  console.log(`   ID: ${articleId}`);
  console.log(`   Title: ${data?.title}`);
  console.log(`   Metro: ${data?.metroId}`);
  console.log(`   Status: ${data?.status}`);
  console.log(`   Published At: ${data?.publishedAt?.toDate().toISOString()}`);
  console.log(`   Source: ${data?.sourceName}`);
}

async function simulateApprove(submissionId: string, publishNow: boolean = true) {
  console.log(`\n🔄 Simulating approveSubmission...`);

  const submission = await checkSubmission(submissionId);
  if (!submission) return;

  if (submission.status !== "pending") {
    console.log(`❌ Cannot approve: status is ${submission.status}, expected pending`);
    return;
  }

  // Simulate function logic
  const articleId = `article-${Date.now()}`;
  const publishTime = publishNow ?
    admin.firestore.Timestamp.now() :
    admin.firestore.Timestamp.fromDate(new Date(Date.now() + 86400000)); // +1 day

  const articleData = {
    metroId: "slc", // Inferred from UT
    title: submission.title,
    snippet: submission.desc.substring(0, 300),
    body: "",
    imageUrl: submission.photoUrl || null,
    sourceName: "Community Submission",
    sourceUrl: "",
    status: "published",
    likeCount: 0,
    featured: false,
    publishedAt: publishTime,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await db.collection("articles").doc(articleId).set(articleData);

  await db.collection("submissions").doc(submissionId).update({
    status: "approved",
    approvedArticleId: articleId,
    moderatorId: "test-admin",
    moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`\n✅ Approval complete!`);
  await checkSubmission(submissionId);
  await checkArticle(articleId);
}

async function simulateReject(submissionId: string, reason: string = "Test rejection") {
  console.log(`\n🔄 Simulating rejectSubmission...`);

  const submission = await checkSubmission(submissionId);
  if (!submission) return;

  if (submission.status !== "pending") {
    console.log(`❌ Cannot reject: status is ${submission.status}, expected pending`);
    return;
  }

  await db.collection("submissions").doc(submissionId).update({
    status: "rejected",
    moderatorId: "test-admin",
    moderatorNote: reason,
    moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`\n✅ Rejection complete!`);
  await checkSubmission(submissionId);
}

async function main() {
  const action = process.argv[2];
  let submissionId = process.argv[3];

  console.log("🧪 Moderation Test Script\n");
  console.log("=" .repeat(60));

  try {
    if (!submissionId && action !== "create") {
      console.log("Creating test submission...");
      submissionId = await createTestSubmission();
      console.log("\nUse this ID for testing:");
      console.log(`  Approve: npx ts-node test_moderation.ts approve ${submissionId}`);
      console.log(`  Reject:  npx ts-node test_moderation.ts reject ${submissionId}\n`);
      process.exit(0);
    }

    switch (action) {
    case "create":
      submissionId = await createTestSubmission();
      console.log(`\nSubmission ID: ${submissionId}`);
      break;

    case "approve":
      if (!submissionId) {
        console.log("Usage: npx ts-node test_moderation.ts approve <SUBMISSION_ID>");
        process.exit(1);
      }
      await simulateApprove(submissionId, true);
      break;

    case "reject":
      if (!submissionId) {
        console.log("Usage: npx ts-node test_moderation.ts reject <SUBMISSION_ID>");
        process.exit(1);
      }
      await simulateReject(submissionId, "Not appropriate for BrightSide");
      break;

    case "check":
      if (!submissionId) {
        console.log("Usage: npx ts-node test_moderation.ts check <SUBMISSION_ID>");
        process.exit(1);
      }
      const data = await checkSubmission(submissionId);
      if (data?.approvedArticleId) {
        await checkArticle(data.approvedArticleId);
      }
      break;

    default:
      console.log("Usage:");
      console.log("  create:  npx ts-node test_moderation.ts create");
      console.log("  approve: npx ts-node test_moderation.ts approve <SUBMISSION_ID>");
      console.log("  reject:  npx ts-node test_moderation.ts reject <SUBMISSION_ID>");
      console.log("  check:   npx ts-node test_moderation.ts check <SUBMISSION_ID>");
      process.exit(1);
    }

    console.log("\n" + "=".repeat(60));
    console.log("✅ Test complete!");
    console.log("\nCheck Firestore emulator UI: http://localhost:4000\n");
  } catch (error) {
    console.error("\n❌ Test failed:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Script error:", error);
    process.exit(1);
  });
