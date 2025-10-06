# Icons & Branding Guide

Complete guide for BrightSide app icons, brand colors, and visual identity.

---

## Brand Colors

### Primary Color Palette

**Primary (Warm Yellow - Sun)**
- `#FFB800` - Main brand color
- `#FFD54F` - Light variant
- `#FFA000` - Dark variant

**Secondary (Blue Sky)**
- `#2196F3` - Secondary brand color
- `#64B5F6` - Light variant
- `#1976D2` - Dark variant

**Accent (Warm Orange)**
- `#FF6B35` - Accent color
- `#FF9966` - Light variant
- `#E64A19` - Dark variant

### Usage in Code

Import the brand colors:

```dart
import 'package:brightside/core/theme/brand_colors.dart';

// Use brand colors
Container(
  color: BrandColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: BrandColors.textPrimary),
  ),
)

// Use gradients
Container(
  decoration: BoxDecoration(
    gradient: BrandColors.primaryGradient,
  ),
)

// Use Material swatch
MaterialApp(
  theme: ThemeData(
    primarySwatch: BrandMaterialColors.primarySwatch,
  ),
)
```

### Semantic Colors

- **Success:** `#4CAF50` (Green)
- **Warning:** `#FFC107` (Amber)
- **Error:** `#F44336` (Red)
- **Info:** `#2196F3` (Blue)

---

## App Icons

### Icon Design

**Visual Elements:**
- **Sun circle** - Central element representing positivity
- **Radiating rays** - 12 rays symbolizing spreading good news
- **Color** - Warm yellow (#FFB800) on white background

**Design Principles:**
- Minimalist and friendly
- High contrast for visibility at small sizes
- Recognizable at a glance
- Consistent with brand identity

### Icon Sizes

The app icon is generated in all required iOS sizes:

**iPhone:**
- 20x20 @2x, @3x
- 29x29 @1x, @2x, @3x
- 40x40 @2x, @3x
- 60x60 @2x, @3x

**iPad:**
- 20x20 @1x, @2x
- 29x29 @1x, @2x
- 40x40 @1x, @2x
- 76x76 @1x, @2x
- 83.5x83.5 @2x

**App Store:**
- 1024x1024 @1x

---

## Generating Icons

### Prerequisites

1. Install Python 3 and PIL (Pillow):
   ```bash
   pip install pillow
   ```

2. Ensure `flutter_launcher_icons` package is in `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.14.1
   ```

### Generate Icons

**Method 1: Using Python Script (Recommended)**

```bash
# Generate source icon files
python3 tool/generate_app_icon.py

# Generate all iOS icon sizes
flutter pub run flutter_launcher_icons
```

**Method 2: Manual Creation**

1. Create `assets/icon/app_icon.png` (1024x1024)
   - White background
   - Sun in warm yellow (#FFB800)
   - Export as PNG

2. Run icon generator:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Verify Icons

**In Xcode:**
1. Open `ios/Runner.xcworkspace`
2. Navigate to `Runner` → `Assets.xcassets` → `AppIcon`
3. Verify all icon slots are filled
4. No warnings should appear

**On Device/Simulator:**
1. Build and run:
   ```bash
   flutter run -t lib/main_dev.dart
   ```
2. Check home screen for app icon
3. Verify icon appears correctly in app switcher

---

## Icon Configuration

### pubspec.yaml

```yaml
flutter_launcher_icons:
  android: false  # Android disabled for now
  ios: true
  image_path: "assets/icon/app_icon.png"
  remove_alpha_ios: true
```

### Assets Structure

```
assets/
└── icon/
    ├── app_icon.png              # 1024x1024 main icon
    ├── app_icon_foreground.png   # 1024x1024 adaptive (for future Android)
    └── README.md                 # Icon documentation
```

---

## Brand Identity Guidelines

### Logo Usage

**Proper Usage:**
- Use on white or light backgrounds
- Maintain minimum clear space around logo
- Don't distort or rotate
- Don't change colors

**Clear Space:**
- Minimum 20px padding on all sides
- Don't place text or other elements in clear space

### Typography

**Recommended Fonts:**
- **Headlines:** System default (SF Pro on iOS)
- **Body:** System default (SF Pro on iOS)
- **Monospace:** SF Mono (for code/data)

**Text Sizes:**
```dart
// In AppTheme
static const double textXSmall = 12.0;
static const double textSmall = 14.0;
static const double textMedium = 16.0;
static const double textLarge = 20.0;
static const double textXLarge = 24.0;
static const double textHero = 32.0;
```

### Spacing

**Padding:**
```dart
static const double paddingXSmall = 4.0;
static const double paddingSmall = 8.0;
static const double paddingMedium = 16.0;
static const double paddingLarge = 24.0;
static const double paddingXLarge = 32.0;
```

**Border Radius:**
```dart
static const double radiusSmall = 4.0;
static const double radiusMedium = 8.0;
static const double radiusLarge = 16.0;
```

---

## Updating Icons

### When to Update Icons

- Rebranding or visual refresh
- Platform requirement changes
- Design feedback from users
- App Store rejection due to icon issues

### Update Process

1. **Create new source icon:**
   ```bash
   python3 tool/generate_app_icon.py
   # OR manually create assets/icon/app_icon.png
   ```

2. **Regenerate all sizes:**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

3. **Test on devices:**
   ```bash
   flutter run -t lib/main_dev.dart
   flutter run -t lib/main_prod.dart --dart-define=PROD=true
   ```

4. **Commit changes:**
   ```bash
   git add assets/icon/
   git add ios/Runner/Assets.xcassets/AppIcon.appiconset/
   git commit -m "feat: update app icons"
   ```

---

## Troubleshooting

### Issue: Icons not showing after generation

**Solution:**
1. Clean build:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Rebuild app:
   ```bash
   flutter run
   ```

3. If still not showing, regenerate:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Issue: Xcode shows icon warnings

**Possible Causes:**
- Missing icon sizes
- Invalid image format
- Incorrect Contents.json

**Solution:**
1. Verify Contents.json in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
2. Regenerate icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Issue: App Store rejection due to icon

**Common Issues:**
- Icon contains transparency (not allowed)
- Icon is too simple or generic
- Icon misleads about app functionality

**Solution:**
1. Ensure `remove_alpha_ios: true` in pubspec.yaml
2. Regenerate icons with opaque background
3. Add more distinctive visual elements

---

## Design Resources

### Tools

**Icon Creation:**
- [Figma](https://figma.com) - Professional design tool
- [Canva](https://canva.com) - Simple icon templates
- [Icon Kitchen](https://icon.kitchen) - Online icon generator

**Color Tools:**
- [Coolors](https://coolors.co) - Color palette generator
- [Adobe Color](https://color.adobe.com) - Color wheel and harmonies
- [Contrast Checker](https://webaim.org/resources/contrastchecker/) - WCAG compliance

### References

- [Apple Human Interface Guidelines - Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Material Design - Icons](https://m3.material.io/styles/icons/overview)
- [Flutter Icon Best Practices](https://docs.flutter.dev/deployment/ios#add-an-app-icon)

---

## Quick Commands

```bash
# Generate source icons
python3 tool/generate_app_icon.py

# Generate all iOS icon sizes
flutter pub run flutter_launcher_icons

# Verify icons in Xcode
open ios/Runner.xcworkspace

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Build production with icons
flutter build ios -t lib/main_prod.dart --dart-define=PROD=true --release
```

---

## Brand Asset Checklist

Before release:

- [ ] App icon generated for all required sizes
- [ ] Icons render correctly on device/simulator
- [ ] Xcode shows no icon warnings
- [ ] App Store 1024x1024 icon present
- [ ] Brand colors documented in code
- [ ] Colors used consistently across app
- [ ] Clear space maintained around logo
- [ ] Icons pass accessibility contrast checks
- [ ] Branding guidelines documented
- [ ] Design assets committed to git
