# BrightSide App Icon

This directory contains the source assets for the BrightSide app icon.

## Assets

- `app_icon.png` - Main app icon (1024x1024px, square with rounded corners applied by OS)
- `app_icon_foreground.png` - Android adaptive icon foreground layer (1024x1024px)

## Icon Design

The BrightSide icon features a simple sun glyph representing positivity and brightness:
- Primary color: #FFB800 (warm yellow/orange)
- Background: White (#FFFFFF)
- Design: Minimalist sun with radiating rays
- Style: Modern, friendly, optimistic

## Generating Icons

After updating the source images, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

This will generate:
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Android Adaptive: `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`

## Requirements

- `app_icon.png`: 1024x1024px PNG, transparent or white background
- `app_icon_foreground.png`: 1024x1024px PNG, transparent background, safe area 432x432px center

## Design Notes

For App Store submission:
- Icons should NOT include text or wordmarks
- Avoid transparency on iOS (use white background)
- Ensure good contrast for dark mode
- Test icon at small sizes (29pt, 40pt, 60pt)

## Placeholder Icon

Currently using a placeholder icon. Replace with final design before production release.

To create a simple sun icon programmatically or use a design tool like:
- Figma
- Sketch
- Adobe Illustrator
- Online icon generators (e.g., icon.kitchen)
