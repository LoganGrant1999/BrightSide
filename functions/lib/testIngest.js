"use strict";
/**
 * Manual Test Trigger for RSS Ingestion
 * HTTP endpoint to manually trigger ingestion for testing
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
exports.testIngest = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const runIngest_1 = require("./ingest/runIngest");
/**
 * HTTP function: Manual trigger for testing ingestion
 * Usage: GET /testIngest?metro=slc
 */
exports.testIngest = (0, https_1.onRequest)(async (req, res) => {
    const metroId = req.query.metro;
    if (!["slc", "nyc", "gsp"].includes(metroId)) {
        res.status(400).send("Invalid metro. Must be slc, nyc, or gsp");
        return;
    }
    try {
        logger.info(`Manual ingestion triggered for: ${metroId}`);
        const count = await (0, runIngest_1.runIngest)(metroId);
        res.status(200).json({
            success: true,
            metro: metroId,
            articlesIngested: count,
            message: `Successfully ingested ${count} articles for ${metroId}`,
        });
    }
    catch (error) {
        logger.error(`Manual ingestion failed for ${metroId}:`, error);
        res.status(500).json({
            success: false,
            metro: metroId,
            error: String(error),
        });
    }
});
//# sourceMappingURL=testIngest.js.map