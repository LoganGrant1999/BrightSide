"use strict";
/**
 * Positivity Filter
 * Filters news items to keep only positive/uplifting stories
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
exports.keepPositive = keepPositive;
exports.scorePositivity = scorePositivity;
exports.getTopPositive = getTopPositive;
const logger = __importStar(require("firebase-functions/logger"));
// Blocklist: Keywords indicating negative/controversial content
const BLOCKLIST_KEYWORDS = [
    // Crime & Violence
    "murder",
    "kill",
    "shot",
    "shooting",
    "assault",
    "attack",
    "robbery",
    "stabbing",
    "dead",
    "death",
    "homicide",
    "crime",
    "arrest",
    "charged",
    // Politics & Controversy
    "trump",
    "biden",
    "election",
    "vote",
    "congress",
    "senate",
    "political",
    "protest",
    "riot",
    "impeach",
    // Disasters & Accidents
    "crash",
    "accident",
    "fire",
    "explosion",
    "disaster",
    "emergency",
    "fatal",
    "died",
    "injured",
    "victim",
    // War & Conflict
    "war",
    "terror",
    "bomb",
    "military",
    "invasion",
    "conflict",
    "strike",
    // Negative General
    "scandal",
    "lawsuit",
    "sue",
    "fraud",
    "abuse",
    "crisis",
    "threat",
];
// Allowlist: Keywords indicating positive content
const ALLOWLIST_KEYWORDS = [
    // Community & Achievement
    "community",
    "volunteer",
    "hero",
    "helping",
    "kindness",
    "charity",
    "donation",
    "fundraiser",
    "support",
    "award",
    "honor",
    "celebrate",
    "achievement",
    "success",
    // Environment & Nature
    "clean",
    "green",
    "solar",
    "park",
    "garden",
    "nature",
    "conservation",
    "wildlife",
    "rescued",
    "saved",
    // Innovation & Progress
    "innovation",
    "breakthrough",
    "develop",
    "improve",
    "new program",
    "initiative",
    "project",
    "opens",
    "launch",
    // Arts & Culture
    "art",
    "museum",
    "festival",
    "music",
    "culture",
    "theater",
    "exhibit",
    // Education & Youth
    "student",
    "school",
    "education",
    "graduate",
    "scholarship",
    "learning",
    // Health & Wellness
    "health",
    "wellness",
    "recovery",
    "miracle",
    "survivor",
];
/**
 * Check if text contains any blocked keywords
 */
function containsBlockedContent(text) {
    const lowerText = text.toLowerCase();
    return BLOCKLIST_KEYWORDS.some((keyword) => lowerText.includes(keyword));
}
/**
 * Check if text contains positive keywords
 */
function containsPositiveContent(text) {
    const lowerText = text.toLowerCase();
    return ALLOWLIST_KEYWORDS.some((keyword) => lowerText.includes(keyword));
}
/**
 * Filter RSS items to keep only positive stories
 * @param items - Array of RSS items
 * @returns Filtered array of positive items
 */
function keepPositive(items) {
    const filtered = [];
    for (const item of items) {
        const textToCheck = `${item.title} ${item.summary || ""}`;
        // Skip if contains blocked content
        if (containsBlockedContent(textToCheck)) {
            logger.debug(`Filtered out (blocked): ${item.title}`);
            continue;
        }
        // Keep if contains positive keywords OR has no negative content
        // (Some positive stories might not match keywords exactly)
        const hasPositive = containsPositiveContent(textToCheck);
        if (hasPositive) {
            filtered.push(item);
            logger.debug(`Kept (positive match): ${item.title}`);
        }
        else {
            // Neutral content - keep with lower priority
            // This allows general news that's not negative but might not be explicitly positive
            logger.debug(`Kept (neutral): ${item.title}`);
            filtered.push(item);
        }
    }
    logger.info(`Positivity filter: ${filtered.length}/${items.length} items kept`);
    return filtered;
}
/**
 * Score item positivity (higher is better)
 * Used for prioritization when we have too many items
 */
function scorePositivity(item) {
    const text = `${item.title} ${item.summary || ""}`.toLowerCase();
    let score = 0;
    // Add points for positive keywords
    for (const keyword of ALLOWLIST_KEYWORDS) {
        if (text.includes(keyword)) {
            score += 2;
        }
    }
    // Subtract points for any near-negative keywords (softer blocklist)
    const softBlocklist = ["concern", "worry", "problem", "issue", "fail"];
    for (const keyword of softBlocklist) {
        if (text.includes(keyword)) {
            score -= 1;
        }
    }
    return Math.max(0, score); // Never negative
}
/**
 * Get top N items by positivity score
 */
function getTopPositive(items, limit) {
    return items
        .map((item) => ({
        item,
        score: scorePositivity(item),
    }))
        .sort((a, b) => b.score - a.score)
        .slice(0, limit)
        .map((x) => x.item);
}
//# sourceMappingURL=positivity_filter.js.map