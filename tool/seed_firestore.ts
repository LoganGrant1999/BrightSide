#!/usr/bin/env ts-node

/**
 * Seed script for BrightSide Firestore database
 *
 * Usage:
 *   For production: ts-node tool/seed_firestore.ts
 *   For emulator: FIRESTORE_EMULATOR_HOST="localhost:8080" ts-node tool/seed_firestore.ts
 *
 * Requires serviceAccountKey.json in the tool/ directory (get from Firebase Console)
 */

import admin from "firebase-admin";
import { readFileSync, existsSync } from "fs";
import { resolve } from "path";

// Initialize Firebase Admin
const serviceAccountPath = resolve(__dirname, "serviceAccountKey.json");

if (!existsSync(serviceAccountPath)) {
  console.error("❌ Error: serviceAccountKey.json not found!");
  console.error("Download it from: https://console.firebase.google.com/project/brightside-9a2c5/settings/serviceaccounts/adminsdk");
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "brightside-9a2c5",
});
const db = admin.firestore();

async function seedMetros() {
  console.log("Seeding metros...");

  const metros = [
    {
      id: "slc",
      name: "Salt Lake City",
      tz: "America/Denver",
      lat: 40.7608,
      lng: -111.8910,
      active: true,
    },
    {
      id: "nyc",
      name: "New York City",
      tz: "America/New_York",
      lat: 40.7128,
      lng: -74.0060,
      active: true,
    },
    {
      id: "gsp",
      name: "Greenville-Spartanburg",
      tz: "America/New_York",
      lat: 34.8526,
      lng: -82.3940,
      active: true,
    },
  ];

  for (const metro of metros) {
    await db.collection("metros").doc(metro.id).set(metro);
    console.log(`  ✓ Created metro: ${metro.name}`);
  }
}

async function seedSystemConfig() {
  console.log("Seeding system config...");

  const config = {
    today_max_articles: 5,
    daily_refresh_hour_local: 5,
    submission_enabled: true,
    reporting_enabled: true,
    popular_lookback_hours: 24,
  };

  await db.collection("system").doc("config").set(config);
  console.log("  ✓ Created system config");
}

async function seedArticles() {
  console.log("Seeding sample articles...");

  const now = admin.firestore.Timestamp.now();
  const yesterday = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 24 * 60 * 60 * 1000)
  );

  const articles = [
    // SLC articles
    {
      title: "Local Coffee Shop Donates 1000 Meals to Homeless Shelter",
      summary: "A beloved downtown coffee shop partnered with a local shelter to provide warm meals throughout the winter season.",
      source_name: "Salt Lake Tribune",
      source_url: "https://example.com/article1",
      image_url: "https://picsum.photos/seed/slc1/800/600",
      metro_id: "slc",
      status: "published",
      publish_time: now,
      is_featured: false,
      featured_start: null,
      featured_end: null,
      like_count_total: 42,
      like_count_24h: 12,
      hot_score: 0,
      created_at: now,
      updated_at: now,
    },
    {
      title: "High School Students Launch Community Garden Project",
      summary: "Students at East High School transformed an empty lot into a thriving community garden, growing fresh produce for neighbors.",
      source_name: "Deseret News",
      source_url: "https://example.com/article2",
      image_url: "https://picsum.photos/seed/slc2/800/600",
      metro_id: "slc",
      status: "published",
      publish_time: yesterday,
      is_featured: false,
      featured_start: null,
      featured_end: null,
      like_count_total: 28,
      like_count_24h: 8,
      hot_score: 0,
      created_at: yesterday,
      updated_at: yesterday,
    },

    // NYC articles
    {
      title: "Brooklyn Artist Creates Free Murals for Small Businesses",
      summary: "A talented street artist is beautifying neighborhood storefronts at no cost, bringing joy to local communities.",
      source_name: "NY Times",
      source_url: "https://example.com/article3",
      image_url: "https://picsum.photos/seed/nyc1/800/600",
      metro_id: "nyc",
      status: "published",
      publish_time: now,
      is_featured: false,
      featured_start: null,
      featured_end: null,
      like_count_total: 156,
      like_count_24h: 45,
      hot_score: 0,
      created_at: now,
      updated_at: now,
    },
    {
      title: "Manhattan Library Launches Free Tech Training for Seniors",
      summary: "The public library is offering weekly classes to help older adults navigate smartphones and video calls with loved ones.",
      source_name: "Gothamist",
      source_url: "https://example.com/article4",
      image_url: "https://picsum.photos/seed/nyc2/800/600",
      metro_id: "nyc",
      status: "published",
      publish_time: yesterday,
      is_featured: false,
      featured_start: null,
      featured_end: null,
      like_count_total: 89,
      like_count_24h: 23,
      hot_score: 0,
      created_at: yesterday,
      updated_at: yesterday,
    },

    // GSP articles
    {
      title: "Greenville Neighbors Rally to Build Wheelchair Ramp for Veteran",
      summary: "Community members volunteered their time and materials to construct an accessible ramp for a disabled veteran.",
      source_name: "Greenville News",
      source_url: "https://example.com/article5",
      image_url: "https://picsum.photos/seed/gsp1/800/600",
      metro_id: "gsp",
      status: "published",
      publish_time: now,
      is_featured: false,
      featured_start: null,
      featured_end: null,
      like_count_total: 67,
      like_count_24h: 19,
      hot_score: 0,
      created_at: now,
      updated_at: now,
    },
    {
      title: "Spartanburg Youth Group Cleans Up Local Parks",
      summary: "Dozens of teenagers spent their Saturday removing litter and planting trees in city parks, inspiring others to join.",
      source_name: "Herald Journal",
      source_url: "https://example.com/article6",
      image_url: "https://picsum.photos/seed/gsp2/800/600",
      metro_id: "gsp",
      status: "published",
      publish_time: yesterday,
      is_featured: false,
      featured_start: null,
      featured_end: null,
      like_count_total: 34,
      like_count_24h: 11,
      hot_score: 0,
      created_at: yesterday,
      updated_at: yesterday,
    },
  ];

  for (const article of articles) {
    await db.collection("articles").add(article);
    console.log(`  ✓ Created article: ${article.title.substring(0, 50)}...`);
  }
}

async function main() {
  console.log("🌱 Starting BrightSide database seed...\n");

  try {
    await seedMetros();
    console.log();
    await seedSystemConfig();
    console.log();
    await seedArticles();
    console.log();
    console.log("✅ Seed completed successfully!");
  } catch (error) {
    console.error("❌ Seed failed:", error);
    process.exit(1);
  }

  process.exit(0);
}

main();
