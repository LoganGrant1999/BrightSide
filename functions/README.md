# BrightSide Cloud Functions

Firebase Cloud Functions for the BrightSide app.

## Functions

### likeArticle (Callable)
- Validates user authentication
- Creates/removes like records atomically
- Increments/decrements article like count
- Prevents liking featured articles

### rotateFeaturedDaily (Scheduled)
- Runs daily at 00:05 UTC
- Computes top 5 articles per metro from last 30 days
- Updates featured flags and timestamps

## Development

```bash
# Install dependencies
cd functions
npm install

# Build TypeScript
npm run build

# Run local emulator
npm run serve

# View logs
npm run logs
```

## Deployment

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:likeArticle
firebase deploy --only functions:rotateFeaturedDaily
```

## Requirements

- Node.js 18+
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase project configured (`firebase init`)
