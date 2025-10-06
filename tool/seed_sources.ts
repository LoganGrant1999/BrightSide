/**
 * Seed RSS sources from rss_sources.yaml to Firestore
 *
 * Reads YAML config and upserts to /system/sources/{metro}/sources/*
 *
 * Usage:
 *   FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/seed_sources.ts  # Dev
 *   npx ts-node tool/seed_sources.ts                                            # Prod
 */

import admin from 'firebase-admin';
import * as fs from 'fs';
import * as yaml from 'js-yaml';
import * as path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'brightside-9a2c5'
});

const db = admin.firestore();

interface RSSSource {
  name: string;
  url: string;
  category: 'primary' | 'secondary' | 'supplemental';
  enabled: boolean;
}

interface MetroConfig {
  name: string;
  timezone: string;
  sources: RSSSource[];
}

interface RSSConfig {
  metros: {
    [metroId: string]: MetroConfig;
  };
}

async function seedSources() {
  console.log('📡 Seeding RSS sources from YAML...');
  console.log('');

  // Read YAML config
  const yamlPath = path.join(__dirname, 'rss_sources.yaml');

  if (!fs.existsSync(yamlPath)) {
    console.error('❌ rss_sources.yaml not found at:', yamlPath);
    process.exit(1);
  }

  const yamlContent = fs.readFileSync(yamlPath, 'utf8');
  const config = yaml.load(yamlContent) as RSSConfig;

  if (!config.metros) {
    console.error('❌ Invalid YAML: missing "metros" key');
    process.exit(1);
  }

  const metroIds = Object.keys(config.metros);
  console.log(`Found ${metroIds.length} metros: ${metroIds.join(', ')}`);
  console.log('');

  let totalSeeded = 0;

  // Process each metro
  for (const metroId of metroIds) {
    const metroConfig = config.metros[metroId];
    console.log(`📍 ${metroConfig.name} (${metroId})`);
    console.log(`   Timezone: ${metroConfig.timezone}`);
    console.log(`   Sources: ${metroConfig.sources.length} configured`);

    // Filter enabled sources
    const enabledSources = metroConfig.sources.filter(s => s.enabled);
    console.log(`   Enabled: ${enabledSources.length}`);
    console.log('');

    if (enabledSources.length === 0) {
      console.log('   ⚠️  No enabled sources, skipping');
      console.log('');
      continue;
    }

    // Build sources object for Firestore
    // Format: { source_id: { rss_url, source_name, weight, active } }
    const sourcesObject: Record<string, any> = {};

    for (const source of enabledSources) {
      // Generate doc ID from source name (slug)
      const docId = source.name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-|-$/g, '');

      // Weight based on category (primary=1.0, secondary=0.7, supplemental=0.5)
      const weight = source.category === 'primary' ? 1.0
                   : source.category === 'secondary' ? 0.7
                   : 0.5;

      sourcesObject[docId] = {
        rss_url: source.url,
        source_name: source.name,
        weight: weight,
        active: true,
      };

      console.log(`   ✓ ${source.name}`);
      console.log(`     URL: ${source.url}`);
      console.log(`     Category: ${source.category} (weight: ${weight})`);
      console.log(`     Doc ID: ${docId}`);
      console.log('');

      totalSeeded++;
    }

    // Write all sources to single document
    const metroSourcesRef = db
      .collection('system')
      .doc('sources')
      .collection(metroId)
      .doc('sources');

    await metroSourcesRef.set(sourcesObject, { merge: true });
  }

  console.log('═══════════════════════════════════════════════════════════');
  console.log(`✅ Seeded ${totalSeeded} sources across ${metroIds.length} metros`);
  console.log('');
  console.log('Firestore structure:');
  console.log('  /system/sources/{metro}/sources -> { source_id: { rss_url, source_name, weight, active } }');
  console.log('');
  console.log('Next steps:');
  console.log('  1. Verify sources in Firestore Console');
  console.log('  2. Run ingestion: firebase functions:shell → runIngest({metroId: "slc"})');
  console.log('  3. Check articles: /articles collection');
  console.log('═══════════════════════════════════════════════════════════');

  process.exit(0);
}

seedSources().catch((error) => {
  console.error('❌ Failed to seed sources:', error);
  process.exit(1);
});
