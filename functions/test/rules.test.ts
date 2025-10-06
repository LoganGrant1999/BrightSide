import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import * as fs from 'fs';
import * as path from 'path';

let testEnv: RulesTestEnvironment;

// Sample test data
const mockArticle = {
  id: 'article1',
  metroId: 'slc',
  title: 'Good News Story',
  snippet: 'A summary',
  body: 'Full article text',
  status: 'published',
  likeCount: 10,
  publishedAt: new Date(),
};

const mockSubmission = {
  user_id: 'user1',
  title: 'My Story',
  summary: 'A great thing that happened',
  metro_id: 'slc',
  status: 'pending',
  created_at: new Date(),
};

const mockLike = {
  user_id: 'user1',
  article_id: 'article1',
  metro_id: 'slc',
  created_at: new Date(),
};

const mockReport = {
  user_id: 'user1',
  article_id: 'article1',
  metro_id: 'slc',
  reason: 'spam',
  created_at: new Date(),
};

beforeAll(async () => {
  // Load firestore.rules from project root
  const rulesPath = path.resolve(__dirname, '../../firestore.rules');
  const rules = fs.readFileSync(rulesPath, 'utf8');

  testEnv = await initializeTestEnvironment({
    projectId: 'brightside-test',
    firestore: {
      rules,
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

describe('Articles Collection', () => {
  test('anyone can read articles', async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(unauthedDb.collection('articles').doc('article1').get());
  });

  test('unauthenticated users cannot write articles', async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      unauthedDb.collection('articles').doc('article1').set(mockArticle)
    );
  });

  test('authenticated users cannot write articles', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertFails(
      authedDb.collection('articles').doc('article1').set(mockArticle)
    );
  });

  test('admins cannot write articles (client-side)', async () => {
    const adminDb = testEnv
      .authenticatedContext('admin1', { admin: true })
      .firestore();
    // Even admins cannot write from client - rules say `allow write: if false`
    // Only Cloud Functions can write
    await assertFails(
      adminDb.collection('articles').doc('article1').set(mockArticle)
    );
  });
});

describe('Submissions Collection', () => {
  test('authenticated users can create their own submission', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertSucceeds(
      authedDb.collection('submissions').doc('sub1').set(mockSubmission)
    );
  });

  test('unauthenticated users cannot create submissions', async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      unauthedDb.collection('submissions').doc('sub1').set(mockSubmission)
    );
  });

  test('users cannot create submissions for other users', async () => {
    const authedDb = testEnv.authenticatedContext('user2').firestore();
    await assertFails(
      authedDb.collection('submissions').doc('sub1').set(mockSubmission)
    );
  });

  test('users cannot create submission with non-pending status', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertFails(
      authedDb.collection('submissions').doc('sub1').set({
        ...mockSubmission,
        status: 'approved',
      })
    );
  });

  test('users can read their own submissions', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('submissions').doc('sub1').set(mockSubmission);
    });
    await assertSucceeds(authedDb.collection('submissions').doc('sub1').get());
  });

  test('users cannot read other users submissions', async () => {
    const authedDb = testEnv.authenticatedContext('user2').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('submissions').doc('sub1').set(mockSubmission);
    });
    await assertFails(authedDb.collection('submissions').doc('sub1').get());
  });

  test('users can update their own pending submissions', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('submissions').doc('sub1').set(mockSubmission);
    });
    await assertSucceeds(
      authedDb.collection('submissions').doc('sub1').update({
        title: 'Updated Title',
      })
    );
  });

  test('users cannot update submissions after status changes from pending', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('submissions').doc('sub1').set({
        ...mockSubmission,
        status: 'approved',
      });
    });
    await assertFails(
      authedDb.collection('submissions').doc('sub1').update({
        title: 'Updated Title',
      })
    );
  });

  test('users cannot change status of their own submissions', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('submissions').doc('sub1').set(mockSubmission);
    });
    await assertFails(
      authedDb.collection('submissions').doc('sub1').update({
        status: 'approved',
      })
    );
  });

  test('admins can approve/reject submissions via custom claims', async () => {
    const adminDb = testEnv
      .authenticatedContext('admin1', { admin: true })
      .firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('submissions').doc('sub1').set(mockSubmission);
    });
    await assertSucceeds(
      adminDb.collection('submissions').doc('sub1').update({
        status: 'approved',
      })
    );
  });

  test('admins can read all submissions', async () => {
    const adminDb = testEnv
      .authenticatedContext('admin1', { admin: true })
      .firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('submissions').doc('sub1').set(mockSubmission);
    });
    await assertSucceeds(adminDb.collection('submissions').doc('sub1').get());
  });
});

describe('ArticleLikes Collection', () => {
  test('authenticated users can create their own like', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertSucceeds(
      authedDb.collection('articleLikes').doc('user1_article1').set(mockLike)
    );
  });

  test('unauthenticated users cannot create likes', async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      unauthedDb.collection('articleLikes').doc('user1_article1').set(mockLike)
    );
  });

  test('users cannot create likes for other users', async () => {
    const authedDb = testEnv.authenticatedContext('user2').firestore();
    await assertFails(
      authedDb.collection('articleLikes').doc('user2_article1').set(mockLike)
    );
  });

  test('users can delete their own likes (idempotent unlike)', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('articleLikes').doc('user1_article1').set(mockLike);
    });
    await assertSucceeds(
      authedDb.collection('articleLikes').doc('user1_article1').delete()
    );
  });

  test('users cannot delete other users likes', async () => {
    const authedDb = testEnv.authenticatedContext('user2').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('articleLikes').doc('user1_article1').set(mockLike);
    });
    await assertFails(
      authedDb.collection('articleLikes').doc('user1_article1').delete()
    );
  });

  test('users can read their own likes', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('articleLikes').doc('user1_article1').set(mockLike);
    });
    await assertSucceeds(
      authedDb.collection('articleLikes').doc('user1_article1').get()
    );
  });

  test('users cannot read other users likes', async () => {
    const authedDb = testEnv.authenticatedContext('user2').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('articleLikes').doc('user1_article1').set(mockLike);
    });
    await assertFails(
      authedDb.collection('articleLikes').doc('user1_article1').get()
    );
  });

  test('creating duplicate like is idempotent (overwrite allowed)', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('articleLikes').doc('user1_article1').set(mockLike);
    });
    // User can "create" again (set operation on existing doc)
    await assertSucceeds(
      authedDb.collection('articleLikes').doc('user1_article1').set(mockLike)
    );
  });
});

describe('Reports Collection', () => {
  test('authenticated users can create reports', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertSucceeds(
      authedDb.collection('reports').doc('report1').set(mockReport)
    );
  });

  test('unauthenticated users cannot create reports', async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      unauthedDb.collection('reports').doc('report1').set(mockReport)
    );
  });

  test('users cannot create reports for other users', async () => {
    const authedDb = testEnv.authenticatedContext('user2').firestore();
    await assertFails(
      authedDb.collection('reports').doc('report1').set(mockReport)
    );
  });

  test('reports must have valid reason', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertFails(
      authedDb.collection('reports').doc('report1').set({
        ...mockReport,
        reason: 'invalid_reason',
      })
    );
  });

  test('authenticated non-admin users cannot read reports', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('reports').doc('report1').set(mockReport);
    });
    await assertFails(authedDb.collection('reports').doc('report1').get());
  });

  test('admins can read reports', async () => {
    const adminDb = testEnv
      .authenticatedContext('admin1', { admin: true })
      .firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('reports').doc('report1').set(mockReport);
    });
    await assertSucceeds(adminDb.collection('reports').doc('report1').get());
  });

  test('unauthenticated users cannot read reports', async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().collection('reports').doc('report1').set(mockReport);
    });
    await assertFails(unauthedDb.collection('reports').doc('report1').get());
  });
});

describe('Edge Cases and Validation', () => {
  test('submission with too long title is rejected', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertFails(
      authedDb.collection('submissions').doc('sub1').set({
        ...mockSubmission,
        title: 'x'.repeat(201), // Exceeds 200 char limit
      })
    );
  });

  test('submission with too long summary is rejected', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertFails(
      authedDb.collection('submissions').doc('sub1').set({
        ...mockSubmission,
        summary: 'x'.repeat(1001), // Exceeds 1000 char limit
      })
    );
  });

  test('submission missing required fields is rejected', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertFails(
      authedDb.collection('submissions').doc('sub1').set({
        user_id: 'user1',
        title: 'Test',
        // Missing summary, metro_id, status, created_at
      })
    );
  });

  test('like missing required fields is rejected', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertFails(
      authedDb.collection('articleLikes').doc('user1_article1').set({
        user_id: 'user1',
        // Missing article_id, metro_id, created_at
      })
    );
  });

  test('report with non-timestamp created_at is rejected', async () => {
    const authedDb = testEnv.authenticatedContext('user1').firestore();
    await assertFails(
      authedDb.collection('reports').doc('report1').set({
        ...mockReport,
        created_at: 'not-a-timestamp',
      })
    );
  });
});
