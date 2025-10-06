"use strict";
/**
 * Health monitoring for scheduled functions
 * Writes heartbeat timestamps to /system/health/{metroId}
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
exports.recordIngestHealth = recordIngestHealth;
exports.recordDigestHealth = recordDigestHealth;
exports.recordFeaturedRotationHealth = recordFeaturedRotationHealth;
const admin = __importStar(require("firebase-admin"));
const logger = __importStar(require("firebase-functions/logger"));
const db = admin.firestore();
/**
 * Record successful ingest run for a metro
 */
async function recordIngestHealth(metroId) {
    try {
        await db.collection("system").doc("health").set({
            [metroId]: {
                lastIngestAt: admin.firestore.FieldValue.serverTimestamp(),
                status: "ok",
            },
        }, { merge: true });
        logger.info(`Health ping recorded for ${metroId} ingest`);
    }
    catch (error) {
        logger.error(`Failed to record health ping for ${metroId}:`, error);
    }
}
/**
 * Record successful digest run for a metro
 */
async function recordDigestHealth(metroId) {
    try {
        await db.collection("system").doc("health").set({
            [metroId]: {
                lastDigestAt: admin.firestore.FieldValue.serverTimestamp(),
                status: "ok",
            },
        }, { merge: true });
        logger.info(`Health ping recorded for ${metroId} digest`);
    }
    catch (error) {
        logger.error(`Failed to record health ping for ${metroId}:`, error);
    }
}
/**
 * Record featured rotation health
 */
async function recordFeaturedRotationHealth() {
    try {
        await db.collection("system").doc("health").set({
            featured: {
                lastRotationAt: admin.firestore.FieldValue.serverTimestamp(),
                status: "ok",
            },
        }, { merge: true });
        logger.info("Health ping recorded for featured rotation");
    }
    catch (error) {
        logger.error("Failed to record health ping for featured rotation:", error);
    }
}
//# sourceMappingURL=health.js.map