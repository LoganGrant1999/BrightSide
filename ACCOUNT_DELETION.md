# Account Deletion Implementation

Complete implementation of account deletion functionality with backend data purge.

## Overview

Users can permanently delete their BrightSide account from the Account page in Settings. This triggers a Cloud Function that purges all user data from Firebase Auth and Firestore, including subcollections, likes, submissions, and analytics.

## User Flow

1. **Navigate to Account**: Settings → Account (sign-in required)
2. **Click Delete Account**: Red "Delete Account" button in Danger Zone section
3. **Confirm Deletion**: Detailed dialog shows all data to be deleted
4. **Processing**: Loading indicator while Cloud Function executes
5. **Success**: Toast confirmation, automatic sign out, redirect to onboarding
6. **Error Handling**: Error message if deletion fails (rare)

## What Gets Deleted

### Firebase Auth
- User authentication record
- Refresh tokens (revoked immediately)

### Firestore Collections
1. **users/{uid}** - User profile document
2. **users/{uid}/devices** - All device tokens (subcollection)
3. **articleLikes** - All likes where `user_id == uid`
4. **submissions** - All story submissions where `user_id == uid`

### Analytics
- User analytics redacted (user_id set to "deleted")
- Analytics data preserved for metrics but anonymized

### Audit Trail
- Deletion event logged to `deletedAccounts` collection
- Includes uid and timestamp for compliance

## Architecture

### Client-Side (Flutter)

**account_page.dart**
- Danger Zone section with delete button
- Comprehensive confirmation dialog
- Loading state during deletion
- Success/error handling with navigation

```dart
// In account_page.dart
void _showDeleteAccountDialog(BuildContext context, WidgetRef ref, String uid)
Future<void> _deleteAccount(BuildContext context, WidgetRef ref, String uid)
```

**auth_provider.dart**
- `deleteAccount()` method in AuthNotifier
- Calls UserService, handles sign out
- Updates auth state

```dart
// In AuthNotifier
Future<void> deleteAccount() async
```

**user_service.dart**
- `deleteUserAccount(uid)` method
- Invokes Cloud Function via cloud_functions package
- Error handling for Firebase Functions exceptions

```dart
Future<void> deleteUserAccount(String uid) async {
  final callable = _functions.httpsCallable('deleteAccount');
  final result = await callable.call<Map<String, dynamic>>({});
  // ...
}
```

### Backend (Cloud Functions)

**functions/src/deleteAccount.ts**

Callable Cloud Function with the following steps:

1. **Authentication Check**: Verifies user is authenticated
2. **Revoke Tokens**: `auth.revokeRefreshTokens(uid)` - immediate logout
3. **Delete Devices**: Batched deletion of `users/{uid}/devices` subcollection
4. **Delete Likes**: Query and delete all `articleLikes` where `user_id == uid`
5. **Delete Submissions**: Query and delete all `submissions` where `user_id == uid`
6. **Redact Analytics**: Set `user_id = 'deleted'` in analytics docs
7. **Delete User Doc**: Remove `users/{uid}` document
8. **Delete Auth Record**: `auth.deleteUser(uid)` - must be last
9. **Audit Log**: Record deletion in `deletedAccounts` collection

#### Batched Deletion Algorithm

```typescript
async function deleteDocumentsWhere(
  collectionName: string,
  field: string,
  value: string,
  batchSize: number
): Promise<void>
```

- Queries documents in batches (default 100)
- Recursively deletes until no documents remain
- Prevents timeout on large datasets
- Uses `process.nextTick()` for proper async recursion

## Security

### Authentication Required
```typescript
if (!context.auth) {
  throw new functions.https.HttpsError(
    "unauthenticated",
    "Must be authenticated to delete account"
  );
}
```

### User Can Only Delete Own Account
- Cloud Function uses `context.auth.uid`
- No admin bypass (future enhancement possible)
- Non-repudiable: user must be signed in to delete

### Immediate Session Invalidation
- Refresh tokens revoked FIRST
- Prevents any further API calls
- User immediately logged out across all devices

## Testing

### Manual Testing Steps

1. **Create Test Account**:
   - Sign up with test email
   - Add some likes and submissions
   - Enable notifications (creates device token)

2. **Verify Data Exists**:
   - Check Firestore console for user doc
   - Verify devices subcollection
   - Check articleLikes and submissions

3. **Delete Account**:
   - Navigate to Settings → Account
   - Click Delete Account
   - Confirm in dialog
   - Wait for success message

4. **Verify Deletion**:
   - Check Firestore: user doc should be gone
   - Check Auth console: user should be removed
   - Check articleLikes: all removed
   - Check submissions: all removed
   - Check analytics: user_id redacted to "deleted"
   - Check deletedAccounts: deletion logged

5. **Test Error Handling**:
   - Disconnect network during deletion
   - Verify error message shows
   - Verify user is NOT deleted if error occurs

### Automated Testing (Future)

```dart
// Example test structure
testWidgets('Delete account success flow', (tester) async {
  // 1. Create mock user
  // 2. Tap delete button
  // 3. Confirm dialog
  // 4. Verify Cloud Function called
  // 5. Verify navigation to onboarding
});
```

## Deployment

### Deploy Cloud Function

```bash
cd functions
npm install
cd ..
firebase deploy --only functions:deleteAccount
```

### Verify Deployment

1. Check Firebase Console → Functions
2. Function should appear as `deleteAccount`
3. Check logs for any deployment errors
4. Test with production account (use test user!)

## Monitoring

### Cloud Function Logs

```bash
# Stream logs
firebase functions:log --only deleteAccount

# Or view in Firebase Console
# Functions → deleteAccount → Logs tab
```

Look for:
- `Starting account deletion for user: {uid}`
- `Revoked refresh tokens for user: {uid}`
- `Deleted devices subcollection for user: {uid}`
- `Deleted article likes for user: {uid}`
- `Deleted submissions for user: {uid}`
- `Redacted analytics for user: {uid}`
- `Deleted user document for user: {uid}`
- `Deleted auth record for user: {uid}`

### Error Monitoring

Common errors:
- **unauthenticated**: User not signed in (shouldn't happen with UI guards)
- **internal**: Database error during deletion (rare, check Firestore rules)
- **permission-denied**: Firestore rules blocking deletion (check security rules)

## Firestore Security Rules

Ensure security rules allow Cloud Functions to delete user data:

```javascript
// In firestore.rules
match /articleLikes/{likeId} {
  allow delete: if request.auth != null &&
                   resource.data.user_id == request.auth.uid;
}

match /submissions/{submissionId} {
  allow delete: if request.auth != null &&
                   resource.data.user_id == request.auth.uid;
}
```

Cloud Functions run with admin privileges, so these rules don't apply to the function itself, only to direct client access.

## Privacy & Compliance

### GDPR Compliance
- ✅ Right to erasure (Article 17)
- ✅ Complete data deletion
- ✅ Audit trail for compliance verification
- ✅ Anonymous analytics (no PII after deletion)

### Data Retention
- User data: Immediately deleted
- Analytics: Anonymized (user_id → "deleted")
- Audit log: Retained for compliance (uid + timestamp only)

### What's NOT Deleted
- Published articles promoted from user submissions (editorial content)
- Anonymized analytics (no PII)
- Audit trail in `deletedAccounts` (compliance requirement)

## Troubleshooting

### "Failed to delete account" Error

**Check Cloud Function logs**:
```bash
firebase functions:log --only deleteAccount
```

**Common causes**:
1. Network timeout (large dataset)
   - Solution: Reduce batch size in deleteAccount.ts
2. Firestore permission denied
   - Solution: Check security rules
3. Auth user already deleted
   - Solution: Handle gracefully (check if user exists first)

### Account Partially Deleted

If deletion fails midway:
1. Check which step failed in logs
2. Manually verify/delete remaining data in Firestore console
3. Delete Auth record manually if it still exists
4. File bug report with error logs

### User Can't Delete Account (Button Disabled)

**Verify**:
1. User is signed in (check authProvider state)
2. firebaseUser is not null
3. appUser is not null
4. Check for loading state blocking UI

## Future Enhancements

1. **Email Confirmation**: Send confirmation email before deletion
2. **Grace Period**: 30-day soft delete with recovery option
3. **Admin Delete**: Allow admins to delete user accounts (moderation)
4. **Export Data**: GDPR export before deletion
5. **Deletion Reason**: Ask user why they're deleting (analytics)
6. **Cascading Delete**: Delete user reports, comments (when added)

## Files Modified

### Client
- `lib/features/auth/presentation/account_page.dart` - UI and delete flow
- `lib/features/auth/providers/auth_provider.dart` - deleteAccount method
- `lib/features/auth/services/user_service.dart` - Cloud Function call
- `lib/features/settings/settings_screen.dart` - Removed incomplete delete

### Backend
- `functions/src/deleteAccount.ts` - Cloud Function implementation (NEW)
- `functions/src/index.ts` - Export deleteAccount function

### Dependencies
- `cloud_functions: ^5.1.3` (already in pubspec.yaml)

## References

- [PRD Section 2.5, 3.6.1-3.6.4](../architecture.md)
- [Firebase Auth Admin SDK](https://firebase.google.com/docs/auth/admin)
- [Cloud Functions Callable](https://firebase.google.com/docs/functions/callable)
- [GDPR Right to Erasure](https://gdpr-info.eu/art-17-gdpr/)
