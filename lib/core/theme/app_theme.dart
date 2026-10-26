import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onBackground: AppColors.onBackground,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.merriweather(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackground,
          height: 1.3,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
            letterSpacing: 0.15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          side: BorderSide(color: AppColors.primary),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
            letterSpacing: 0.15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
            letterSpacing: 0.15,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onBackground,
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.merriweather(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 64 / 57,
          letterSpacing: -0.25,
          color: AppColors.onBackground,
        ),
        displayMedium: GoogleFonts.merriweather(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 52 / 45,
          color: AppColors.onBackground,
        ),
        displaySmall: GoogleFonts.merriweather(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 44 / 36,
          color: AppColors.onBackground,
        ),
        headlineLarge: GoogleFonts.merriweather(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 40 / 32,
          color: AppColors.onBackground,
        ),
        headlineMedium: GoogleFonts.merriweather(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 36 / 28,
          color: AppColors.onBackground,
        ),
        headlineSmall: GoogleFonts.merriweather(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
          color: AppColors.onBackground,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 28 / 22,
          letterSpacing: 0.1,
          color: AppColors.onBackground,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 24 / 16,
          letterSpacing: 0.15,
          color: AppColors.onBackground,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: AppColors.onBackground,
        ),
        bodyLarge: GoogleFonts.merriweather(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          height: 1.65,
          letterSpacing: 0.5,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.merriweather(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          letterSpacing: 0.25,
          color: AppColors.onSurface,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          letterSpacing: 0.25,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariant,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 16 / 10,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurfaceDark,
        onBackground: AppColors.onBackgroundDark,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.onBackgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.merriweather(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackgroundDark,
          height: 1.3,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.merriweather(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 64 / 57,
          letterSpacing: -0.25,
          color: AppColors.onBackgroundDark,
        ),
        displayMedium: GoogleFonts.merriweather(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 52 / 45,
          color: AppColors.onBackgroundDark,
        ),
        displaySmall: GoogleFonts.merriweather(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 44 / 36,
          color: AppColors.onBackgroundDark,
        ),
        headlineLarge: GoogleFonts.merriweather(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 40 / 32,
          color: AppColors.onBackgroundDark,
        ),
        headlineMedium: GoogleFonts.merriweather(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 36 / 28,
          color: AppColors.onBackgroundDark,
        ),
        headlineSmall: GoogleFonts.merriweather(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
          color: AppColors.onBackgroundDark,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 28 / 22,
          letterSpacing: 0.1,
          color: AppColors.onBackgroundDark,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 24 / 16,
          letterSpacing: 0.15,
          color: AppColors.onBackgroundDark,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: AppColors.onSurfaceDark,
        ),
        bodyLarge: GoogleFonts.merriweather(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          height: 1.65,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceDark,
        ),
        bodyMedium: GoogleFonts.merriweather(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          letterSpacing: 0.25,
          color: AppColors.onSurfaceDark,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          letterSpacing: 0.25,
          color: AppColors.onSurfaceVariantDark,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: AppColors.onSurfaceDark,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariantDark,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 16 / 10,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariantDark,
        ),
      ),
    );
  }
}

class AppColors {
  // Primary - Medium Green
  static const Color primary = Color(0xFF292929);
  static const Color primaryLight = Color(0xFF4A4A4A);
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary - Accent
  static const Color secondary = Color(0xFF6B6B6B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);
  static const Color onSurface = Color(0xFF292929);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFF6B6B6B);
  static const Color onSurfaceVariantDark = Color(0xFF9E9E9E);
  
  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color onBackground = Color(0xFF292929);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  
  // Border
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF3A3A3A);
  
  // Error
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  
  // Success
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF81C784);
  
  // Warning
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFB74D);
  
  // Info
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF42A5F5);
  
  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF424242);
  
  // Claps color
  static const Color clapsColor = Color(0xFF292929);
  static const Color clapsColorHighlight = Color(0xFF4A4A4A);
  
  // Highlight colors
  static const List<Color> highlightColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFF6B6B), // Coral
    Color(0xFF4ECDC4), // Teal
    Color(0xFFA05195), // Purple
    Color(0xFFFFA07A), // Light Salmon
  ];
}

class AppTypography {
  // Merriweather for body text (serif)
  static TextStyle get bodyText => GoogleFonts.merriweather(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.65,
    letterSpacing: 0.5,
  );
  
  static TextStyle get bodyTextDark => GoogleFonts.merriweather(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.65,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceDark,
  );
  
  // Inter for UI elements (sans-serif)
  static TextStyle get uiText => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );
  
  static TextStyle get uiTextDark => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceDark,
  );
}

class AppDimensions {
  // Spacing
  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;
  static const double spacingXXLarge = 48;
  
  // Padding
  static const double paddingXSmall = 4;
  static const double paddingSmall = 8;
  static const double paddingMedium = 16;
  static const double paddingLarge = 24;
  static const double paddingXLarge = 32;
  
  // Margin
  static const double marginXSmall = 4;
  static const double marginSmall = 8;
  static const double marginMedium = 16;
  static const double marginLarge = 24;
  
  // Radius
  static const double radiusXSmall = 4;
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
  static const double radiusFull = 1000;
  
  // Icon sizes
  static const double iconXSmall = 16;
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;
  
  // Button sizes
  static const double buttonHeightSmall = 40;
  static const double buttonHeightMedium = 48;
  static const double buttonHeightLarge = 56;
  
  // Image sizes
  static const double avatarSizeSmall = 32;
  static const double avatarSizeMedium = 48;
  static const double avatarSizeLarge = 72;
  static const double coverImageHeight = 200;
  static const double articleImageHeight = 150;
  
  // Card sizes
  static const double cardElevation = 0;
  static const double cardBorderWidth = 1;
  
  // Divider
  static const double dividerHeight = 1;
  static const double dividerIndent = 16;
  
  // AppBar
  static const double appBarHeight = 56;
  static const double appBarElevation = 0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 56;
  
  // Text Field
  static const double textFieldHeight = 48;
  
  // Dialog
  static const double dialogRadius = 16;
  static const double dialogPadding = 24;
  
  // Chip
  static const double chipHeight = 32;
  static const double chipPadding = 8;
  static const double chipRadius = 16;
  
  // Article content max width for readability
  static const double maxContentWidth = 650;
  static const double maxContentWidthTablet = 800;
  
  // Claps button
  static const double clapsButtonSize = 40;
  static const double clapsIconSize = 24;
  
  // Highlight
  static const double highlightMenuWidth = 200;
}
