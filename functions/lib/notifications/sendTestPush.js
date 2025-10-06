"use strict";
/**
 * Send Test Push Notification
 *
 * Sends a test notification to the current user's registered devices.
 * Useful for testing APNs/FCM configuration and device token registration.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendTestPush = void 0;
const admin = __importStar(require("firebase-admin"));
const logger = __importStar(require("firebase-functions/logger"));
const https_1 = require("firebase-functions/v2/https");
exports.sendTestPush = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    const db = admin.firestore();
    const messaging = admin.messaging();
    // Get caller UID
    const callerUid = request.auth?.uid;
    if (!callerUid) {
        throw new https_1.HttpsError("unauthenticated", "User must be signed in");
    }
    // Determine target user
    let targetUid = callerUid;
    // If targeting another user, check admin permission
    if (request.data?.targetUid) {
        const isAdmin = request.auth?.token?.admin === true;
        if (!isAdmin) {
            throw new https_1.HttpsError("permission-denied", "Only admins can send test push to other users");
        }
        targetUid = request.data.targetUid;
    }
    logger.info(`Sending test push to user: ${targetUid}`);
    try {
        // Get user's device tokens
        const devicesSnapshot = await db
            .collection("users")
            .doc(targetUid)
            .collection("devices")
            .get();
        if (devicesSnapshot.empty) {
            logger.warn(`No devices found for user: ${targetUid}`);
            return {
                success: false,
                message: "No devices registered for this user",
                deviceCount: 0,
            };
        }
        const tokens = [];
        devicesSnapshot.forEach((doc) => {
            const data = doc.data();
            if (data.fcm_token) {
                tokens.push(data.fcm_token);
            }
        });
        if (tokens.length === 0) {
            logger.warn(`No FCM tokens found for user: ${targetUid}`);
            return {
                success: false,
                message: "No valid FCM tokens found",
                deviceCount: devicesSnapshot.size,
            };
        }
        logger.info(`Found ${tokens.length} FCM token(s) for user: ${targetUid}`);
        // Get user info for personalization
        const userDoc = await db.collection("users").doc(targetUid).get();
        const userData = userDoc.data();
        const userName = userData?.display_name || "there";
        const chosenMetro = userData?.chosen_metro || "your area";
        // Build notification message
        const message = {
            tokens,
            notification: {
                title: "🧪 BrightSide Test Notification",
                body: `Hey ${userName}! Your notifications are working perfectly. ✓`,
            },
            data: {
                type: "test_notification",
                metro_id: chosenMetro,
                test: "true",
                timestamp: Date.now().toString(),
            },
            apns: {
                headers: {
                    "apns-priority": "10",
                },
                payload: {
                    aps: {
                        alert: {
                            title: "🧪 BrightSide Test Notification",
                            body: `Hey ${userName}! Your notifications are working perfectly. ✓`,
                        },
                        sound: "default",
                        badge: 1,
                    },
                },
            },
            android: {
                priority: "high",
                notification: {
                    channelId: "daily_digest",
                    sound: "default",
                    priority: "high",
                },
            },
        };
        // Send notification
        const response = await messaging.sendEachForMulticast(message);
        logger.info(`Test push sent: ${response.successCount}/${tokens.length} successful`);
        // Log failures
        if (response.failureCount > 0) {
            response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                    logger.error(`Failed to send to token ${idx}:`, resp.error);
                }
            });
        }
        return {
            success: true,
            message: "Test notification sent",
            deviceCount: tokens.length,
            successCount: response.successCount,
            failureCount: response.failureCount,
            tokens: tokens.map((t) => `${t.substring(0, 20)}...`),
        };
    }
    catch (error) {
        logger.error("Error sending test push:", error);
        throw new https_1.HttpsError("internal", `Failed to send test push: ${error.message}`);
    }
});
//# sourceMappingURL=sendTestPush.js.map