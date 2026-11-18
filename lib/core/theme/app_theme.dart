import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// App theme. Green is the brand colour. The full design system is Step 0.5.
class AppTheme {
  const AppTheme._();

  /// Pitch green: the main brand colour.
  static const Color pitchGreen = Color(0xFF0B6B3A);

  /// Marigold: accent for highlights and live indicators.
  static const Color marigold = Color(0xFFF2A900);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  /// The "stadium night" neon design from the approved screens (Step 0.5).
  static ThemeData neonNight() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.neonGreen,
      onPrimary: Color(0xFF03210F),
      primaryContainer: AppColors.greenDeep,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.electricBlue,
      onSecondary: AppColors.textPrimary,
      tertiary: AppColors.gold,
      onTertiary: Color(0xFF241A00),
      error: AppColors.liveRed,
      onError: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.cyan,
      outlineVariant: AppColors.divider,
    );

    const TextTheme textTheme = TextTheme(
      displayLarge: AppTextStyles.score,
      headlineSmall: AppTextStyles.title,
      titleMedium: AppTextStyles.heading,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
      labelSmall: AppTextStyles.badge,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.bgBase,
      dividerColor: AppColors.divider,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.bgDeep,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.title,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgDeep,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.greenDeep,
        labelTextStyle: WidgetStateProperty.all(AppTextStyles.caption),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.neonGreen : AppColors.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide(color: AppColors.borderCyan),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide(color: AppColors.borderCyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide(color: AppColors.neonGreen, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTap),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final base = ColorScheme.fromSeed(
      seedColor: pitchGreen,
      brightness: brightness,
    );

    // Pin the key greens so the app is clearly green, not a tinted neutral.
    final scheme = base.copyWith(
      surface: isLight ? Colors.white : base.surface,
      primary: isLight ? pitchGreen : const Color(0xFF6FDC95),
      onPrimary: isLight ? Colors.white : const Color(0xFF00391B),
      primaryContainer:
          isLight ? const Color(0xFFCDEED8) : const Color(0xFF0F5A32),
      onPrimaryContainer:
          isLight ? const Color(0xFF00210F) : const Color(0xFFCDEED8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? Colors.white : scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? Colors.white : null,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),
    );
  }
}
