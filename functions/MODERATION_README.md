# Submission Moderation

Callable Cloud Functions for moderating user-submitted stories until an admin UI is built.

## Overview

User submissions flow through moderation before becoming published articles:

```
User submits story via app
    ↓
/submissions/{id} created with status="pending"
    ↓
Admin reviews submission
    ↓
approveSubmission() OR rejectSubmission()
    ↓
Approved: Creates /articles doc, visible in Today feed
Rejected: Updates submission status, no article created
```

## Functions

### `approveSubmission`

Approves a pending submission and creates a published article.

**Parameters:**
```typescript
{
  submissionId: string;       // Required: Submission document ID
  publishNow?: boolean;       // Optional: true = publish immediately, false = schedule for next 5am (default: true)
  metroId?: string;          // Optional: Override metro (default: inferred from submission city/state)
}
```

**Returns:**
```typescript
{
  success: true,
  articleId: string,
  publishTime: string,       // ISO timestamp
  message: string
}
```

**Behavior:**
- Verifies caller has admin custom claim
- Checks submission status is "pending"
- Creates `/articles/{id}` document with:
  - `metroId`: Provided or inferred from city/state
  - `title`: From submission
  - `snippet`: First 300 chars of description
  - `body`: Empty (user submissions don't have full body)
  - `sourceName`: "Community Submission"
  - `sourceUrl`: Empty
  - `status`: "published"
  - `publishedAt`: Now or next 5am window
  - `likeCount`: 0
  - `featured`: false
- Updates submission:
  - `status`: "approved"
  - `approvedArticleId`: Link to article
  - `moderatorId`: Admin UID
  - `moderatedAt`: Timestamp

**Publishing Schedule:**
- `publishNow: true` → Article visible immediately in Today feed
- `publishNow: false` → Article scheduled for next 5am local time
  - If before 5am: Publishes at 5am today
  - If after 5am: Publishes at 5am tomorrow

### `rejectSubmission`

Rejects a pending submission without creating an article.

**Parameters:**
```typescript
{
  submissionId: string;       // Required: Submission document ID
  reason?: string;           // Optional: Rejection reason
}
```

**Returns:**
```typescript
{
  success: true,
  message: "Submission rejected"
}
```

**Behavior:**
- Verifies caller has admin custom claim
- Checks submission status is "pending"
- Updates submission:
  - `status`: "rejected"
  - `moderatorId`: Admin UID
  - `moderatorNote`: Reason or "No reason provided"
  - `moderatedAt`: Timestamp
- Does NOT create article

## Security

### Firestore Rules

**Articles collection:**
```
match /articles/{articleId} {
  allow read: if true;           // Public read
  allow write: if false;         // Only Cloud Functions can write
}
```

**Submissions collection:**
```
match /submissions/{submissionId} {
  allow create: if isAuthenticated() && request.resource.data.user_id == request.auth.uid;
  allow read: if isAuthenticated() && (resource.data.user_id == request.auth.uid || isAdmin());
  allow update: if isAuthenticated() && resource.data.user_id == request.auth.uid && resource.data.status == "pending";
  allow write: if isAdmin();    // Admins can do anything
}
```

### Admin Custom Claims

Only users with `admin: true` custom claim can call moderation functions.

**Set admin claim via Firebase CLI:**

```bash
# Get user UID
firebase auth:export users.json
# Find your user and note the UID

# Set admin claim
firebase auth:set-custom-user-claims <USER_UID> '{"admin": true}'

# Verify claim was set
firebase auth:get-user <USER_UID>
# Look for customClaims: { admin: true }
```

**Set admin claim via Node.js:**

```javascript
const admin = require('firebase-admin');
admin.initializeApp();

async function setAdmin(uid) {
  await admin.auth().setCustomUserClaims(uid, { admin: true });
  console.log(`Admin claim set for ${uid}`);
}

setAdmin('USER_UID_HERE');
```

**Important:** User must sign out and sign back in for custom claims to take effect in their auth token.

## Usage

### Via curl (Local Testing)

**1. Get ID token:**

In your Flutter app or via Firebase Auth REST API:
```dart
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken();
print(token);
```

**2. Approve submission:**

```bash
# Replace with your project ID and token
PROJECT_ID="your-project-id"
TOKEN="your-id-token"
SUBMISSION_ID="abc123"

curl -X POST \
  https://us-central1-${PROJECT_ID}.cloudfunctions.net/approveSubmission \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "data": {
      "submissionId": "'${SUBMISSION_ID}'",
      "publishNow": true
    }
  }'
```

**3. Reject submission:**

```bash
curl -X POST \
  https://us-central1-${PROJECT_ID}.cloudfunctions.net/rejectSubmission \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "data": {
      "submissionId": "'${SUBMISSION_ID}'",
      "reason": "Not appropriate for BrightSide"
    }
  }'
```

### Via Firebase Console (Testing)

1. Go to Cloud Functions → approveSubmission → Testing tab
2. Set authenticated user (must have admin claim)
3. Use test data:
```json
{
  "submissionId": "abc123",
  "publishNow": true,
  "metroId": "slc"
}
```
4. Click "Run the function"

### Via Flutter App (Future Admin Panel)

```dart
import 'package:cloud_functions/cloud_functions.dart';

class ModerationService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> approveSubmission({
    required String submissionId,
    bool publishNow = true,
    String? metroId,
  }) async {
    try {
      final result = await _functions.httpsCallable('approveSubmission').call({
        'submissionId': submissionId,
        'publishNow': publishNow,
        if (metroId != null) 'metroId': metroId,
      });

      print('Approved: ${result.data['articleId']}');
      print('Message: ${result.data['message']}');
    } on FirebaseFunctionsException catch (e) {
      print('Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  Future<void> rejectSubmission({
    required String submissionId,
    String? reason,
  }) async {
    try {
      final result = await _functions.httpsCallable('rejectSubmission').call({
        'submissionId': submissionId,
        if (reason != null) 'reason': reason,
      });

      print('Rejected: ${result.data['message']}');
    } on FirebaseFunctionsException catch (e) {
      print('Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}
```

## Testing Locally with Emulator

**1. Start emulators:**
```bash
cd functions
npm run serve
```

**2. Create test submission:**

Via Firestore emulator UI (http://localhost:4000):
```
Collection: submissions
Document ID: test-submission-1

Data:
{
  "id": "test-submission-1",
  "submittedByUid": "test-user-123",
  "title": "Community Garden Opens Downtown",
  "desc": "Local volunteers have created a beautiful new community garden in the heart of downtown, bringing fresh produce and green space to the neighborhood.",
  "city": "Salt Lake City",
  "state": "UT",
  "when": <Timestamp>,
  "photoUrl": "https://example.com/photo.jpg",
  "status": "pending",
  "createdAt": <Timestamp>
}
```

**3. Set admin claim for test user:**

Create `functions/set_admin.js`:
```javascript
const admin = require('firebase-admin');

process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';

admin.initializeApp({ projectId: 'brightside-test' });

async function setAdmin() {
  await admin.auth().setCustomUserClaims('test-user-123', { admin: true });
  console.log('Admin claim set');
}

setAdmin();
```

Run: `node set_admin.js`

**4. Call function via emulator:**

```bash
# Get emulated auth token
# (In Flutter app connected to emulator, print user.getIdToken())

# Call approve
curl -X POST \
  http://localhost:5001/brightside-test/us-central1/approveSubmission \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "data": {
      "submissionId": "test-submission-1",
      "publishNow": true
    }
  }'
```

**5. Verify in Firestore emulator:**
- Check `/articles` collection for new document
- Check `/submissions/test-submission-1` → status should be "approved"

## Metro Inference

If `metroId` is not provided, the function infers it from submission city/state:

| City/State | Metro |
|------------|-------|
| UT or "Salt Lake" | slc |
| NY or "New York" | nyc |
| SC, "Greenville", or "Spartanburg" | gsp |
| Unknown | slc (fallback) |

**Best practice:** Always provide `metroId` explicitly for accuracy.

## Today Feed Integration

**Approved articles appear in Today feed when:**
1. `status == "published"`
2. `metroId` matches user's selected metro
3. `publishedAt >= 5am local window start`
4. Sorted by `publishedAt desc`
5. Limited to 5 articles

**Scheduling behavior:**
- `publishNow: true` → Visible immediately (if within 5am window)
- `publishNow: false` → Visible starting at next 5am
  - Before 5am now → Publishes at 5am today
  - After 5am now → Publishes at 5am tomorrow

**Example:** Current time is 3pm on Tuesday
- `publishNow: true` → Article published at 3pm Tuesday, visible now
- `publishNow: false` → Article published at 5am Wednesday, visible Wednesday morning

## Monitoring

**Check function logs:**
```bash
firebase functions:log --only approveSubmission,rejectSubmission
```

**Key events to monitor:**
- "Submission approved" with articleId, moderatorId, publishTime
- "Submission rejected" with moderatorId, reason
- "Non-admin attempted to approve/reject" warnings
- Error logs for failed approvals

**Metrics to track:**
- Approval rate (approved / total submissions)
- Average moderation time (submission created → moderated)
- Articles per moderator
- Rejected submission reasons (common patterns)

## Error Handling

**Common errors:**

| Error Code | Cause | Solution |
|------------|-------|----------|
| `permission-denied` | User lacks admin claim | Set custom claim via Firebase CLI |
| `not-found` | Submission ID doesn't exist | Verify submission ID |
| `failed-precondition` | Submission not pending | Already moderated or wrong status |
| `invalid-argument` | Missing submissionId | Provide valid submission ID |
| `internal` | Unexpected error | Check function logs |

**Client error handling:**
```dart
try {
  await moderationService.approveSubmission(submissionId: id);
} on FirebaseFunctionsException catch (e) {
  switch (e.code) {
    case 'permission-denied':
      showError('You do not have admin permissions');
      break;
    case 'not-found':
      showError('Submission not found');
      break;
    case 'failed-precondition':
      showError('Submission has already been moderated');
      break;
    default:
      showError('An error occurred: ${e.message}');
  }
}
```

## Workflow

**Typical moderation flow:**

1. **User submits story** (via app)
   - Creates `/submissions/{id}` with `status: "pending"`
   - Moderators notified (future: via Cloud Function trigger)

2. **Admin reviews submission**
   - Read from `/submissions` collection
   - Filter by `status == "pending"`
   - Order by `createdAt desc`

3. **Admin makes decision**
   - **Approve:**
     - Call `approveSubmission(submissionId, publishNow: true/false)`
     - Article appears in Today feed
     - User could be notified (future enhancement)
   - **Reject:**
     - Call `rejectSubmission(submissionId, reason: "...")`
     - Submission marked rejected
     - User could be notified with reason (future enhancement)

4. **Verify in app**
   - Approved: Check Today feed for new article
   - Rejected: Submission no longer pending

## Future Enhancements

- [ ] Admin UI web app for reviewing submissions
- [ ] Email/push notifications to submitter on approval/rejection
- [ ] Batch approve/reject operations
- [ ] Submission editing before approval
- [ ] Category/tag assignment during approval
- [ ] Automatic spam detection
- [ ] Moderation queue with filters and search
- [ ] Approval history and audit log
- [ ] Scheduled publishing calendar

## Acceptance Criteria ✅

- [x] Submitting from app creates `/submissions` with `status: "pending"`
- [x] Calling `approveSubmission()` creates `/articles` doc
- [x] Approved article shows in Today feed (respecting ≤5 limit)
- [x] `publishNow: true` publishes immediately
- [x] `publishNow: false` schedules for next 5am window
- [x] Calling `rejectSubmission()` updates status to "rejected"
- [x] Rejected submissions do NOT create articles
- [x] Only admins can call functions (verified via custom claims)
- [x] Clients cannot write to `/articles` (Firestore rules block)
- [x] Functions log moderation actions with moderatorId

---

**Status:** ✅ Production Ready

**Last Updated:** 2025-10-03
