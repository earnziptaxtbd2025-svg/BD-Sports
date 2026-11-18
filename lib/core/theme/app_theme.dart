import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
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

  /// Dark "stadium night" look: the approved neon design (Step 0.5).
  static ThemeData neonNight() => _neon(AppPalette.dark);

  /// Light "match day" look: same design on a white and pale-blue background.
  static ThemeData neonDay() => _neon(AppPalette.light);

  /// Builds one look of the neon design from its palette.
  static ThemeData _neon(AppPalette p) {
    final bool isDark = p.isDark;
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    final AppText t = AppText(p);

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: isDark ? const Color(0xFF03210F) : const Color(0xFFFFFFFF),
      primaryContainer: isDark ? AppColors.greenDeep : const Color(0xFFCDEED8),
      onPrimaryContainer: isDark ? AppColors.textPrimary : const Color(0xFF00210F),
      secondary: AppColors.electricBlue,
      onSecondary: AppColors.textPrimary,
      tertiary: p.goldText,
      onTertiary: isDark ? const Color(0xFF241A00) : const Color(0xFFFFFFFF),
      error: p.danger,
      onError: AppColors.textPrimary,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      outline: p.cyanText,
      outlineVariant: p.divider,
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: t.score,
      headlineSmall: t.title,
      titleMedium: t.heading,
      bodyLarge: t.body,
      bodyMedium: t.body,
      bodySmall: t.caption,
      labelLarge: t.button,
      labelSmall: t.badge,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: p.bgBase,
      dividerColor: p.divider,
      extensions: <ThemeExtension<dynamic>>[p],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: p.bgDeep,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: t.title,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.bgDeep,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(t.caption),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? p.accent : p.textSecondary);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: TextStyle(color: p.textMuted),
        border: OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide(color: p.accent, width: 1.5),
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
