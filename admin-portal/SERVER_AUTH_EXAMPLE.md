# Server-Side Authentication for API Routes

This file contains example code for implementing server-side authentication in Next.js API routes.

**Note:** The current admin portal uses static export (`output: 'export'`) which doesn't support API routes.
If you need server-side API routes in the future, switch to `output: 'standalone'` and use the code below.

---

## Installation

If switching to API routes, install firebase-admin:

```bash
cd admin-portal
npm install firebase-admin
```

---

## Server Auth Utility

Create `lib/server-auth.ts`:

```typescript
/**
 * Server-side authentication utilities for API routes
 *
 * Usage in API route (app/api/example/route.ts):
 *
 * import { verifyAdminToken } from '@/lib/server-auth';
 * import { NextRequest, NextResponse } from 'next/server';
 *
 * export async function POST(request: NextRequest) {
 *   const authResult = await verifyAdminToken(request);
 *
 *   if (!authResult.success) {
 *     return NextResponse.json(
 *       { error: authResult.error },
 *       { status: authResult.status }
 *     );
 *   }
 *
 *   const uid = authResult.uid;
 *   // ... process authenticated admin request
 * }
 */

import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK (singleton)
if (!admin.apps.length) {
  if (process.env.FIRESTORE_EMULATOR_HOST) {
    console.log('[Server Auth] Using Firebase Emulator');
    admin.initializeApp({ projectId: 'brightside-test' });
  } else {
    admin.initializeApp();
  }
}

export interface AuthResult {
  success: boolean;
  uid?: string;
  email?: string;
  isAdmin?: boolean;
  error?: string;
  status?: number;
}

/**
 * Verify Firebase ID token and check for admin custom claim
 *
 * @param request - Next.js request object
 * @returns AuthResult with success status and user info or error details
 */
export async function verifyAdminToken(
  request: Request
): Promise<AuthResult> {
  try {
    // Extract Authorization header
    const authHeader = request.headers.get('Authorization');

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return {
        success: false,
        error: 'Missing or invalid Authorization header',
        status: 401,
      };
    }

    const idToken = authHeader.split('Bearer ')[1];

    if (!idToken) {
      return {
        success: false,
        error: 'No token provided',
        status: 401,
      };
    }

    // Verify ID token
    const decodedToken = await admin.auth().verifyIdToken(idToken);

    // Check for admin custom claim
    if (!decodedToken.admin) {
      return {
        success: false,
        error: 'Admin access required',
        status: 403,
      };
    }

    return {
      success: true,
      uid: decodedToken.uid,
      email: decodedToken.email,
      isAdmin: true,
    };
  } catch (error: any) {
    console.error('[Server Auth] Token verification failed:', error);

    if (error.code === 'auth/id-token-expired') {
      return {
        success: false,
        error: 'Token expired',
        status: 401,
      };
    }

    if (error.code === 'auth/argument-error') {
      return {
        success: false,
        error: 'Invalid token format',
        status: 401,
      };
    }

    return {
      success: false,
      error: 'Authentication failed',
      status: 401,
    };
  }
}

/**
 * Verify token without requiring admin claim (for general authenticated routes)
 */
export async function verifyUserToken(
  request: Request
): Promise<AuthResult> {
  try {
    const authHeader = request.headers.get('Authorization');

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return {
        success: false,
        error: 'Missing or invalid Authorization header',
        status: 401,
      };
    }

    const idToken = authHeader.split('Bearer ')[1];

    if (!idToken) {
      return {
        success: false,
        error: 'No token provided',
        status: 401,
      };
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);

    return {
      success: true,
      uid: decodedToken.uid,
      email: decodedToken.email,
      isAdmin: decodedToken.admin === true,
    };
  } catch (error: any) {
    console.error('[Server Auth] Token verification failed:', error);

    return {
      success: false,
      error: 'Authentication failed',
      status: 401,
    };
  }
}
```

---

## Example API Route

Create `app/api/example/route.ts`:

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
  const body = await request.json();

  // Your business logic here...

  return NextResponse.json({
    success: true,
    message: 'Admin action completed',
    uid,
  });
}
```

---

## Client-Side Usage

```typescript
import { auth } from '@/lib/firebase';

async function callAdminAPI() {
  const user = auth.currentUser;

  if (!user) {
    console.error('Not signed in');
    return;
  }

  const idToken = await user.getIdToken();

  const response = await fetch('/api/example', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${idToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      action: 'moderate',
      targetId: 'abc123',
    }),
  });

  const data = await response.json();
  console.log(data);
}
```

---

## Switching from Static Export to API Routes

**1. Update `next.config.ts`:**

```typescript
const nextConfig: NextConfig = {
  // Remove 'export' to enable API routes
  // output: 'export',  // <-- REMOVE THIS LINE
  basePath: '/admin',
  images: {
    unoptimized: true,
  },
};
```

**2. Update Firebase Hosting to use Next.js server:**

Deploy as Cloud Functions instead of static hosting, or use Firebase Hosting with Cloud Run.

See: https://firebase.google.com/docs/hosting/nextjs

---

## Current Architecture

The admin portal currently uses:
- **Static export** (`output: 'export'`) for Firebase Hosting
- **Client-side callable functions** for all server operations
- **ProtectedRoute component** for client-side auth checks

This approach:
- ✅ Simple deployment (no server required)
- ✅ Fast performance (static assets)
- ✅ Works well with Firebase Hosting
- ❌ No server-side rendering
- ❌ No API routes

If you need API routes in the future, follow the steps above to switch to a server-based deployment.
