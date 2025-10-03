"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatDateYYYYMMDD = formatDateYYYYMMDD;
exports.getUTCHourForLocalTime = getUTCHourForLocalTime;
exports.get24HoursAgo = get24HoursAgo;
/**
 * Format a Date as YYYYMMDD string
 */
function formatDateYYYYMMDD(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}${month}${day}`;
}
/**
 * Convert UTC Date to local date in a specific timezone
 * For cron scheduling - e.g., "05:00 America/Denver" → UTC offset
 */
function getUTCHourForLocalTime(localHour, timezone) {
    // Simple implementation - for production, use a library like date-fns-tz
    const tzOffsets = {
        "America/Denver": -7, // MST (adjust for DST as needed)
        "America/New_York": -5, // EST
        "America/Chicago": -6, // CST
    };
    const offset = tzOffsets[timezone] || 0;
    return (localHour - offset + 24) % 24;
}
/**
 * Get timestamp for 24 hours ago
 */
function get24HoursAgo() {
    const now = new Date();
    return new Date(now.getTime() - 24 * 60 * 60 * 1000);
}
//# sourceMappingURL=time.js.map