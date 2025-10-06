# Admin Portal Setup & Deployment

Complete guide for setting up and deploying the BrightSide admin portal.

---

## Admin Role Management

### Grant Admin Access

To grant admin role to a user:

```bash
# Development (emulator)
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/admin_claims.ts grant admin@example.com

# Production
npx ts-node tool/admin_claims.ts grant admin@brightside.com
```

**Requirements:**
- User must have already signed up via the mobile app
- Uses email address to look up Firebase Auth user
- Sets `admin: true` custom claim on the user's ID token

**Output:**
```
🔑 Granting admin role to: admin@example.com

   ✓ Found user: admin@example.com
   ✓ UID: abc123xyz
   ✓ Admin claim granted

✅ Success! User is now an admin.

ℹ️  User must sign out and sign back in for changes to take effect.

Custom claims: { admin: true }
```

### Revoke Admin Access

To remove admin role from a user:

```bash
# Development (emulator)
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/admin_claims.ts revoke admin@example.com

# Production
npx ts-node tool/admin_claims.ts revoke admin@example.com
```

### List All Admins

To see all users with admin claims:

```bash
# Development (emulator)
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/admin_claims.ts list

# Production
npx ts-node tool/admin_claims.ts list
```

**Output:**
```
👥 Listing all admin users...

   Found 2 admin(s):

   • admin@brightside.com (abc123xyz)
   • moderator@brightside.com (def456uvw)
```

---

## Admin Portal Deployment

### Development Environment

**1. Start Firebase Emulators:**
```bash
firebase emulators:start
```

**2. Run Admin Portal Locally:**
```bash
cd admin-portal
npm run dev
```

**3. Access Portal:**
```
http://localhost:3000/admin
```

The portal will connect to Firebase emulators (Auth, Firestore, Functions) when `NEXT_PUBLIC_USE_EMULATORS=true` in `.env.development`.

### Production Deployment

**Build and deploy to Firebase Hosting:**

```bash
cd admin-portal

# Deploy to production
npm run deploy:prod

# OR deploy to dev environment
npm run deploy:dev
```

**Manual deployment:**
```bash
# Build admin portal
cd admin-portal
npm run build

# Deploy to Firebase Hosting
cd ..
firebase use prod
firebase deploy --only hosting:admin
```

**Access Portal:**
```
https://brightside-9a2c5.web.app/admin
# OR custom domain:
https://admin.brightside.com
```

---

## Authentication & Authorization

### Client-Side Protection

The admin portal uses **client-side** auth checks via the `ProtectedRoute` component:

**How it works:**
1. User signs in with Google OAuth
2. `AuthProvider` checks ID token for `admin: true` custom claim
3. `ProtectedRoute` wrapper redirects non-admins to `/unauthorized`

**Usage:**
```tsx
import { ProtectedRoute } from '@/components/protected-route';

export default function AdminPage() {
  return (
    <ProtectedRoute>
      {/* Admin-only content */}
    </ProtectedRoute>
  );
}
```

**Behavior:**
- Not signed in → Redirect to `/login`
- Signed in but not admin → Redirect to `/unauthorized`
- Signed in as admin → Show protected content

### Server-Side Protection (API Routes)

For future API routes, use server-side token verification:

**Create API route with admin check:**

`app/api/example/route.ts`:
```typescript
import { verifyAdminToken } from '@/lib/server-auth';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  // Verify admin token
  const authResult = await verifyAdminToken(request);

  if (!authResult.success) {
    return NextResponse.json(
      { error: authResult.error },
      { status: authResult.status }
    );
  }

  const uid = authResult.uid;

  // Process authenticated admin request
  return NextResponse.json({ success: true });
}
```

**Client-side usage:**
```typescript
import { auth } from '@/lib/firebase';

const user = auth.currentUser;
if (user) {
  const idToken = await user.getIdToken();

  const response = await fetch('/api/example', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${idToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ data: 'example' }),
  });
}
```

---

## Admin Portal Features

### Pending Submissions
**Route:** `/admin/submissions`

**Features:**
- View all pending user submissions
- Approve submissions → Publish as articles
- Reject submissions with reason

**Functions Used:**
- `approveSubmission(submissionId, publishNow)`
- `rejectSubmission(submissionId, reason)`

### Content Reports
**Route:** `/admin/reports`

**Features:**
- View flagged content reports
- Dismiss false reports
- Remove violating content

**Functions Used:**
- `moderateReport(reportId, action, reason)`

### Featured Articles
**Route:** `/admin/articles`

**Features:**
- Pin articles as featured
- Set featured duration
- Auto-rotation scheduler

**Functions Used:**
- `setFeaturedArticle(articleId, duration)`

---

## Firebase Hosting Configuration

### Hosting Targets

`.firebaserc`:
```json
{
  "projects": {
    "default": "brightside-9a2c5",
    "dev": "brightside-dev",
    "prod": "brightside-9a2c5"
  },
  "targets": {
    "brightside-9a2c5": {
      "hosting": {
        "admin": ["brightside-9a2c5"]
      }
    },
    "brightside-dev": {
      "hosting": {
        "admin": ["brightside-dev"]
      }
    }
  }
}
```

### Hosting Config

`firebase.json`:
```json
{
  "hosting": [
    {
      "target": "admin",
      "public": "admin-portal/out",
      "cleanUrls": true,
      "trailingSlash": false,
      "rewrites": [
        {
          "source": "**",
          "destination": "/index.html"
        }
      ]
    }
  ]
}
```

### Next.js Config

`admin-portal/next.config.ts`:
```typescript
const nextConfig: NextConfig = {
  output: 'export',        // Static export for Firebase Hosting
  basePath: '/admin',      // Serve under /admin path
  images: {
    unoptimized: true,     // Required for static export
  },
};
```

---

## Troubleshooting

### Issue: Admin claim not detected after granting

**Solution:**
User must sign out and sign back in for custom claims to refresh in ID token.

**Steps:**
1. Grant admin claim: `npx ts-node tool/admin_claims.ts grant user@example.com`
2. User signs out of admin portal
3. User signs back in
4. Custom claim now present in ID token

### Issue: "User not found" when granting admin

**Solution:**
User must sign up in the mobile app first to create Firebase Auth account.

**Steps:**
1. User downloads BrightSide app
2. User signs up with Google/Apple
3. Admin runs grant command with user's email

### Issue: Admin portal shows blank page

**Solution:**
Check basePath and build output directory.

**Debug:**
```bash
# Check build output
ls -la admin-portal/out

# Verify basePath in next.config.ts
cat admin-portal/next.config.ts

# Rebuild and redeploy
cd admin-portal
npm run build
npm run deploy:prod
```

### Issue: Functions not found in admin portal

**Solution:**
Ensure functions are deployed and emulators are running.

**Development:**
```bash
firebase emulators:start
```

**Production:**
```bash
cd functions
npm run deploy:prod
```

### Issue: Authentication fails in production

**Solution:**
Verify environment variables in `.env.production`.

**Check:**
```bash
cat admin-portal/.env.production
```

**Required variables:**
```env
NEXT_PUBLIC_FIREBASE_API_KEY=<your-api-key>
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=<your-project>.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=<your-project>
NEXT_PUBLIC_USE_EMULATORS=false
```

---

## Security Best Practices

### Custom Claims
- ✅ Custom claims are server-verified (cannot be faked by client)
- ✅ Claims are included in ID token (no extra DB lookup)
- ✅ Claims refresh on sign-out/sign-in

### Admin Access Control
- ✅ Client-side checks via `ProtectedRoute` (redirect non-admins)
- ✅ Server-side checks via `verifyAdminToken` (API routes)
- ✅ Firebase Security Rules check `request.auth.token.admin == true`

### Production Checklist
- [ ] Admin claims granted only to trusted staff
- [ ] `.env.production` contains real Firebase config (no emulator settings)
- [ ] Functions deployed with admin-only callable enforcement
- [ ] Firestore rules require `request.auth.token.admin == true` for admin writes

---

## Quick Commands Reference

```bash
# Admin Claims
npx ts-node tool/admin_claims.ts grant admin@example.com
npx ts-node tool/admin_claims.ts revoke admin@example.com
npx ts-node tool/admin_claims.ts list

# Admin Portal Development
cd admin-portal && npm run dev

# Admin Portal Deployment
cd admin-portal && npm run deploy:prod
cd admin-portal && npm run deploy:dev

# Firebase Hosting Only
firebase deploy --only hosting:admin

# Check Active Project
firebase use

# Switch Projects
firebase use dev
firebase use prod
```

---

## Custom Domain Setup (Optional)

To host admin portal at `admin.brightside.com`:

**1. Add custom domain in Firebase Console:**
- Go to Firebase Console → Hosting
- Click "Add custom domain"
- Enter `admin.brightside.com`

**2. Update DNS records:**
```
Type: A
Name: admin
Value: <Firebase IP from console>
```

**3. Wait for SSL provisioning (up to 24 hours)**

**4. Update `.env.production`:**
```env
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=admin.brightside.com
```

**5. Redeploy:**
```bash
cd admin-portal
npm run deploy:prod
```

---

## Monitoring & Logs

### View Admin Portal Logs

Firebase Hosting logs are available in Firebase Console:
- https://console.firebase.google.com/project/YOUR-PROJECT/hosting

### View Functions Logs

```bash
# Real-time logs
firebase use prod
firebase functions:log

# Filter by function
firebase functions:log --only approveSubmission
```

### Analytics

Track admin actions in Firebase Analytics:
```typescript
import { logEvent } from 'firebase/analytics';

// Log admin action
logEvent(analytics, 'admin_action', {
  action: 'approve_submission',
  submission_id: submissionId,
});
```
