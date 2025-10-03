"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isAdmin = isAdmin;
/**
 * Check if user has admin privileges via custom claims
 */
function isAdmin(auth) {
    if (!auth)
        return false;
    return auth.admin === true;
}
//# sourceMappingURL=admin.js.map