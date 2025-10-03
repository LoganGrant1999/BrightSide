import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Seed Firestore with sample article data for testing
///
/// Run with: dart run tool/seed_firestore.dart
///
/// Note: Requires Firebase credentials to be configured
/// Set up Firebase config file or use Firebase CLI
void main() async {
  print('🌱 Seeding Firestore with sample data...\n');

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized\n');
  } catch (e) {
    print('❌ Failed to initialize Firebase: $e');
    print('\nMake sure you have:');
    print('  1. Run `firebase init` in your project');
    print('  2. Created a Firebase project');
    print('  3. Downloaded and configured firebase credentials');
    return;
  }

  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // Metro IDs to seed
  final metros = ['slc', 'nyc', 'gsp'];

  // Sample article titles and snippets by metro
  final sampleData = {
    'slc': [
      {
        'title': 'New Ski Resort Opens in Big Cottonwood Canyon',
        'snippet': 'World-class slopes ready for winter season',
        'body': 'A brand new ski resort featuring 50 runs and state-of-the-art lifts opened today in Big Cottonwood Canyon. The resort promises to bring more accessibility to Utah\'s famous powder.',
        'city': 'Salt Lake City',
        'state': 'UT',
      },
      {
        'title': 'Utah Tech Startup Raises \$50M Series B',
        'snippet': 'AI company focused on climate solutions',
        'body': 'Local startup ClimateAI announced their Series B funding round led by top Silicon Valley investors. The company plans to expand their team by 100 employees.',
        'city': 'Salt Lake City',
        'state': 'UT',
      },
      {
        'title': 'Downtown SLC Gets New Bike Lanes',
        'snippet': 'City expands sustainable transportation infrastructure',
        'body': 'Salt Lake City has completed a new network of protected bike lanes connecting downtown to surrounding neighborhoods. The project aims to reduce car dependency and improve air quality.',
        'city': 'Salt Lake City',
        'state': 'UT',
      },
    ],
    'nyc': [
      {
        'title': 'Brooklyn Bridge Gets Major Renovation',
        'snippet': 'Historic landmark to undergo \$500M restoration',
        'body': 'The iconic Brooklyn Bridge will receive its most comprehensive restoration in decades. Work will focus on structural integrity while preserving the bridge\'s historic character.',
        'city': 'New York',
        'state': 'NY',
      },
      {
        'title': 'New Subway Line Opening in Queens',
        'snippet': 'Commute times expected to drop by 30 minutes',
        'body': 'The MTA announced the opening of a new subway line connecting Queens to Manhattan, significantly reducing travel time for thousands of daily commuters.',
        'city': 'New York',
        'state': 'NY',
      },
      {
        'title': 'Hudson Yards Announces Public Art Installation',
        'snippet': 'World-renowned artists to showcase work',
        'body': 'Hudson Yards will host a new public art installation featuring works from internationally acclaimed artists. The exhibition will be free and open to the public.',
        'city': 'New York',
        'state': 'NY',
      },
    ],
    'gsp': [
      {
        'title': 'Downtown Greenville Adds New Park',
        'snippet': '15-acre green space opens to public',
        'body': 'A new urban park featuring walking trails, playgrounds, and event spaces opened in downtown Greenville. The park is part of the city\'s green initiative.',
        'city': 'Greenville',
        'state': 'SC',
      },
      {
        'title': 'BMW Manufacturing Plant Expansion',
        'snippet': 'Company to add 1,000 jobs in Spartanburg',
        'body': 'BMW announced a major expansion of their Spartanburg manufacturing facility, making it one of the largest automotive plants in North America.',
        'city': 'Spartanburg',
        'state': 'SC',
      },
      {
        'title': 'Greenville Tech Hub Opens Downtown',
        'snippet': 'New coworking space supports local startups',
        'body': 'A new technology hub has opened in downtown Greenville, offering coworking space, mentorship programs, and funding opportunities for local tech startups.',
        'city': 'Greenville',
        'state': 'SC',
      },
    ],
  };

  // Sample author names
  final authors = [
    {'name': 'Sarah Johnson', 'uid': 'author_1'},
    {'name': 'Michael Chen', 'uid': 'author_2'},
    {'name': 'Emily Rodriguez', 'uid': 'author_3'},
    {'name': 'David Park', 'uid': 'author_4'},
    {'name': 'Jessica Williams', 'uid': 'author_5'},
  ];

  int totalCreated = 0;
  final batch = firestore.batch();

  for (final metroId in metros) {
    print('📍 Seeding articles for $metroId...');

    final articles = sampleData[metroId]!;

    for (var i = 0; i < articles.length; i++) {
      final article = articles[i];
      final author = authors[random.nextInt(authors.length)];

      // Generate unique ID
      final id = '${metroId}_article_${DateTime.now().millisecondsSinceEpoch}_$i';

      // Random hours ago (1-48 hours)
      final hoursAgo = 1 + random.nextInt(48);
      final publishedAt = DateTime.now().subtract(Duration(hours: hoursAgo));

      // Random like count (0-50)
      final likeCount = random.nextInt(51);

      final docRef = firestore.collection('articles').doc(id);

      batch.set(docRef, {
        'id': id,
        'metroId': metroId,
        'state': article['state'],
        'city': article['city'],
        'title': article['title'],
        'snippet': article['snippet'],
        'body': article['body'],
        'imageUrl': 'https://picsum.photos/seed/$id/800/600',
        'authorUid': author['uid'],
        'authorName': author['name'],
        'authorPhotoURL': null,
        'likeCount': likeCount,
        'featured': false,
        'featuredAt': null,
        'publishedAt': Timestamp.fromDate(publishedAt),
        'status': 'published',
      });

      totalCreated++;
      print('  ✓ Created: ${article['title']} ($likeCount likes, ${hoursAgo}h ago)');
    }
  }

  // Commit batch write
  try {
    await batch.commit();
    print('\n✅ Successfully seeded $totalCreated articles!');
    print('\nArticles distribution:');
    print('  - SLC: ${sampleData['slc']!.length}');
    print('  - NYC: ${sampleData['nyc']!.length}');
    print('  - GSP: ${sampleData['gsp']!.length}');
    print('\n🎉 Seeding complete!');
  } catch (e) {
    print('\n❌ Failed to commit batch: $e');
  }
}
