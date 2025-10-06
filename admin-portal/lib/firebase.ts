import { initializeApp, getApps } from 'firebase/app';
import { getAuth, GoogleAuthProvider, connectAuthEmulator } from 'firebase/auth';
import { getFirestore, connectFirestoreEmulator } from 'firebase/firestore';
import { getFunctions, connectFunctionsEmulator } from 'firebase/functions';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

// Initialize Firebase
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

// Initialize services
export const auth = getAuth(app);
export const db = getFirestore(app);
export const functions = getFunctions(app);
export const googleProvider = new GoogleAuthProvider();

// Connect to emulators in development
const useEmulators = process.env.NEXT_PUBLIC_USE_EMULATORS === 'true';

if (useEmulators && typeof window !== 'undefined') {
  console.log('🔧 Connecting to Firebase emulators...');

  // Firestore emulator
  if (process.env.NEXT_PUBLIC_FIRESTORE_EMULATOR_HOST) {
    const [host, port] = process.env.NEXT_PUBLIC_FIRESTORE_EMULATOR_HOST.split(':');
    connectFirestoreEmulator(db, host, parseInt(port));
    console.log(`  ✓ Firestore: ${host}:${port}`);
  }

  // Auth emulator
  if (process.env.NEXT_PUBLIC_AUTH_EMULATOR_HOST) {
    const [host, port] = process.env.NEXT_PUBLIC_AUTH_EMULATOR_HOST.split(':');
    connectAuthEmulator(auth, `http://${host}:${port}`, { disableWarnings: true });
    console.log(`  ✓ Auth: ${host}:${port}`);
  }

  // Functions emulator
  if (process.env.NEXT_PUBLIC_FUNCTIONS_EMULATOR_HOST) {
    const [host, port] = process.env.NEXT_PUBLIC_FUNCTIONS_EMULATOR_HOST.split(':');
    connectFunctionsEmulator(functions, host, parseInt(port));
    console.log(`  ✓ Functions: ${host}:${port}`);
  }

  console.log('🔧 Emulators connected');
} else {
  console.log('🚀 Using production Firebase services');
}
