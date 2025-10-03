# BrightSide Development Tools

Scripts and utilities for development and testing.

## Firestore Seeding

### seed_firestore.dart

Seeds Firestore with sample article data for testing the app with Firebase backend.

**Prerequisites:**
- Firebase project created and configured
- Firebase CLI installed (`npm install -g firebase-tools`)
- Authenticated with Firebase (`firebase login`)
- Firebase initialized in project (`firebase init`)

**Usage:**

```bash
# Run the seed script
dart run tool/seed_firestore.dart
```

**What it does:**
- Creates sample articles for all three metros (SLC, NYC, GSP)
- Each metro gets 3 articles with realistic titles, snippets, and content
- Articles have random like counts (0-50)
- Published timestamps range from 1-48 hours ago
- All articles set to `status: 'published'` and `featured: false`

**Sample output:**
```
🌱 Seeding Firestore with sample data...

✅ Firebase initialized

📍 Seeding articles for slc...
  ✓ Created: New Ski Resort Opens in Big Cottonwood Canyon (23 likes, 12h ago)
  ✓ Created: Utah Tech Startup Raises $50M Series B (45 likes, 8h ago)
  ✓ Created: Downtown SLC Gets New Bike Lanes (7 likes, 36h ago)

📍 Seeding articles for nyc...
  ✓ Created: Brooklyn Bridge Gets Major Renovation (38 likes, 5h ago)
  ✓ Created: New Subway Line Opening in Queens (41 likes, 18h ago)
  ✓ Created: Hudson Yards Announces Public Art Installation (15 likes, 42h ago)

📍 Seeding articles for gsp...
  ✓ Created: Downtown Greenville Adds New Park (29 likes, 3h ago)
  ✓ Created: BMW Manufacturing Plant Expansion (50 likes, 24h ago)
  ✓ Created: Greenville Tech Hub Opens Downtown (11 likes, 45h ago)

✅ Successfully seeded 9 articles!

Articles distribution:
  - SLC: 3
  - NYC: 3
  - GSP: 3

🎉 Seeding complete!
```

**Notes:**
- Run this script whenever you need fresh test data
- Articles are created with batch writes for efficiency
- Each run creates new articles (doesn't delete existing ones)
- Use Firebase Console to manually delete old test data if needed

## Future Tools

Additional development tools will be added here as needed:
- Analytics data generators
- User profile seeders
- Submission status updaters
- Data migration scripts
