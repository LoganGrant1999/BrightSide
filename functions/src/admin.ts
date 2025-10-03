import { DecodedIdToken } from "firebase-admin/auth";

/**
 * Check if user has admin privileges via custom claims
 */
export function isAdmin(auth: DecodedIdToken | undefined): boolean {
  if (!auth) return false;
  return auth.admin === true;
}
