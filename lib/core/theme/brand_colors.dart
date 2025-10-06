import 'package:flutter/material.dart';

/// BrightSide Brand Colors
///
/// Centralized color palette for the BrightSide app.
/// All brand colors should be defined here for consistency across the app.
class BrandColors {
  BrandColors._(); // Private constructor to prevent instantiation

  // Primary Brand Color - Warm Yellow (Sun)
  static const Color primary = Color(0xFFFFB800);
  static const Color primaryLight = Color(0xFFFFD54F);
  static const Color primaryDark = Color(0xFFFFA000);

  // Secondary Colors
  static const Color secondary = Color(0xFF2196F3); // Blue sky
  static const Color secondaryLight = Color(0xFF64B5F6);
  static const Color secondaryDark = Color(0xFF1976D2);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B35); // Warm orange
  static const Color accentLight = Color(0xFFFF9966);
  static const Color accentDark = Color(0xFFE64A19);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);

  // Grayscale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFFA000);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);

  // Icon Colors
  static const Color iconActive = Color(0xFF212121);
  static const Color iconInactive = Color(0xFF9E9E9E);
  static const Color iconDisabled = Color(0xFFBDBDBD);

  // Divider & Border
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF757575);

  // Overlay & Shadow
  static const Color overlay = Color(0x66000000); // 40% black
  static const Color overlayLight = Color(0x33000000); // 20% black
  static const Color overlayDark = Color(0x99000000); // 60% black

  static const Color shadow = Color(0x1F000000); // 12% black
  static const Color shadowLight = Color(0x0F000000); // 6% black
  static const Color shadowDark = Color(0x3D000000); // 24% black

  // Social Media Colors (for auth buttons)
  static const Color google = Color(0xFF4285F4);
  static const Color apple = Color(0xFF000000);
  static const Color facebook = Color(0xFF1877F2);

  // Feature-Specific Colors
  static const Color likeActive = Color(0xFFE91E63); // Pink for liked stories
  static const Color likeInactive = Color(0xFFBDBDBD);

  static const Color featured = Color(0xFFFFC107); // Gold for featured articles
  static const Color trending = Color(0xFFFF6B35); // Orange for trending

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB800), // primary
      Color(0xFFFFA000), // primaryDark
    ],
  );

  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFD54F), // primaryLight
      Color(0xFFFFB800), // primary
      Color(0xFFFF6B35), // accent
    ],
  );

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF64B5F6), // secondaryLight
      Color(0xFF2196F3), // secondary
    ],
  );
}

/// Brand Color Helpers
extension BrandColorHelpers on BuildContext {
  /// Get primary brand color
  Color get primaryColor => BrandColors.primary;

  /// Get secondary brand color
  Color get secondaryColor => BrandColors.secondary;

  /// Get accent brand color
  Color get accentColor => BrandColors.accent;
}

/// Material Color Swatch for Primary Color
/// Use this for ThemeData primarySwatch
class BrandMaterialColors {
  static const MaterialColor primarySwatch = MaterialColor(
    0xFFFFB800,
    <int, Color>{
      50: Color(0xFFFFF8E1),
      100: Color(0xFFFFECB3),
      200: Color(0xFFFFE082),
      300: Color(0xFFFFD54F),
      400: Color(0xFFFFCA28),
      500: Color(0xFFFFB800), // Primary
      600: Color(0xFFFFB300),
      700: Color(0xFFFFA000),
      800: Color(0xFFFF8F00),
      900: Color(0xFFFF6F00),
    },
  );
}
