# BrightSide Pre-Flight Summary

Quick reference for final verification before App Store submission.

---

## 🚀 Quick Start

### 1. Environment Check (2 minutes)
```bash
# Run environment verification
npx ts-node tool/print_env_check.ts
```

**Expected:**
- ✅ Environment: PRODUCTION
- ✅ Project ID: brightside-9a2c5
- ✅ Legal URLs accessible
- ✅ Health checks recent (<24h)
- ✅ Stories available (all metros)

### 2. Full Preflight (4-6 hours)
Follow comprehensive checklist: `docs/checklists/preflight.md`

---

## 📋 Critical Path Verification

### Must Pass (30 minutes)

1. **Onboarding**
   - [ ] Fresh install → metro selection works
   - [ ] Location allow → correct metro detected
   - [ ] Location deny → manual picker works

2. **Authentication**
   - [ ] Google sign-in works
   - [ ] Apple sign-in works
   - [ ] Email sign-in works
   - [ ] Session persists across app restarts

3. **Today Feed**
   - [ ] 5 stories appear (or max available)
   - [ ] All images load
   - [ ] Tap story → detail opens
   - [ ] "Read Full Article" → browser opens

4. **Submit → Approve → Publish**
   - [ ] Submit story from app
   - [ ] Approve in admin portal
   - [ ] Story appears in Today feed

5. **Notifications**
   - [ ] Soft-ask after first feed view
   - [ ] Test notification works (dev mode)
   - [ ] Notification tap → app opens

6. **Account Deletion**
   - [ ] Delete account → cascade works
   - [ ] All user data removed

7. **Legal & Permissions**
   - [ ] Privacy Policy link opens
   - [ ] Terms of Service link opens
   - [ ] Location permission string correct
   - [ ] Notification permission string correct

---

## 🔧 Environment Check Tool

**Location:** `tool/print_env_check.ts`

**What it checks:**
```
📦 Environment (dev vs prod)
🔥 Firebase configuration
⚙️  System config (legal URLs, support email, maintenance mode)
🏥 Health checks (last ingest/digest per metro)
📰 Content status (published stories per metro)
⚠️  Warnings & recommendations
```

**Usage:**
```bash
# Production check
npx ts-node tool/print_env_check.ts

# Development/emulator check
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/print_env_check.ts
```

---

## 📝 Full Checklist

**Location:** `docs/checklists/preflight.md`

**Sections (15 total):**
1. Onboarding Flow
2. Authentication
3. Today Feed
4. Popular Feed
5. Submit Flow
6. Likes & Featured Stories
7. Offline Caching & Error Handling
8. Notifications
9. Account Deletion
10. Legal Links & Permissions
11. Performance & Polish
12. Cross-Device & Cross-Platform
13. Security & Privacy
14. App Store Compliance
15. Final Verification

---

## ⚡ Pre-Build Checklist (5 minutes)

### Code
- [ ] `flutter analyze` → no errors
- [ ] Version incremented (pubspec.yaml)
- [ ] Build number incremented

### Firebase
- [ ] System config seeded
- [ ] Legal URLs work
- [ ] APNs key configured
- [ ] Security rules deployed

### Release Build
```bash
flutter build ios --release -t lib/main_prod.dart
```

- [ ] Build succeeds
- [ ] No debug menu in Settings
- [ ] Test on physical device

---

## 🐛 Issue Severity

**P0 - Critical (Block Release):**
- Crashes, data loss, security issues, core features broken

**P1 - High (Fix Before Ship):**
- Major bugs in primary flows

**P2 - Medium (Fix If Time):**
- Minor bugs, UX issues

**P3 - Low (Defer):**
- Polish, edge cases

---

## 📞 Support

**Documentation:**
- Full preflight: `docs/checklists/preflight.md`
- Checklists index: `docs/checklists/README.md`
- Release checklist: `docs/RELEASE_CHECKLIST.md`
- App Store metadata: `docs/app-store/metadata.md`

**Contact:**
support@brightside.com

---

**Last Updated:** 2025-01-06  
**Version:** 1.0.0
