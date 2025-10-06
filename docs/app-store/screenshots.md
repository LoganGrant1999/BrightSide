# App Store Screenshots Guide

Complete guide for capturing and preparing App Store screenshots for BrightSide.

---

## Required Screenshot Sizes

### iPhone (Required)
- **6.7" Display** (iPhone 14 Pro Max, 15 Pro Max, etc.)
  - Resolution: 1290 x 2796 pixels
  - Device: iPhone 15 Pro Max, iPhone 14 Pro Max
- **6.5" Display** (iPhone 11 Pro Max, XS Max, etc.)
  - Resolution: 1242 x 2688 pixels
  - Device: iPhone 11 Pro Max, iPhone XS Max

### iPad (If Universal App)
- **12.9" Display** (iPad Pro 12.9-inch)
  - Resolution: 2048 x 2732 pixels
- **13" Display** (iPad Pro 13-inch)
  - Resolution: 2064 x 2752 pixels

**Note:** BrightSide is currently iPhone-only, so iPad screenshots are optional.

---

## Screenshot Strategy

### Set of 5 Screenshots (Order Matters!)

Apple displays the first 3 screenshots in search results, so prioritize the most compelling screens.

**Recommended Order:**

1. **Today Feed** - Hero screen showing 5 curated positive stories
2. **Story Detail** - Single story with image, headline, source
3. **Popular Tab** - Trending stories across the metro
4. **Submit Flow** - Community story submission (shows engagement)
5. **Settings/Metro Selection** - Personalization and privacy features

---

## Screenshot Specifications

### Today Feed (Screenshot 1)
**Purpose:** Show core value proposition—curated positive news

**Screen State:**
- Display: Today feed with 5 stories loaded
- Metro: Salt Lake City (UT) or New York City (NY)
- Stories: Mix of categories (community, environment, health, education)
- Time: Show "Today" badge clearly visible
- Status bar: Clean (use simulator or hide sensitive info)

**Caption (Optional but Recommended):**
"5 Uplifting Stories Curated Daily for Your Community"

**Checklist:**
- [ ] All 5 story cards visible (may require scrolling composite)
- [ ] Clear story images loaded
- [ ] Metro name visible in navigation
- [ ] "Today" badge or timestamp visible
- [ ] No loading states or errors

---

### Story Detail (Screenshot 2)
**Purpose:** Show content quality and readability

**Screen State:**
- Display: Single story detail page
- Story: High-quality image with positive headline
- Content: First 2-3 paragraphs visible
- Source: News source attribution visible
- Action: "Read Full Article" button or sharing options

**Caption:**
"Read Full Stories from Trusted Local Sources"

**Checklist:**
- [ ] Hero image fully loaded and high quality
- [ ] Headline clear and positive
- [ ] Source attribution visible
- [ ] First paragraph readable
- [ ] No truncation or layout issues

---

### Popular Tab (Screenshot 3)
**Purpose:** Show community engagement and social proof

**Screen State:**
- Display: Popular tab with trending stories
- Stories: Mix of recent popular content
- Engagement: Vote counts or engagement indicators visible
- Metro: Same metro as Screenshot 1 for consistency

**Caption:**
"Discover What's Uplifting Your Community"

**Checklist:**
- [ ] Multiple popular stories visible
- [ ] Engagement metrics clear
- [ ] Tab bar shows "Popular" selected
- [ ] Stories are diverse (not all same category)

---

### Submit Flow (Screenshot 4)
**Purpose:** Show user engagement and community-driven content

**Screen State:**
- Display: Submit story screen with form partially filled
- Fields: URL, headline preview, optional notes
- UI: Clean form with clear CTA ("Submit for Review")
- Context: Shows user can contribute

**Caption:**
"Share Good News from Your Neighborhood"

**Checklist:**
- [ ] Form fields clearly labeled
- [ ] Example URL or headline shown (fake/demo data okay)
- [ ] Submit button visible
- [ ] Tab bar shows "Submit" selected
- [ ] No keyboard obstructing key UI

---

### Settings/Metro Selection (Screenshot 5)
**Purpose:** Show personalization, privacy, and metro options

**Screen State:**
- Display: Settings screen showing metro selection or notification preferences
- Options: Metro list (SLC, NYC, GSP) or notification toggle
- Privacy: Link to Privacy Policy visible
- Version: App version shown (optional)

**Caption:**
"Personalize Your Experience with Privacy in Mind"

**Checklist:**
- [ ] Key settings options visible (metro, notifications)
- [ ] Privacy Policy link visible
- [ ] Clean, organized layout
- [ ] User profile or account info (if shown)

---

## Manual Screenshot Capture

### Using iOS Simulator

1. **Launch Simulator**
   ```bash
   open -a Simulator
   ```

2. **Select Device**
   - iPhone 15 Pro Max (6.7" for 1290x2796)
   - iPhone 11 Pro Max (6.5" for 1242x2688)

3. **Run App**
   ```bash
   flutter run -d <simulator-id>
   ```

4. **Prepare Screen State**
   - Navigate to desired screen
   - Ensure data loaded correctly
   - Hide any dev/debug UI elements

5. **Capture Screenshot**
   - Method 1: `Cmd + S` (saves to Desktop)
   - Method 2: Device menu → Screenshot

6. **Verify Dimensions**
   ```bash
   sidentify -format "%wx%h" screenshot.png
   ```

### Using Physical Device

1. **Connect Device** (iPhone 14 Pro Max or newer recommended)

2. **Run App**
   ```bash
   flutter run
   ```

3. **Capture Screenshot**
   - Press `Volume Up + Side Button` simultaneously
   - Screenshot saves to Photos app

4. **Transfer to Mac**
   - AirDrop, iCloud Photos, or cable transfer
   - Download at full resolution (not compressed)

5. **Verify Dimensions**
   - Check in Preview → Tools → Adjust Size

---

## Screenshot Best Practices

### Content Guidelines
- ✅ Use real, positive content (not lorem ipsum)
- ✅ Show fully loaded states (no loading spinners)
- ✅ Use high-quality story images
- ✅ Ensure text is readable (good contrast)
- ✅ Hide any beta/dev indicators
- ❌ No user personal info (use demo account)
- ❌ No copyrighted images without permission
- ❌ No offensive or controversial content

### Technical Guidelines
- ✅ Exact pixel dimensions required (use correct simulator)
- ✅ PNG format (no JPG compression artifacts)
- ✅ RGB color space (not CMYK)
- ✅ No transparency (opaque background)
- ✅ Clean status bar (hide if necessary)
- ❌ No added borders, frames, or device mockups in screenshot itself
- ❌ No text overlays in the screenshot (use captions instead)

### Design Guidelines
- ✅ Consistent theme across all screenshots (light or dark mode)
- ✅ Same metro across all screenshots (for consistency)
- ✅ Portrait orientation only
- ✅ Fill entire screen (no letterboxing)
- ✅ Show app in best light (use appealing content)

---

## Optional: Adding Captions/Overlays

### Using Apple's Screenshots Feature
Apple allows text captions directly in App Store Connect. **Recommended approach.**

**Pros:**
- Easy to update without re-uploading images
- Localized captions for different languages
- Clean, Apple-approved format

**Cons:**
- Limited formatting options

### Using External Tools (Advanced)
If you want custom overlays, device frames, or marketing text:

**Tools:**
- **Figma** - Design custom screenshot layouts
- **Sketch** - macOS design tool
- **Canva** - Web-based graphic design
- **screenshots.pro** - Automated screenshot framing

**⚠️ Warning:** Custom overlays must NOT be misleading. Screenshot must accurately represent actual app UI.

---

## Automation with Fastlane (Optional)

For repeatable screenshot generation across app updates.

### Setup

1. **Install Fastlane**
   ```bash
   sudo gem install fastlane
   cd ios
   fastlane init
   ```

2. **Install Snapshot Plugin**
   ```bash
   fastlane add_plugin snapshot
   ```

3. **Create UI Test Target** (in Xcode)
   - File → New → Target → UI Testing Bundle
   - Name: `BrightSideUITests`

4. **Configure Snapfile**
   ```ruby
   # ios/fastlane/Snapfile
   devices([
     "iPhone 15 Pro Max",
     "iPhone 11 Pro Max"
   ])

   languages(["en-US"])

   scheme("BrightSide")

   output_directory("./screenshots")

   clear_previous_screenshots(true)
   ```

5. **Write UI Tests**
   ```swift
   // ios/BrightSideUITests/ScreenshotTests.swift
   import XCTest

   class ScreenshotTests: XCTestCase {
       override func setUp() {
           super.setUp()
           let app = XCUIApplication()
           setupSnapshot(app)
           app.launch()
       }

       func testTodayFeed() {
           let app = XCUIApplication()
           // Navigate to Today tab
           app.tabBars.buttons["Today"].tap()
           sleep(2) // Wait for load
           snapshot("01-Today-Feed")
       }

       func testStoryDetail() {
           let app = XCUIApplication()
           app.tabBars.buttons["Today"].tap()
           app.collectionViews.cells.firstMatch.tap()
           sleep(2)
           snapshot("02-Story-Detail")
       }

       func testPopularTab() {
           let app = XCUIApplication()
           app.tabBars.buttons["Popular"].tap()
           sleep(2)
           snapshot("03-Popular-Tab")
       }

       func testSubmitFlow() {
           let app = XCUIApplication()
           app.tabBars.buttons["Submit"].tap()
           sleep(1)
           snapshot("04-Submit-Flow")
       }

       func testSettings() {
           let app = XCUIApplication()
           app.tabBars.buttons["Settings"].tap()
           sleep(1)
           snapshot("05-Settings")
       }
   }
   ```

6. **Run Snapshot**
   ```bash
   cd ios
   fastlane snapshot
   ```

7. **Output**
   - Screenshots saved to `ios/screenshots/en-US/`
   - Organized by device type automatically

### Pros of Fastlane Automation
- ✅ Repeatable across updates
- ✅ Generate for all devices at once
- ✅ Version controlled test scripts
- ✅ Integrate with CI/CD

### Cons
- ❌ Initial setup time
- ❌ Requires UI tests maintenance
- ❌ May need mock data setup

---

## Uploading to App Store Connect

### Via Web Interface

1. **Log in to App Store Connect**
   - https://appstoreconnect.apple.com

2. **Navigate to App**
   - My Apps → BrightSide → App Store tab

3. **Select Version**
   - Choose version (e.g., 1.0.0)

4. **Upload Screenshots**
   - Scroll to "App Previews and Screenshots"
   - Select device size (6.7" Display, 6.5" Display)
   - Drag & drop PNG files in order
   - Add captions (optional but recommended)

5. **Reorder if Needed**
   - Drag to reorder (first 3 show in search results)

6. **Save**

### Via Fastlane (Advanced)

```bash
# ios/fastlane/Deliverfile
app_identifier("com.brightside.app")
username("your-apple-id@example.com")

screenshots_path("./screenshots")
```

**Upload:**
```bash
fastlane deliver --skip_binary_upload --skip_metadata
```

---

## Localization (Future)

If you plan to support multiple languages:

1. **Capture Screenshots per Language**
   - Change device language in simulator
   - Re-run screenshot process
   - Ensure in-app text is localized

2. **Upload to App Store Connect**
   - Each language has separate screenshot section
   - Can reuse English screenshots if UI isn't localized

3. **Localized Captions**
   - Write captions in each supported language
   - Keep messaging consistent across languages

---

## Quality Checklist

Before uploading to App Store Connect:

- [ ] All 5 screenshots captured for each required device size
- [ ] Exact dimensions verified (1290x2796 for 6.7", 1242x2688 for 6.5")
- [ ] PNG format, RGB color space
- [ ] No personal data, offensive content, or errors visible
- [ ] Fully loaded states (no spinners, no "no data" messages)
- [ ] Consistent theme (all light mode or all dark mode)
- [ ] High-quality story images used
- [ ] Text is readable (good contrast)
- [ ] Status bar clean (or hidden if necessary)
- [ ] Screenshots show actual app functionality (no mockups)
- [ ] First 3 screenshots are most compelling
- [ ] Captions written (optional but recommended)
- [ ] Reviewed on multiple screen sizes for clarity

---

## Tips for Great Screenshots

1. **Tell a Story**
   - Order screenshots to show user journey: Today → Detail → Popular → Submit → Settings

2. **Show Value, Not Just Features**
   - Screenshot 1 should immediately communicate "positive, curated news"

3. **Use Real Content**
   - Real headlines and images are more compelling than placeholders

4. **Highlight Differentiation**
   - Emphasize what makes BrightSide different (curation, positivity, local focus)

5. **Keep It Simple**
   - Don't overcrowd with too much UI—let key elements breathe

6. **Test on Target Audience**
   - Show screenshots to potential users; get feedback on clarity and appeal

7. **Update with Major Releases**
   - If UI changes significantly in v2.0, update screenshots to match

---

## Common Mistakes to Avoid

❌ **Wrong Dimensions** - App Store Connect will reject incorrect sizes
❌ **Low-Quality Images** - Blurry or pixelated screenshots hurt conversion
❌ **Misleading UI** - Showing features that don't exist will get rejected
❌ **Empty States** - Don't show "No stories found" or loading spinners
❌ **Inconsistent Style** - Mix of light/dark mode or different metros looks unprofessional
❌ **Too Much Text Overlay** - Screenshots should show the app, not marketing copy
❌ **Personal Data** - Never show real user emails, names, or sensitive info
❌ **Unpolished UI** - Fix any visual bugs or misalignments before capturing

---

## Contact

**For screenshot questions or automation help:**
support@brightside.com

**For Fastlane/automation setup:**
See fastlane docs: https://docs.fastlane.tools/actions/snapshot/

---

**Last Updated:** 2025-01-06
**Version:** 1.0.0
**Status:** Ready for Use
