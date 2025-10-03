# Onboarding Feature

First-run onboarding flow for BrightSide app.

## Flow

1. **Intro Screen** (`onboarding_intro_page.dart`)
   - Shows app value proposition
   - Features: Local stories, curated daily, submit stories
   - CTA: "Continue" → Location permission

2. **Location Permission** (`location_permission_page.dart`)
   - Soft-ask explaining why we need location
   - "Allow Location Access" → Native permission prompt
   - "Choose Manually" → Metro picker
   - If granted: Auto-detect metro from GPS (80km radius)
   - If denied: Redirect to metro picker

3. **Metro Picker** (`metro_picker_page.dart`)
   - Manual selection of metro area
   - Options: Salt Lake City, New York City, Greenville-Spartanburg
   - Persists choice to SharedPreferences (will backfill to Firestore on sign-in)

4. **Auth Placeholder** (`auth_placeholder_page.dart`)
   - Placeholder for authentication (Prompt 2)
   - "Skip for Now" → Mark onboarding complete → Today feed

## Providers

### `locationPermissionProvider`
- Manages location permission state (granted/denied/permanently denied)
- `requestPermission()`: Request native permission
- `detectMetroFromLocation()`: GPS → nearest metro (Haversine formula)

### `metroStateProvider`
- Manages chosen metro state
- `setMetro(metroId)`: Save metro to SharedPreferences
- TODO: Backfill to Firestore on sign-in (Prompt 2)

### `onboardingStateProvider`
- Manages onboarding completion state
- `isCompleted`: Has user finished onboarding?
- `hasChosenMetro`: Has user chosen a metro?
- Persisted via SharedPreferences

## Routing

Gate in `app_router.dart`:
- If `!onboardingState.isCompleted` and not on `/onboarding/*` → redirect to `/onboarding/intro`
- If `onboardingState.isCompleted` and on `/onboarding/*` → redirect to `/today`

## Persistence

### Local (SharedPreferences)
- `onboarding_completed`: bool
- `metro_chosen`: bool
- `chosen_metro`: string (metro ID)

### Firestore (TODO: Prompt 2)
- `/users/{uid}.chosen_metro`: Backfill on sign-in
- When user signs in, move local metro to Firestore

## Acceptance Criteria

✅ Fresh install → intro → permission soft-ask → native prompt
✅ Allow path: Lands on Today feed
✅ Deny path: Metro picker shows immediately
✅ Metro persists across relaunch
✅ No dead ends (always a way forward)

## Future Work (Prompt 2)
- [ ] Wire real authentication
- [ ] Backfill local metro to Firestore on sign-in
- [ ] Load metro from Firestore for signed-in users
