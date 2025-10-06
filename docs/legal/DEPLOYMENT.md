# Legal Documents Deployment Guide

Guide for deploying and updating BrightSide legal documents (Privacy Policy and Terms of Service).

---

## Overview

Legal documents are:
- Stored as **Markdown** in `docs/legal/`
- Converted to **HTML** using Python script
- Hosted on **Firebase Hosting** at `/legal/`
- Referenced in **Settings** screen and `/system/config` Firestore document

---

## File Structure

```
brightside/
├── docs/legal/
│   ├── privacy_policy.md          # Privacy Policy (markdown source)
│   ├── terms_of_service.md        # Terms of Service (markdown source)
│   └── DEPLOYMENT.md               # This file
├── legal-web/
│   ├── index.html                  # Legal landing page
│   ├── privacy.html                # Privacy Policy (generated HTML)
│   └── terms.html                  # Terms of Service (generated HTML)
└── tool/
    └── convert_legal_to_html.py    # Markdown → HTML converter
```

---

## Updating Legal Documents

### Step 1: Edit Markdown Files

Edit the source markdown files:

```bash
# Edit Privacy Policy
code docs/legal/privacy_policy.md

# Edit Terms of Service
code docs/legal/terms_of_service.md
```

**Important Updates:**
- Change "Effective Date" and "Last Updated" dates
- Update contact email if needed
- Modify data collection details as app evolves
- Add new sections as required by law

### Step 2: Convert to HTML

Run the conversion script:

```bash
# Install markdown library (first time only)
pip install markdown

# Convert markdown to HTML
python3 tool/convert_legal_to_html.py
```

**Output:**
```
Converting legal documents to HTML...

Converting privacy_policy.md → privacy.html...
✓ Generated privacy.html
Converting terms_of_service.md → terms.html...
✓ Generated terms.html

✅ HTML generation complete!
```

### Step 3: Review Generated HTML

Open the generated files in a browser:

```bash
# macOS
open legal-web/privacy.html
open legal-web/terms.html

# Linux
xdg-open legal-web/privacy.html
xdg-open legal-web/terms.html
```

**Check for:**
- Proper formatting
- Working links
- Correct dates
- No HTML rendering issues

### Step 4: Deploy to Firebase Hosting

Deploy the legal site:

```bash
# Deploy to production
firebase use prod
firebase deploy --only hosting:legal

# Deploy to development (for testing)
firebase use dev
firebase deploy --only hosting:legal
```

**Expected output:**
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/brightside-9a2c5/overview
Hosting URL: https://brightside-9a2c5.web.app
```

### Step 5: Test Public URLs

Visit the deployed URLs:

**Production:**
- https://brightside-9a2c5.web.app/legal/
- https://brightside-9a2c5.web.app/legal/privacy
- https://brightside-9a2c5.web.app/legal/terms

**Development:**
- https://brightside-dev.web.app/legal/
- https://brightside-dev.web.app/legal/privacy
- https://brightside-dev.web.app/legal/terms

### Step 6: Update System Config

If URLs have changed (e.g., custom domain), update the system config:

```bash
# Edit the seed script
code tool/seed_system_config.ts

# Update privacy_policy_url and terms_of_service_url
# Then run:
npx ts-node tool/seed_system_config.ts
```

### Step 7: Test in App

1. Run the Flutter app (dev or prod)
2. Go to **Settings** → **Privacy Policy** / **Terms of Service**
3. Tap links and verify they open correctly
4. Verify URLs load in external browser

---

## Firebase Hosting Configuration

### firebase.json

```json
{
  "hosting": [
    {
      "target": "legal",
      "public": "legal-web",
      "ignore": ["firebase.json", "**/.*"],
      "cleanUrls": true,
      "headers": [
        {
          "source": "**/*.@(html|css|js)",
          "headers": [
            {
              "key": "Cache-Control",
              "value": "public, max-age=3600"
            }
          ]
        }
      ]
    }
  ]
}
```

### .firebaserc

```json
{
  "targets": {
    "brightside-9a2c5": {
      "hosting": {
        "legal": ["brightside-9a2c5"]
      }
    }
  }
}
```

---

## Custom Domain Setup (Optional)

To host legal docs at `https://legal.brightside.com`:

### Step 1: Add Custom Domain in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project → **Hosting**
3. Click **Add custom domain**
4. Enter: `legal.brightside.com`

### Step 2: Update DNS Records

Add DNS records provided by Firebase (example):

```
Type: A
Name: legal
Value: 151.101.1.195

Type: A
Name: legal
Value: 151.101.65.195
```

### Step 3: Wait for SSL Provisioning

SSL certificate provisioning can take up to 24 hours.

### Step 4: Update System Config

```typescript
const systemConfig = {
  privacy_policy_url: 'https://legal.brightside.com/privacy',
  terms_of_service_url: 'https://legal.brightside.com/terms',
  // ...
};
```

### Step 5: Redeploy

```bash
# Update system config
npx ts-node tool/seed_system_config.ts

# Deploy legal site
firebase deploy --only hosting:legal
```

---

## App Store Connect Requirements

### Privacy Policy URL

When submitting to App Store Connect, you'll need to provide:

**Field:** Privacy Policy URL
**Value:** `https://brightside-9a2c5.web.app/legal/privacy`

**Or with custom domain:**
**Value:** `https://legal.brightside.com/privacy`

### Terms of Service (EULA)

**Field:** End User License Agreement (EULA)
**Value:** `https://brightside-9a2c5.web.app/legal/terms`

**Note:** Apple may require specific EULA formatting. Review their guidelines.

---

## Compliance Checklist

Before App Store submission:

- [ ] Effective date is current
- [ ] Contact email is correct (`support@brightside.com`)
- [ ] All data collection is accurately described
- [ ] Third-party services are listed (Firebase, Apple, Google)
- [ ] User rights are clearly stated (deletion, access, portability)
- [ ] COPPA compliance (no data from children under 13)
- [ ] CCPA compliance (California privacy rights)
- [ ] GDPR compliance (European privacy rights)
- [ ] Links to third-party privacy policies are working
- [ ] HTML versions are deployed and accessible
- [ ] System config has correct URLs
- [ ] Settings screen opens correct URLs

---

## Legal Review

**Recommended:**
Consult with a lawyer before finalizing legal documents, especially for:
- App Store submission
- International markets (EU, California)
- Handling sensitive data
- User-generated content liability

**Disclaimer:** The provided templates are starting points. They are NOT legal advice. Consult a qualified attorney for your specific needs.

---

## Troubleshooting

### Issue: Links in Settings don't work

**Check:**
1. System config has correct URLs:
   ```bash
   # Check Firestore /system/config document
   ```
2. Firebase Hosting deployed:
   ```bash
   firebase deploy --only hosting:legal
   ```
3. URLs are publicly accessible (test in incognito browser)

### Issue: HTML looks broken

**Solution:**
1. Regenerate HTML:
   ```bash
   python3 tool/convert_legal_to_html.py
   ```
2. Check for markdown formatting errors
3. Test locally by opening HTML files in browser

### Issue: App Store rejects Privacy Policy

**Common Reasons:**
- URL not publicly accessible
- Privacy Policy missing required sections
- Data collection not fully disclosed
- Third-party services not listed

**Solution:**
Review [Apple's App Privacy Guidelines](https://developer.apple.com/app-store/app-privacy-details/)

---

## Quick Commands

```bash
# Edit legal docs
code docs/legal/privacy_policy.md
code docs/legal/terms_of_service.md

# Convert to HTML
python3 tool/convert_legal_to_html.py

# Deploy to production
firebase use prod
firebase deploy --only hosting:legal

# Test URLs
open https://brightside-9a2c5.web.app/legal/privacy
open https://brightside-9a2c5.web.app/legal/terms

# Update system config
npx ts-node tool/seed_system_config.ts

# Test in app
flutter run -t lib/main_dev.dart
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-01 | Initial privacy policy and terms of service |

---

**For questions or updates, contact:** support@brightside.com
