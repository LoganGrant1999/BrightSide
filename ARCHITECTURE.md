# BrightSide App Architecture Guide

## Table of Contents
1. [Overview](#overview)
2. [Frontend (Flutter/Dart)](#frontend-flutterdart)
3. [Backend (Firebase)](#backend-firebase)
4. [Data Flow](#data-flow)
5. [Architecture Patterns](#architecture-patterns)

---

## Overview

BrightSide is a **mobile-first application** built with:
- **Frontend**: Flutter (Dart) - Cross-platform mobile UI framework
- **Backend**: Firebase - Google's Backend-as-a-Service (BaaS)
- **State Management**: Riverpod - Reactive state management for Flutter
- **Architecture**: Clean Architecture with Repository Pattern

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     MOBILE APP (Flutter)                │
│  ┌──────────────┬──────────────┬──────────────────┐    │
│  │ Presentation │   Business   │   Data Layer     │    │
│  │    Layer     │    Logic     │  (Repositories)  │    │
│  └──────────────┴──────────────┴──────────────────┘    │
└─────────────────────────────────────────────────────────┘
                           ↕
┌─────────────────────────────────────────────────────────┐
│                    BACKEND (Firebase)                   │
│  ┌──────────────┬──────────────┬──────────────────┐    │
│  │  Cloud       │  Firestore   │   Firebase       │    │
│  │  Functions   │  Database    │   Storage        │    │
│  └──────────────┴──────────────┴──────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### Frontend vs Backend File Structure

```
PROJECT ROOT
│
├── 📱 FRONTEND (Flutter/Dart)
│   │
│   └── lib/
│       ├── main.dart                              # App entry point
│       │
│       ├── core/                                  # Shared infrastructure
│       │   ├── config/
│       │   │   └── environment.dart              # Env config, feature flags
│       │   ├── theme/
│       │   │   └── app_theme.dart                # Design system (colors, fonts)
│       │   ├── utils/
│       │   │   ├── ui.dart                       # UI helpers (snackbars, dialogs)
│       │   │   └── geo.dart                      # Location utilities
│       │   └── router/
│       │       └── app_router.dart               # Navigation routes
│       │
│       ├── shared/                                # Reusable components
│       │   ├── services/
│       │   │   ├── firebase_boot.dart            # 🔌 Firebase initialization
│       │   │   ├── functions_service.dart        # 🔌 Cloud Functions client
│       │   │   ├── app_router.dart               # Route definitions
│       │   │   └── issue_cache.dart              # Local data cache
│       │   └── widgets/
│       │       ├── story_card.dart               # Reusable story card UI
│       │       └── metro_picker_dialog.dart      # Metro selection dialog
│       │
│       └── features/                              # Feature modules
│           │
│           ├── today/                            # Today's stories feature
│           │   └── today_screen.dart            # UI: Today tab
│           │
│           ├── popular/                          # Popular stories feature
│           │   └── popular_screen.dart          # UI: Popular tab
│           │
│           ├── submit/                           # Story submission feature
│           │   ├── submit_screen.dart           # UI: Submit form
│           │   └── model/
│           │       └── submission_fs.dart       # 📦 Firestore submission model
│           │
│           ├── story/                            # Core story feature
│           │   ├── presentation/
│           │   │   └── story_details_screen.dart # UI: Story detail view
│           │   ├── providers/
│           │   │   └── story_providers.dart      # State management
│           │   ├── data/
│           │   │   ├── story_repository.dart     # Abstract interface
│           │   │   ├── story_repository_firebase.dart # 🔌 Firebase impl
│           │   │   └── http_story_repository.dart # HTTP impl (future)
│           │   └── model/
│           │       ├── story.dart                # UI model
│           │       └── article_fs.dart           # 📦 Firestore article model
│           │
│           ├── metro/                            # Metro selection feature
│           │   ├── metro.dart                   # Metro data model
│           │   └── metro_provider.dart          # Metro state management
│           │
│           ├── auth/                             # Authentication feature
│           │   ├── providers/
│           │   │   └── auth_provider.dart       # Auth state management
│           │   ├── data/
│           │   │   └── auth_repository.dart     # Auth operations
│           │   ├── models/
│           │   │   └── auth_user.dart           # User model
│           │   └── presentation/
│           │       └── auth_gate.dart           # Auth route guard
│           │
│           ├── settings/                         # Settings feature
│           │   └── settings_screen.dart         # UI: Settings, debug tools
│           │
│           └── profile/                          # User profile feature
│               └── model/
│                   └── user_profile_fs.dart     # 📦 Firestore user model
│
├── 🔥 BACKEND (Firebase)
│   │
│   ├── functions/                                # Cloud Functions (TypeScript)
│   │   ├── index.ts                             # Backend logic
│   │   │   ├── likeArticle()                   # Callable: Like/unlike articles
│   │   │   ├── fixSeedForMetro()               # Callable: Admin seed fix tool
│   │   │   └── rotateFeaturedDaily()           # Scheduled: Daily featured rotation
│   │   ├── package.json                         # Node.js dependencies
│   │   └── tsconfig.json                        # TypeScript config
│   │
│   └── firebase/                                 # Firebase config
│       ├── firestore.rules                      # Security rules
│       └── firestore.indexes.json               # Database indexes (auto-generated)
│
└── 🛠️  TOOLING
    │
    ├── tool/
    │   └── seed_firestore.dart                  # Dev tool: Seed test data
    │
    ├── .vscode/                                  # VS Code settings
    │   ├── settings.json                        # IDE config (iOS-only)
    │   ├── launch.json                          # Debug config
    │   └── tasks.json                           # Build tasks
    │
    └── pubspec.yaml                              # Flutter dependencies

LEGEND:
  📱 = Frontend (Flutter mobile app)
  🔥 = Backend (Firebase serverless)
  🔌 = Frontend-to-backend connection point
  📦 = Firestore data model (shared schema knowledge)
  🛠️  = Development tools
```

**Key Connection Points (🔌)**:
- `firebase_boot.dart` → Initializes Firebase SDK, handles auth
- `functions_service.dart` → Calls Cloud Functions from Flutter
- `story_repository_firebase.dart` → Queries Firestore, calls Cloud Functions
- `*_fs.dart` models → Match Firestore document structure

---

## Frontend (Flutter/Dart)

The frontend is a **Flutter mobile application** located in the `lib/` directory. Flutter compiles to native iOS and Android apps.

### Entry Point

#### `lib/main.dart`
**What it does**: Application entry point
- Initializes Firebase connection
- Sets up SharedPreferences for local storage
- Configures Riverpod dependency injection
- Launches the root `BrightSideApp` widget

**Key responsibilities**:
```dart
main() → Initialize Firebase → Setup DI → Run App
```

---

### Core Layer (`lib/core/`)

Shared infrastructure and utilities used across the entire app.

#### `lib/core/config/environment.dart`
**Purpose**: Environment configuration
- Defines dev/staging/production environments
- Controls whether to use Firebase or mock data
- Feature flags via compile-time constants

#### `lib/core/theme/app_theme.dart`
**Purpose**: Visual design system
- App-wide colors, fonts, spacing constants
- Consistent UI styling across all screens

#### `lib/core/utils/ui.dart`
**Purpose**: UI helper utilities
- `UIHelpers.showSuccessSnackBar()` - Success messages
- `UIHelpers.showErrorSnackBar()` - Error messages
- `handleError()` - Centralized error display

#### `lib/core/utils/geo.dart`
**Purpose**: Geographic utilities
- Location-based features (finding user's metro area)

#### `lib/core/router/app_router.dart`
**Purpose**: Navigation configuration
- Defines app routes and navigation structure
- Uses `go_router` for declarative routing

---

### Shared Layer (`lib/shared/`)

Reusable components and services used by multiple features.

#### `lib/shared/services/firebase_boot.dart`
**Purpose**: Firebase initialization & authentication
- `initFirebase()` - Connects to Firebase backend
- Auto-creates anonymous user on first launch
- Providers for user authentication state

#### `lib/shared/services/functions_service.dart`
**Purpose**: Cloud Functions client
- Wraps calls to backend Firebase Functions
- `fixSeedForMetro()` - Admin tool to fix test data

#### `lib/shared/services/app_router.dart`
**Purpose**: Route definitions
- Maps URLs to screen widgets
- `/today`, `/popular`, `/submit`, `/settings`, etc.

#### `lib/shared/services/issue_cache.dart`
**Purpose**: Local data caching
- Caches story data to reduce network calls
- Implements time-based cache invalidation

#### `lib/shared/widgets/story_card.dart`
**Purpose**: Reusable story card UI component
- Displays story preview with image, title, likes
- Handles like button interaction
- Shows loading shimmer animation

#### `lib/shared/widgets/metro_picker_dialog.dart`
**Purpose**: Metro selection dialog
- Allows user to choose their city/metro area

---

### Features Layer (`lib/features/`)

Each feature is a **self-contained module** following Clean Architecture:

```
feature/
  ├── presentation/   # UI screens and widgets
  ├── providers/      # State management (Riverpod)
  ├── data/          # Data sources & repositories
  └── model/         # Data models
```

---

#### **Today Feature** (`lib/features/today/`)

**Purpose**: Shows recent positive news for selected metro

##### `lib/features/today/today_screen.dart`
- **Layer**: Presentation
- **What it does**: UI screen displaying today's stories
- **Features**:
  - Fetches stories for active metro via `todayStoriesProvider`
  - Pull-to-refresh functionality
  - Loading shimmer skeletons
  - Empty state: "No stories yet — share a positive moment!"

---

#### **Popular Feature** (`lib/features/popular/`)

**Purpose**: Shows most-liked stories in selected metro

##### `lib/features/popular/popular_screen.dart`
- **Layer**: Presentation
- **What it does**: UI screen displaying popular stories (top 10 by likes)
- **Features**:
  - Ranked list display (1st, 2nd, 3rd...)
  - Auto-refreshes data
  - Same loading/empty states as Today

---

#### **Submit Feature** (`lib/features/submit/`)

**Purpose**: Allows users to submit positive local stories

##### `lib/features/submit/submit_screen.dart`
- **Layer**: Presentation
- **What it does**: Form to submit user-generated stories
- **Features**:
  - Title, description, optional photo
  - Metro selection
  - Validates auth (creates anonymous user if needed)
  - Uploads to `/submissions` collection in Firestore

##### `lib/features/submit/model/submission_fs.dart`
- **Layer**: Data Model
- **What it does**: Defines submission data structure
- **Uses**: Freezed (immutable data classes) + JSON serialization

---

#### **Story Feature** (`lib/features/story/`)

**Purpose**: Core story/article management

##### Presentation Layer
- `lib/features/story/presentation/story_details_screen.dart`
  - Full story detail view
  - Like button with real-time count updates
  - Report functionality (flag inappropriate content)
  - Debug: Toggle featured status (dev mode only)

##### Data Layer
- `lib/features/story/data/story_repository.dart`
  - **Interface**: Defines contract for story data operations
  - Methods: `fetchToday()`, `fetchPopular()`, `like()`, `submitUserStory()`

- `lib/features/story/data/story_repository_firebase.dart`
  - **Implementation**: Real Firebase backend
  - Queries Firestore `/articles` collection
  - Handles photo uploads to Firebase Storage
  - Calls Cloud Functions for likes

- `lib/features/story/data/http_story_repository.dart`
  - **Implementation**: HTTP API backend (future use)

- `lib/features/story/data/story_repository.dart` (also contains `MockStoryRepository`)
  - **Implementation**: Local mock data for development
  - Uses SharedPreferences for persistence
  - No network calls needed

##### State Management
- `lib/features/story/providers/story_providers.dart`
  - **Riverpod Providers**: Manage story state
  - `todayStoriesProvider` - Fetches today's stories
  - `popularStoriesProvider` - Fetches popular stories
  - `storyByIdProvider` - Fetches single story
  - `LikesController` - Manages like/unlike state
  - `LikeBlockedFeaturedException` - Custom error type

##### Models
- `lib/features/story/model/story.dart`
  - App's internal story model (used in UI)

- `lib/features/story/model/article_fs.dart`
  - Firestore article model (database format)
  - Has extra fields like `featured`, `featuredAt`, `authorUid`

**Why two models?** Separation of concerns:
- `Story` = what the UI needs
- `ArticleFs` = what the database stores

---

#### **Metro Feature** (`lib/features/metro/`)

**Purpose**: Manages user's selected metro/city

##### `lib/features/metro/metro.dart`
- **Data Model**: Defines supported metros
- Cities: SLC (Salt Lake City), NYC (New York), GSP (Greenville-Spartanburg)

##### `lib/features/metro/metro_provider.dart`
- **State Management**:
  - Stores active metro selection
  - Persists to SharedPreferences
  - `setFromLocation()` - Auto-detect metro from GPS

---

#### **Auth Feature** (`lib/features/auth/`)

**Purpose**: User authentication

##### `lib/features/auth/providers/auth_provider.dart`
- **State Management**: Auth state (signed in/out)
- Manages user session

##### `lib/features/auth/data/auth_repository.dart`
- **Data Layer**: Auth operations
- Sign in, sign out, account deletion

##### `lib/features/auth/models/auth_user.dart`
- **Data Model**: Authenticated user info

##### `lib/features/auth/presentation/auth_gate.dart`
- **UI Component**: Route guard for protected screens

---

#### **Settings Feature** (`lib/features/settings/`)

**Purpose**: App configuration and account management

##### `lib/features/settings/settings_screen.dart`
- **Presentation**: Settings UI
- Account info, metro selection, delete account
- **Debug tools**:
  - `[DEBUG] Fix seed for current metro` - Calls backend to refresh test data

---

#### **Profile Feature** (`lib/features/profile/`)

**Purpose**: User profiles (future feature)

##### `lib/features/profile/model/user_profile_fs.dart`
- **Data Model**: User profile structure
- Fields: displayName, photoURL, bio, stats (articles, likes)
- Includes nested models: `UserRoles`, `UserStats`

---

## Backend (Firebase)

The backend runs on **Firebase** (Google's serverless platform). No traditional server code - just configuration and serverless functions.

### Firebase Services Used

1. **Firebase Authentication** - Anonymous user creation
2. **Cloud Firestore** - NoSQL database
3. **Cloud Functions** - Serverless backend logic
4. **Firebase Storage** - Photo/file storage

---

### Cloud Functions (`functions/`)

Serverless backend code written in **TypeScript**, deployed to Google Cloud.

#### `functions/index.ts`
**Purpose**: All backend business logic

##### Function: `likeArticle` (Callable)
- **Type**: HTTPS Callable (invoked from mobile app)
- **Auth**: Requires authenticated user
- **What it does**:
  1. Validates article exists and isn't featured
  2. Atomically creates/removes like record in `/articleLikes`
  3. Increments/decrements `likeCount` on article
  4. Returns updated count
- **Error handling**: Throws `failed-precondition` if article is featured

##### Function: `fixSeedForMetro` (Callable - Admin Only)
- **Type**: HTTPS Callable (debug/development tool)
- **Auth**: Requires authenticated user + secret token
- **What it does**:
  1. Finds articles for specified metro
  2. Fixes missing/incorrect fields:
     - Sets `status: 'published'`
     - Sets `featured: false`
     - Updates `publishedAt` to recent timestamp
  3. Returns count of updated articles
- **Security**: Token must match `FIX_SEED_TOKEN` environment variable

##### Function: `rotateFeaturedDaily` (Scheduled)
- **Type**: Scheduled (Cloud Scheduler)
- **Schedule**: Runs daily at 00:05 UTC
- **What it does**:
  1. For each metro, finds top 5 articles by likes (last 30 days)
  2. Clears old featured flags
  3. Sets new top 5 as featured
- **Purpose**: Automatically rotates "featured" stories

#### `functions/package.json`
**Purpose**: Node.js dependencies
- Lists required npm packages: `firebase-admin`, `firebase-functions`

#### `functions/tsconfig.json`
**Purpose**: TypeScript compiler configuration
- Compiles `.ts` files to JavaScript for deployment

---

### Firestore Database (`firebase/`)

NoSQL document database. No traditional schema - just security rules.

#### `firebase/firestore.rules`
**Purpose**: Database security rules
- **What it does**: Controls who can read/write data

**Key rules**:
```javascript
// Public can read articles, only admins can write
articles: { allow read: if true; allow write: if false; }

// Users can create submissions for themselves
submissions: {
  allow read: if signedIn();
  allow create: if signedIn() && userOwnsDocument();
}

// Users can read/update their own profiles
users: {
  allow read: if true;
  allow update: if ownsProfile();
}
```

---

### Firestore Collections (Database Tables)

#### `/articles`
**Purpose**: Published stories
- **Fields**: id, metroId, title, snippet, body, imageUrl, authorUid, likeCount, featured, publishedAt, status
- **Access**: Public read, admin write only

#### `/submissions`
**Purpose**: User-submitted stories (pending approval)
- **Fields**: id, submittedByUid, title, desc, photoUrl, status (pending/approved/rejected)
- **Access**: Authenticated users can create, admins approve

#### `/users`
**Purpose**: User profiles
- **Fields**: uid, displayName, photoURL, bio, roles (admin flag), stats
- **Access**: Public read, users update their own

#### `/articleLikes`
**Purpose**: Like records (one doc per user-article pair)
- **Fields**: uid, articleId, createdAt
- **Access**: Users can like/unlike

#### `/reports`
**Purpose**: Flagged content reports
- **Fields**: articleId, uid, reason (spam/inaccurate/inappropriate), details
- **Access**: Users create, admins read

---

## Data Flow

### Example: User Likes a Story

```
1. USER TAPS LIKE BUTTON
   ↓
2. FRONTEND (StoryCard widget)
   - Disables button (prevents double-tap)
   - Shows loading spinner
   ↓
3. STATE MANAGEMENT (LikesController)
   - Calls repository.like(storyId, userId)
   ↓
4. DATA LAYER (StoryRepositoryFirebase)
   - Calls Cloud Function via Firebase SDK
   ↓
5. BACKEND (Cloud Function: likeArticle)
   - Validates auth
   - Checks if article is featured (throws error if yes)
   - Atomic transaction:
     * Create/delete like document in /articleLikes
     * Increment/decrement article.likeCount
   - Returns new count
   ↓
6. FRONTEND RECEIVES RESPONSE
   - Updates like count in UI
   - Re-enables button
   - If error: Shows "Already featured — likes paused" toast
```

### Example: Loading Today's Stories

```
1. USER OPENS "TODAY" TAB
   ↓
2. PRESENTATION (TodayScreen)
   - Watches todayStoriesProvider(metroId)
   ↓
3. STATE MANAGEMENT (todayStoriesProvider)
   - Checks cache first
   - If cache miss, calls repository.fetchToday(metroId)
   ↓
4. DATA LAYER (StoryRepositoryFirebase)
   - Queries Firestore:
     * articles
     * where metroId == 'slc'
     * where publishedAt >= (now - 24 hours)
     * orderBy publishedAt desc
     * limit 5
   - If no results: Falls back to latest 5 articles
   ↓
5. BACKEND (Firestore)
   - Executes query
   - Returns matching documents
   ↓
6. DATA LAYER
   - Maps ArticleFs (database format) → Story (UI format)
   - Caches results
   ↓
7. PRESENTATION
   - Displays StoryCard widgets
   - Shows shimmer skeleton while loading
```

---

## Architecture Patterns

### 1. **Clean Architecture**

The app is organized in layers with clear boundaries:

```
┌─────────────────────────────────────┐
│   Presentation Layer (UI)           │  ← Screens, Widgets
├─────────────────────────────────────┤
│   Business Logic (Providers)        │  ← Riverpod State
├─────────────────────────────────────┤
│   Data Layer (Repositories)         │  ← Abstract Interfaces
├─────────────────────────────────────┤
│   External Services (Firebase)      │  ← Implementations
└─────────────────────────────────────┘
```

**Benefits**:
- UI doesn't know about Firebase (could swap to different backend)
- Easy to test (can use MockStoryRepository)
- Clear separation of concerns

### 2. **Repository Pattern**

`StoryRepository` is an **interface** (contract):
```dart
abstract class StoryRepository {
  Future<List<Story>> fetchToday(String metroId);
  Future<int> like(String storyId, String userId);
  // ...
}
```

**Three implementations**:
1. `MockStoryRepository` - Fake data, no network
2. `StoryRepositoryFirebase` - Real Firebase backend
3. `HttpStoryRepository` - Future HTTP API backend

**Switching between them**: Change one line in `story_providers.dart`:
```dart
if (Environment.useFirebase) {
  return StoryRepositoryFirebase();  // ← Firebase
} else {
  return MockStoryRepository();       // ← Mock data
}
```

### 3. **State Management (Riverpod)**

**Providers** are like "smart variables" that:
- Hold state
- Notify listeners when state changes
- Rebuild UI automatically

**Example**:
```dart
// Provider definition
final todayStoriesProvider = FutureProvider.family<List<Story>, String>((ref, metroId) async {
  final repo = ref.watch(storyRepositoryProvider);
  return repo.fetchToday(metroId);
});

// UI watches the provider
final stories = ref.watch(todayStoriesProvider('slc'));
// When stories change, UI rebuilds automatically
```

### 4. **Dependency Injection**

Riverpod provides dependencies:
```dart
// Define what you need
final functionsServiceProvider = Provider((ref) =>
  FunctionsService(FirebaseFunctions.instance)
);

// Use it anywhere
final svc = ref.read(functionsServiceProvider);
await svc.fixSeedForMetro(metroId: 'slc', token: 'secret');
```

No manual `new` or constructor passing needed!

### 5. **Immutable Data Models**

Uses **Freezed** package for immutable data classes:
```dart
@freezed
class ArticleFs with _$ArticleFs {
  const factory ArticleFs({
    required String id,
    required String title,
    required int likeCount,
  }) = _ArticleFs;
}
```

**Benefits**:
- Can't accidentally modify data
- Built-in `copyWith()` for updates
- Auto-generates JSON serialization

---

## Summary

### Frontend = Flutter Mobile App (`lib/`)
- **Presentation**: UI screens (TodayScreen, PopularScreen, etc.)
- **State Management**: Riverpod providers
- **Data Layer**: Repository interfaces + implementations
- **Models**: Data structures (Story, User, etc.)

### Backend = Firebase (`functions/`, `firebase/`)
- **Cloud Functions**: Serverless TypeScript functions
- **Firestore**: NoSQL database with security rules
- **Storage**: Photo uploads
- **Authentication**: Anonymous users

### Key Architectural Decisions
1. **Clean Architecture** - Layered separation of concerns
2. **Repository Pattern** - Swappable data sources
3. **Riverpod** - Reactive state management
4. **Firebase** - Serverless backend (no server management)
5. **Freezed** - Immutable, type-safe data models

This architecture makes the app:
- **Testable** (can use mocks)
- **Maintainable** (clear boundaries)
- **Scalable** (can add features without breaking existing code)
- **Flexible** (can swap Firebase for another backend)
