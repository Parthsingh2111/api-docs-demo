import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Design System for PayGlocal
/// Inspired by modern payment platforms like Stripe, Razorpay, and Square
class AppTheme {
  // ============================================================================
  // PREMIUM COLOR PALETTE
  // ============================================================================
  
  // Primary Brand Colors - Deep, trustworthy navy
  static const Color primaryDark = Color(0xFF0A2540);
  static const Color primaryMid = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2E4A6F);
  
  // Accent Colors - Refined indigo/purple
  static const Color accent = Color(0xFF6366F1);
  static const Color accentLight = Color(0xFF818CF8);
  static const Color accentDark = Color(0xFF4F46E5);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDCFCE7);
  
  // Neutral Grays - Sophisticated, modern
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray300 = Color(0xFFD4D4D8);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray500 = Color(0xFF71717A);
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray700 = Color(0xFF3F3F46);
  static const Color gray800 = Color(0xFF27272A);
  static const Color gray900 = Color(0xFF18181B);
  
  // Surface Colors
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFAFAFA);
  static const Color surfaceTertiary = Color(0xFFF4F4F5);
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFF4F4F5);
  
  // Dark Mode Colors - Muted, professional grey palette
  static const Color darkBackground = Color(0xFF0A0A0A); // Existential Angst - Base background
  static const Color darkBackgroundGrid = Color(0xFF19191A); // Thamar Black - Grid line color
  
  // Light Mode Grid Color
  static const Color lightBackgroundGrid = Color(0xFFE4E4E7); // Light grid line color
  static const Color darkSurface = Color(0xFF19191A); // Thamar Black - Elevated surface
  static const Color darkSurfaceElevated = Color(0xFF2A2A2A); // The End - More elevated surface
  static const Color darkBorder = Color(0xFF363636); // Dark Grey - Subtle border
  static const Color darkBorderStrong = Color(0xFF605E5E); // Rhine Castle - Stronger border
  
  // Additional dark mode greys for gradients and accents
  static const Color darkGreyMedium = Color(0xFF363636); // Dark Grey
  static const Color darkGreyLight = Color(0xFF605E5E); // Rhine Castle
  static const Color darkGreyLighter = Color(0xFF938A87); // Storm Break
  
  // Text Colors - Light Mode
  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF52525B);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textDisabled = Color(0xFFA1A1AA);
  
  // Text Colors - Dark Mode (reduced contrast, easier on eyes)
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // Zinc-50 soft white
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Zinc-400 reduced contrast
  static const Color darkTextTertiary = Color(0xFF71717A); // Zinc-500 medium gray
  static const Color darkTextDisabled = Color(0xFF52525B); // Zinc-600 dimmed
  
  // Border Colors
  static const Color borderLight = Color(0xFFE4E4E7);
  static const Color borderMedium = Color(0xFFD4D4D8);
  static const Color borderDark = Color(0xFFA1A1AA);
  
  // Overlay Colors
  static const Color overlayLight = Color(0x0F000000); // 6%
  static const Color overlayMedium = Color(0x1A000000); // 10%
  static const Color overlayDark = Color(0x33000000); // 20%
  static const Color overlayHeavy = Color(0x4D000000); // 30%

  // ============================================================================
  // LIGHT THEME - PRODUCT COLORS
  // Vibrant, clear colors for light mode
  // ============================================================================

  // JWT Secure / Primary Info - Vibrant Blue (matches existing usage)
  static const Color lightJwtBlue = Color(0xFF3B82F6);
  static const Color lightJwtBlueLight = Color(0xFF60A5FA);
  static const Color lightJwtBlueDark = Color(0xFF1E3A8A);

  // Recurring / Warm Colors - Vibrant Orange
  static const Color lightRecurringOrange = Color(0xFFFFA500);
  static const Color lightRecurringOrangeLight = Color(0xFFFBBF24);
  static const Color lightRecurringOrangeDark = Color(0xFFD97706);

  // Success / Flexible - Vibrant Green (matches AppTheme.success)
  static const Color lightSuccessGreen = Color(0xFF10B981);
  static const Color lightSuccessGreenLight = Color(0xFF34D399);
  static const Color lightSuccessGreenDark = Color(0xFF059669);

  // ============================================================================
  // CALM DARK THEME - PRODUCT COLORS (Stripe/Razorpay style)
  // Significantly muted, professional colors for reduced eye strain
  // ============================================================================

  // JWT Secure / Primary Info - Calm Indigo (Tailwind Indigo-400)
  static const Color darkJwtBlue = Color(0xFF818CF8);
  static const Color darkJwtBlueLight = Color(0xFFA5B4FC);
  static const Color darkJwtBlueDim = Color(0xFF6366F1);

  // Recurring / Rick Ring - Calm Amber (Tailwind Amber-400)
  static const Color darkRecurringAmber = Color(0xFFFBBF24);
  static const Color darkRecurringAmberLight = Color(0xFFFCD34D);
  static const Color darkRecurringAmberDim = Color(0xFFF59E0B);

  // Flexible / Success - Calm Green (Tailwind Green-400)
  static const Color darkSuccessEmerald = Color(0xFF4ADE80);
  static const Color darkSuccessEmeraldLight = Color(0xFF6EE7B7);
  static const Color darkSuccessEmeraldDim = Color(0xFF34D399);

  // Error / Refund - Calm Red (Tailwind Red-400)
  static const Color darkErrorCoral = Color(0xFFF87171);
  static const Color darkErrorCoralLight = Color(0xFFFCA5A5);
  static const Color darkErrorCoralDim = Color(0xFFEF4444);

  // Warning / Reversal - Calm Orange (Tailwind Orange-400)
  static const Color darkWarningOrange = Color(0xFFFB923C);
  static const Color darkWarningOrangeLight = Color(0xFFFDBBAF);
  static const Color darkWarningOrangeDim = Color(0xFFF97316);

  // Codedrop / Special Services - Calm Teal (Tailwind Teal-400)
  static const Color darkCodedropTeal = Color(0xFF2DD4BF);
  static const Color darkCodedropTealLight = Color(0xFF5EEAD4);
  static const Color darkCodedropTealDim = Color(0xFF14B8A6);

  // Capture / Confirm - Calm Emerald (Tailwind Emerald-400)
  static const Color darkCaptureMint = Color(0xFF34D399);
  static const Color darkCaptureMintLight = Color(0xFF6EE7B7);
  static const Color darkCaptureMintDim = Color(0xFF10B981);

  // SI Pause - Calm Purple (Tailwind Purple-400)
  static const Color darkSIPausePurple = Color(0xFFC084FC);
  static const Color darkSIPausePurpleLight = Color(0xFFD8B4FE);
  static const Color darkSIPausePurpleDim = Color(0xFFA855F7);

  // SI Activate - Calm Cyan (Tailwind Cyan-400)
  static const Color darkSIActivateCyan = Color(0xFF22D3EE);
  static const Color darkSIActivateCyanLight = Color(0xFF67E8F9);
  static const Color darkSIActivateCyanDim = Color(0xFF06B6D4);

  // SI On-Demand - Calm Blue (Tailwind Blue-400)
  static const Color darkSIOnDemandBlue = Color(0xFF60A5FA);
  static const Color darkSIOnDemandBlueLight = Color(0xFF93C5FD);
  static const Color darkSIOnDemandBlueDim = Color(0xFF3B82F6);

  // SI Status Check - Calm Sky (Tailwind Sky-400)
  static const Color darkSIStatusSky = Color(0xFF38BDF8);
  static const Color darkSIStatusSkyLight = Color(0xFF7DD3FC);
  static const Color darkSIStatusSkyDim = Color(0xFF0EA5E9);

  // ============================================================================
  // ADDITIONAL SEMANTIC COLORS (for documentation screens)
  // ============================================================================

  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple50 = Color(0xFFFAF5FF);
  static const Color green600 = Color(0xFF16A34A);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color red600 = Color(0xFFDC2626);
  static const Color teal600 = Color(0xFF0D9488);
  static const Color pink600 = Color(0xFFDB2777);
  
  // ============================================================================
  // SPACING SYSTEM - 8px Grid
  // ============================================================================

  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  static const double spacing80 = 80.0;
  static const double spacing96 = 96.0;
  
  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 9999.0;
  
  // ============================================================================
  // ELEVATION & SHADOWS
  // ============================================================================

  static List<BoxShadow> get shadowXS => [
    BoxShadow(
      color: overlayLight,
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: overlayLight,
      blurRadius: 8,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: overlayLight,
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: overlayLight,
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: overlayMedium,
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: overlayLight,
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowXL => [
    BoxShadow(
      color: overlayMedium,
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: overlayLight,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // ============================================================================
  // LIGHT THEME
  // ============================================================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: accent,
        primaryContainer: accentLight,
        secondary: primaryDark,
        secondaryContainer: primaryLight,
        tertiary: success,
        tertiaryContainer: successLight,
        surface: surfacePrimary,
        surfaceTint: accent,
        error: error,
        errorContainer: errorLight,
        onPrimary: Colors.white,
        onPrimaryContainer: primaryDark,
        onSecondary: Colors.white,
        onSecondaryContainer: primaryDark,
        onTertiary: Colors.white,
        onTertiaryContainer: success,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        onError: Colors.white,
        onErrorContainer: error,
        outline: borderLight,
        outlineVariant: borderMedium,
        shadow: overlayMedium,
        scrim: overlayHeavy,
        inverseSurface: darkSurface,
        onInverseSurface: darkTextPrimary,
        inversePrimary: accentLight,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: backgroundPrimary,
      
      // App Bar Theme - Clean and minimal
      appBarTheme: AppBarTheme(
        backgroundColor: surfacePrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _textStyle(20, FontWeight.w600, textPrimary),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
        actionsIconTheme: const IconThemeData(color: textSecondary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
        shadowColor: overlayLight,
      ),
      
      // Typography - Premium, readable
      textTheme: TextTheme(
        // Display styles
        displayLarge: _textStyle(48, FontWeight.bold, textPrimary, height: 1.2),
        displayMedium: _textStyle(40, FontWeight.bold, textPrimary, height: 1.2),
        displaySmall: _textStyle(32, FontWeight.bold, textPrimary, height: 1.2),
        
        // Headline styles
        headlineLarge: _textStyle(28, FontWeight.w600, textPrimary, height: 1.3),
        headlineMedium: _textStyle(24, FontWeight.w600, textPrimary, height: 1.3),
        headlineSmall: _textStyle(20, FontWeight.w600, textPrimary, height: 1.4),
        
        // Title styles
        titleLarge: _textStyle(18, FontWeight.w600, textPrimary, height: 1.4),
        titleMedium: _textStyle(16, FontWeight.w600, textPrimary, height: 1.5),
        titleSmall: _textStyle(14, FontWeight.w600, textPrimary, height: 1.5),
        
        // Body styles
        bodyLarge: _textStyle(16, FontWeight.normal, textPrimary, height: 1.6),
        bodyMedium: _textStyle(14, FontWeight.normal, textSecondary, height: 1.6),
        bodySmall: _textStyle(12, FontWeight.normal, textTertiary, height: 1.5),
        
        // Label styles
        labelLarge: _textStyle(14, FontWeight.w500, textPrimary, height: 1.4),
        labelMedium: _textStyle(12, FontWeight.w500, textSecondary, height: 1.4),
        labelSmall: _textStyle(11, FontWeight.w500, textTertiary, height: 1.3),
      ),
      
      // Card Theme - Subtle, refined
cardTheme: CardThemeData(
  color: surfacePrimary,
  elevation: 0,
  shadowColor: overlayLight,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radiusLG),
    side: const BorderSide(color: borderLight, width: 1),
  ),
  margin: EdgeInsets.zero,
  clipBehavior: Clip.antiAlias,
),
      
      // Button Themes - Premium, accessible
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: gray200,
          disabledForegroundColor: textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          minimumSize: const Size(88, 44),
          textStyle: _textStyle(14, FontWeight.w600, Colors.white),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: textDisabled,
          side: const BorderSide(color: borderMedium, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          minimumSize: const Size(88, 44),
          textStyle: _textStyle(14, FontWeight.w600, accent),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          disabledForegroundColor: textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing8,
          ),
          minimumSize: const Size(64, 40),
          textStyle: _textStyle(14, FontWeight.w600, accent),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfacePrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: _textStyle(14, FontWeight.normal, textSecondary),
        hintStyle: _textStyle(14, FontWeight.normal, textTertiary),
        errorStyle: _textStyle(12, FontWeight.normal, error),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSecondary,
        deleteIconColor: textSecondary,
        disabledColor: gray200,
        selectedColor: accentLight,
        secondarySelectedColor: successLight,
        padding: const EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8),
        labelStyle: _textStyle(13, FontWeight.w500, textPrimary),
        secondaryLabelStyle: _textStyle(13, FontWeight.w500, textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        elevation: 0,
      ),
      
      // Dialog Theme
// Dialog Theme
dialogTheme: DialogThemeData(
  backgroundColor: surfacePrimary,
  elevation: 8,
  shadowColor: overlayMedium,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radiusLG),
  ),
  titleTextStyle: _textStyle(20, FontWeight.w600, textPrimary),
  contentTextStyle: _textStyle(14, FontWeight.normal, textSecondary, height: 1.6),
),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: gray800,
        contentTextStyle: _textStyle(14, FontWeight.normal, Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: gray200,
        circularTrackColor: gray200,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentLight;
          return gray200;
        }),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
  
  // ============================================================================
  // DARK THEME
  // ============================================================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: darkJwtBlue, // Muted blue for primary actions
        primaryContainer: darkJwtBlueDim,
        secondary: darkRecurringAmber, // Muted amber for secondary
        secondaryContainer: darkRecurringAmberDim,
        tertiary: darkSuccessEmerald, // Muted emerald for success
        tertiaryContainer: darkSuccessEmeraldDim,
        surface: darkSurface,
        surfaceTint: darkJwtBlueLight,
        error: darkErrorCoral, // Muted coral red
        errorContainer: darkErrorCoralDim,
        onPrimary: darkBackground,
        onPrimaryContainer: darkJwtBlueLight,
        onSecondary: darkBackground,
        onSecondaryContainer: darkRecurringAmberLight,
        onTertiary: darkBackground,
        onTertiaryContainer: darkSuccessEmeraldLight,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
        onError: darkBackground,
        onErrorContainer: darkErrorCoralLight,
        outline: darkBorder,
        outlineVariant: darkBorderStrong,
        shadow: overlayHeavy,
        scrim: Color(0x80000000),
        inverseSurface: surfacePrimary,
        onInverseSurface: textPrimary,
        inversePrimary: darkJwtBlue,
      ),
      
      scaffoldBackgroundColor: darkBackground,
      
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _textStyle(20, FontWeight.w600, darkTextPrimary),
        iconTheme: const IconThemeData(color: darkTextPrimary, size: 24),
        actionsIconTheme: const IconThemeData(color: darkTextSecondary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        surfaceTintColor: Colors.transparent,
      ),
      
      textTheme: TextTheme(
        displayLarge: _textStyle(48, FontWeight.bold, darkTextPrimary, height: 1.2),
        displayMedium: _textStyle(40, FontWeight.bold, darkTextPrimary, height: 1.2),
        displaySmall: _textStyle(32, FontWeight.bold, darkTextPrimary, height: 1.2),
        headlineLarge: _textStyle(28, FontWeight.w600, darkTextPrimary, height: 1.3),
        headlineMedium: _textStyle(24, FontWeight.w600, darkTextPrimary, height: 1.3),
        headlineSmall: _textStyle(20, FontWeight.w600, darkTextPrimary, height: 1.4),
        titleLarge: _textStyle(18, FontWeight.w600, darkTextPrimary, height: 1.4),
        titleMedium: _textStyle(16, FontWeight.w600, darkTextPrimary, height: 1.5),
        titleSmall: _textStyle(14, FontWeight.w600, darkTextPrimary, height: 1.5),
        bodyLarge: _textStyle(16, FontWeight.normal, darkTextPrimary, height: 1.6),
        bodyMedium: _textStyle(14, FontWeight.normal, darkTextSecondary, height: 1.6),
        bodySmall: _textStyle(12, FontWeight.normal, darkTextTertiary, height: 1.5),
        labelLarge: _textStyle(14, FontWeight.w500, darkTextPrimary, height: 1.4),
        labelMedium: _textStyle(12, FontWeight.w500, darkTextSecondary, height: 1.4),
        labelSmall: _textStyle(11, FontWeight.w500, darkTextTertiary, height: 1.3),
      ),
      
    cardTheme: CardThemeData(
  color: darkSurface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radiusLG),
    side: const BorderSide(color: darkBorder, width: 1),
  ),
  margin: EdgeInsets.zero,
  clipBehavior: Clip.antiAlias,
),

      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkJwtBlue, // Muted blue for buttons
          foregroundColor: darkBackground,
          elevation: 0,
          disabledBackgroundColor: darkBorder,
          disabledForegroundColor: darkTextDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          minimumSize: const Size(88, 44),
          textStyle: _textStyle(14, FontWeight.w600, darkBackground),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkJwtBlueLight,
          side: const BorderSide(color: darkBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          minimumSize: const Size(88, 44),
          textStyle: _textStyle(14, FontWeight.w600, darkJwtBlueLight),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkJwtBlueLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing8,
          ),
          minimumSize: const Size(64, 40),
          textStyle: _textStyle(14, FontWeight.w600, darkJwtBlueLight),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: darkJwtBlueLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: _textStyle(14, FontWeight.normal, darkTextSecondary),
        hintStyle: _textStyle(14, FontWeight.normal, darkTextTertiary),
        errorStyle: _textStyle(12, FontWeight.normal, error),
      ),
      
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      
      iconTheme: const IconThemeData(
        color: darkTextSecondary,
        size: 24,
      ),
      
      dialogTheme: DialogThemeData(
  backgroundColor: darkSurface,
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radiusLG),
  ),
  titleTextStyle: _textStyle(20, FontWeight.w600, darkTextPrimary),
  contentTextStyle: _textStyle(14, FontWeight.normal, darkTextSecondary, height: 1.6),
),

      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceElevated,
        contentTextStyle: _textStyle(14, FontWeight.normal, darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Creates a consistent TextStyle with Poppins font
  static TextStyle _textStyle(
    double fontSize,
    FontWeight fontWeight,
    Color color, {
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing ?? (fontWeight == FontWeight.bold ? -0.02 : 0),
    );
  }
  
  /// Code/monospace font style
  static TextStyle codeStyle({
    double fontSize = 13,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.firaCode(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textSecondary,
      height: 1.5,
    );
  }

  // ============================================================================
  // GRID BACKGROUND DECORATION
  // Premium grid pattern for dark theme backgrounds
  // ============================================================================

  /// Creates a premium grid background decoration for dark theme
  /// Grid size: 40px squares with subtle lines
  static BoxDecoration get darkGridBackground {
    return BoxDecoration(
      color: darkBackground,
      image: DecorationImage(
        image: const AssetImage('assets/images/grid_pattern.png'),
        repeat: ImageRepeat.repeat,
        opacity: 0.3,
        fit: BoxFit.none,
      ),
    );
  }

  /// Creates a CSS-style grid pattern using CustomPainter
  /// Use this if you don't want to use an image asset
  static BoxDecoration get darkGridBackgroundPattern {
    return const BoxDecoration(
      color: darkBackground,
      // Grid pattern will be painted using CustomPainter
    );
  }

  /// Helper to get grid paint properties
  static Paint get gridPaint {
    return Paint()
      ..color = darkBackgroundGrid
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
  }

  // ============================================================================
  // THEME-AWARE COLOR GETTERS
  // Use these to automatically get the right color for current theme
  // ============================================================================

  /// Get background color based on theme brightness
  static Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBackground : backgroundPrimary;
  }

  /// Get surface color based on theme brightness
  static Color getSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurface : surfacePrimary;
  }

  /// Get border color based on theme brightness
  static Color getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBorder : borderLight;
  }

  /// Get JWT/Primary product color based on theme brightness
  static Color getJwtColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkJwtBlue : lightJwtBlue;
  }

  /// Get Recurring/Secondary product color based on theme brightness
  static Color getRecurringColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkRecurringAmber : lightRecurringOrange;
  }

  /// Get Success/Flexible color based on theme brightness
  static Color getSuccessColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSuccessEmerald : lightSuccessGreen;
  }

  /// Get primary text color based on theme brightness
  static Color getTextPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextPrimary : textPrimary;
  }

  /// Get secondary text color based on theme brightness
  static Color getTextSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextSecondary : textSecondary;
  }
}
