import 'package:flutter/material.dart';

/// NovaMind design system.
///
/// One source of truth for colour, spacing, radius and type. Every screen and
/// widget reads from here, so the whole app stays consistent — that consistency
/// is what makes it feel premium. To retheme later (or add a light mode), you
/// only change values in this file.
class Nova {
  Nova._();

  // ---------------------------------------------------------------------------
  // BRAND — sampled directly from your logo
  // Left of the brain / "nova"  -> violet   ~#9566EB
  // Right of the brain / "mind" -> royal blue ~#486DE1
  // ---------------------------------------------------------------------------
  static const Color violet = Color(0xFF8B5CF6); // primary accent
  static const Color blue = Color(0xFF4F6FE6); // gradient companion

  /// The ONE gradient in the app. It lives only on the primary action of a
  /// screen — never on every card, chip and bubble. That restraint is the point.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [violet, blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ---------------------------------------------------------------------------
  // SURFACES — one calm, deep canvas instead of competing glows
  // ---------------------------------------------------------------------------
  static const Color bg = Color(0xFF0A0D16); // page background
  static const Color surface = Color(0xFF141A2A); // cards / inputs
  static const Color surfaceHigh = Color(0xFF1B2233); // raised / dialogs

  // Hairline borders. Kept subtle and consistent everywhere.
  static const Color border = Color(0x14FFFFFF); // ~8% white
  static const Color borderStrong = Color(0x24FFFFFF); // ~14% white

  // ---------------------------------------------------------------------------
  // TEXT — readable by default. No more critical copy sitting at 45% opacity.
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFFF4F6FB);
  static const Color textSecondary = Color(0xFFAAB4C6);
  static const Color textMuted = Color(0xFF6E7891);

  // ---------------------------------------------------------------------------
  // SEMANTIC (used sparingly, only where meaning is needed)
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color danger = Color(0xFFF04444);

  // ---------------------------------------------------------------------------
  // SPACING — 4pt rhythm. Use these instead of magic numbers.
  // ---------------------------------------------------------------------------
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;

  // ---------------------------------------------------------------------------
  // RADIUS
  // ---------------------------------------------------------------------------
  static const double rSm = 14;
  static const double rMd = 18;
  static const double rLg = 24;
  static const double rXl = 30;

  // ---------------------------------------------------------------------------
  // TYPE SCALE — one scale, applied everywhere.
  // ---------------------------------------------------------------------------
  static const TextStyle display = TextStyle(
    color: textPrimary,
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );
  static const TextStyle h1 = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  static const TextStyle h2 = TextStyle(
    color: textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle title = TextStyle(
    color: textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle body = TextStyle(
    color: textPrimary,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle bodySecondary = TextStyle(
    color: textSecondary,
    fontSize: 14.5,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle label = TextStyle(
    color: textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Soft shadow used only under the primary action, for a subtle lift.
  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: violet.withValues(alpha: 0.28),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];

  // ---------------------------------------------------------------------------
  // MATERIAL THEME
  // ---------------------------------------------------------------------------
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: violet,
        brightness: Brightness.dark,
      ).copyWith(surface: bg),
    );

    return base.copyWith(
      splashFactory: InkRipple.splashFactory,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: violet),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceHigh,
        contentTextStyle: body,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rSm),
          side: const BorderSide(color: borderStrong),
        ),
      ),
    );
  }
}
