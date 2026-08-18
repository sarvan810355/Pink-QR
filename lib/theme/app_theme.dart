import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// QR Bloom design tokens — the single source of truth for the
/// "girly minimalist" pink aesthetic. Screens should pull colors,
/// spacing, radii and gradients from here instead of hardcoding values.
class AppColors {
  AppColors._();

  // ---- Day Pink (light theme) ----
  static const Color blush = Color(0xFFFFF6F9);
  static const Color blushWhite = Color(0xFFFFFBFD);
  static const Color primaryPink = Color(0xFFFFB6C1);
  static const Color softPink = Color(0xFFFFD6E8);
  static const Color hotPink = Color(0xFFFF8FAB);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color roseGoldLight = Color(0xFFE8B4B8);
  static const Color lavenderMist = Color(0xFFE9DFF3);
  static const Color mintWhisper = Color(0xFFDFF3EA);
  static const Color butterYellow = Color(0xFFFFF3C4);
  static const Color skyBlush = Color(0xFFD8ECF3);
  static const Color textDark = Color(0xFF4A3238);
  static const Color textMuted = Color(0xFF9A7B83);
  static const Color heartRed = Color(0xFFFF6B81);

  // ---- Night Pink (dark theme) ----
  static const Color charcoal = Color(0xFF241B1E);
  static const Color charcoalCard = Color(0xFF2F2327);
  static const Color dustyRose = Color(0xFFD48A99);
  static const Color dustyRoseDeep = Color(0xFFB56576);
  static const Color nightTextLight = Color(0xFFF6E6EA);
  static const Color nightTextMuted = Color(0xFFC7A8B0);

  static const List<Color> pastelPaletteChoices = [
    softPink,
    primaryPink,
    lavenderMist,
    mintWhisper,
    butterYellow,
    skyBlush,
    roseGoldLight,
  ];
}

class AppRadii {
  AppRadii._();
  static const double sm = 14;
  static const double md = 20;
  static const double lg = 24;
  static const double pill = 999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppGradients {
  AppGradients._();

  static const LinearGradient dayBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE3ED), Color(0xFFFFF6F9), Color(0xFFFFFBFD)],
  );

  static const LinearGradient nightBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2B1F23), Color(0xFF241B1E), Color(0xFF1D1518)],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.softPink, AppColors.hotPink],
  );

  static const LinearGradient roseGoldShine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.roseGoldLight, AppColors.roseGold],
  );

  /// Time-of-day greeting gradient for the Home header.
  static LinearGradient greetingForHour(int hour) {
    if (hour < 5) {
      return const LinearGradient(
        colors: [Color(0xFF9AA6D8), Color(0xFFE9DFF3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 12) {
      return const LinearGradient(
        colors: [Color(0xFFFFE3ED), Color(0xFFFFF3C4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 17) {
      return const LinearGradient(
        colors: [Color(0xFFFFD6E8), Color(0xFFD8ECF3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hour < 20) {
      return const LinearGradient(
        colors: [Color(0xFFFFB6C1), Color(0xFFE8B4B8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF6B5876), Color(0xFFB56576)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.primaryPink.withValues(alpha: 0.18),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.hotPink.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTextStyles {
  AppTextStyles._();

  static final TextStyle _base = GoogleFonts.quicksand();
  static final TextStyle _display = GoogleFonts.comfortaa();

  static TextStyle greeting(Color color) => _display.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.2,
      );

  static TextStyle heading(Color color) => _display.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle title(Color color) => _base.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle body(Color color) => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle caption(Color color) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle button(Color color) => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.3,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.blush,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.hotPink,
        brightness: Brightness.light,
        primary: AppColors.hotPink,
        secondary: AppColors.roseGold,
        surface: AppColors.blushWhite,
      ),
      fontFamily: GoogleFonts.quicksand().fontFamily,
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.quicksandTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.blushWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: AppTextStyles.body(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get night {
    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.charcoal,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dustyRose,
        brightness: Brightness.dark,
        primary: AppColors.dustyRose,
        secondary: AppColors.roseGold,
        surface: AppColors.charcoalCard,
      ),
      fontFamily: GoogleFonts.quicksand().fontFamily,
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.quicksandTextTheme(base.textTheme).apply(
        bodyColor: AppColors.nightTextLight,
        displayColor: AppColors.nightTextLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.nightTextLight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoalCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dustyRoseDeep,
        contentTextStyle: AppTextStyles.body(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
