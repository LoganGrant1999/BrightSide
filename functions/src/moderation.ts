import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {isAdmin} from "./admin";

interface ApproveSubmissionRequest {
  submissionId: string;
  publishNow?: boolean;
  metroId?: string;
}

interface RejectSubmissionRequest {
  submissionId: string;
  reason?: string;
}

interface SubmissionData {
  id: string;
  submittedByUid: string;
  title: string;
  desc: string;
  city: string;
  state: string;
  when: admin.firestore.Timestamp;
  photoUrl?: string;
  status: string;
  createdAt: admin.firestore.Timestamp;
}

/**
 * Calculate next 5am window start time for a metro
 * If publishNow is false, returns next 5am (today if before 5am, tomorrow if after)
 */
function nextWindowStart(metroId: string): admin.firestore.Timestamp {
  // Metro timezone mappings
  const timezones: Record<string, string> = {
    slc: "America/Denver",
    nyc: "America/New_York",
    gsp: "America/New_York",
  };

  const timezone = timezones[metroId] || "America/Denver";
  const now = new Date();

  // Get current time in metro timezone
  const localTime = new Date(
    now.toLocaleString("en-US", {timeZone: timezone})
  );

  // Create 5am today in metro timezone
  const fiveAmToday = new Date(localTime);
  fiveAmToday.setHours(5, 0, 0, 0);

  let nextWindow: Date;

  // If current time is before 5am, next window is today at 5am
  if (localTime < fiveAmToday) {
    nextWindow = fiveAmToday;
  } else {
    // Otherwise, next window is tomorrow at 5am
    nextWindow = new Date(fiveAmToday);
    nextWindow.setDate(nextWindow.getDate() + 1);
  }

  return admin.firestore.Timestamp.fromDate(nextWindow);
}

/**
 * Approve submission and create published article
 * Admin-only callable function
 */
export const approveSubmission = onCall<ApproveSubmissionRequest>(
  async (request) => {
    // Verify admin authentication
    if (!isAdmin(request.auth as any)) {
      logger.warn("Non-admin attempted to approve submission", {
        uid: request.auth?.uid,
      });
      throw new HttpsError(
        "permission-denied",
        "Only admins can approve submissions"
      );
    }

    const {submissionId, publishNow = true, metroId} = request.data;

    if (!submissionId || typeof submissionId !== "string") {
      throw new HttpsError("invalid-argument", "submissionId is required");
    }

    const db = admin.firestore();
    const submissionRef = db.collection("submissions").doc(submissionId);

    try {
      const submissionDoc = await submissionRef.get();

      if (!submissionDoc.exists) {
        throw new HttpsError(
          "not-found",
          `Submission ${submissionId} not found`
        );
      }

      const submission = submissionDoc.data() as SubmissionData;

      if (submission.status !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          `Submission status is ${submission.status}, expected pending`
        );
      }

      // Determine metro (use provided or infer from submission)
      const targetMetroId = metroId || inferMetroFromSubmission(submission);

      // Determine publish time
      const publishTime = publishNow ?
        admin.firestore.Timestamp.now() :
        nextWindowStart(targetMetroId);

      // Create article from submission
      const articleData = {
        metroId: targetMetroId,
        title: submission.title,
        snippet: submission.desc.substring(0, 300),
        body: "", // User submissions don't have full body
        imageUrl: submission.photoUrl || null,
        sourceName: "Community Submission",
        sourceUrl: "", // User submissions don't have external URLs
        status: "published",
        likeCount: 0,
        featured: false,
        publishedAt: publishTime,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      const articleRef = await db.collection("articles").add(articleData);

      // Update submission status
      await submissionRef.update({
        status: "approved",
        approvedArticleId: articleRef.id,
        moderatorId: request.auth?.uid || "unknown",
        moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info("Submission approved", {
        submissionId,
        articleId: articleRef.id,
        moderatorId: request.auth?.uid,
        publishNow,
        publishTime: publishTime.toDate().toISOString(),
      });

      return {
        success: true,
        articleId: articleRef.id,
        publishTime: publishTime.toDate().toISOString(),
        message: publishNow ?
          "Article published immediately" :
          "Article scheduled for next 5am window",
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      logger.error("Error approving submission", {
        submissionId,
        error,
      });
      throw new HttpsError("internal", "Failed to approve submission");
    }
  }
);

/**
 * Reject submission with optional reason
 * Admin-only callable function
 */
export const rejectSubmission = onCall<RejectSubmissionRequest>(
  async (request) => {
    // Verify admin authentication
    if (!isAdmin(request.auth as any)) {
      logger.warn("Non-admin attempted to reject submission", {
        uid: request.auth?.uid,
      });
      throw new HttpsError(
        "permission-denied",
        "Only admins can reject submissions"
      );
    }

    const {submissionId, reason} = request.data;

    if (!submissionId || typeof submissionId !== "string") {
      throw new HttpsError("invalid-argument", "submissionId is required");
    }

    const db = admin.firestore();
    const submissionRef = db.collection("submissions").doc(submissionId);

    try {
      const submissionDoc = await submissionRef.get();

      if (!submissionDoc.exists) {
        throw new HttpsError(
          "not-found",
          `Submission ${submissionId} not found`
        );
      }

      const submission = submissionDoc.data() as SubmissionData;

      if (submission.status !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          `Submission status is ${submission.status}, expected pending`
        );
      }

      // Update submission status to rejected
      await submissionRef.update({
        status: "rejected",
        moderatorId: request.auth?.uid || "unknown",
        moderatorNote: reason || "No reason provided",
        moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info("Submission rejected", {
        submissionId,
        moderatorId: request.auth?.uid,
        reason,
      });

      return {
        success: true,
        message: "Submission rejected",
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      logger.error("Error rejecting submission", {
        submissionId,
        error,
      });
      throw new HttpsError("internal", "Failed to reject submission");
    }
  }
);

/**
 * Infer metro from submission data (city/state)
 * Falls back to 'slc' if cannot determine
 */
function inferMetroFromSubmission(submission: SubmissionData): string {
  const state = submission.state.toLowerCase();
  const city = submission.city.toLowerCase();

  // Simple inference based on state/city
  if (state === "ut" || city.includes("salt lake")) {
    return "slc";
  }

  if (state === "ny" || city.includes("new york")) {
    return "nyc";
  }

  if (state === "sc" ||
      city.includes("greenville") ||
      city.includes("spartanburg")) {
    return "gsp";
  }

  // Default fallback
  logger.warn("Could not infer metro from submission", {
    submissionId: submission.id,
    city: submission.city,
    state: submission.state,
  });
  return "slc";
}
