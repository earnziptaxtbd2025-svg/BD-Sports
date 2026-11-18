import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The colours that change between the dark and the light look.
///
/// Brand colours that look the same in both (neon green buttons, team blue and red,
/// LIVE red) stay in [AppColors]. Everything that must be readable on a dark or on a
/// light background lives here. Widgets read it with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.isDark,
    required this.bgDeep,
    required this.bgBase,
    required this.surface,
    required this.surfaceRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.accent,
    required this.goldText,
    required this.cyanText,
    required this.orangeText,
    required this.danger,
    required this.screenGradient,
    required this.glassGradient,
    required this.glowStrength,
  });

  /// Dark "stadium night" look: the approved design.
  static const AppPalette dark = AppPalette(
    isDark: true,
    bgDeep: AppColors.bgDeep,
    bgBase: AppColors.bgBase,
    surface: AppColors.surface,
    surfaceRaised: AppColors.surfaceRaised,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    border: AppColors.borderCyan,
    divider: AppColors.divider,
    accent: AppColors.neonGreen,
    goldText: AppColors.gold,
    cyanText: AppColors.cyan,
    orangeText: AppColors.orange,
    danger: Color(0xFFFF6B76),
    screenGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[AppColors.bgBase, AppColors.bgDeep],
    ),
    glassGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xCC123068), Color(0xCC0B1E4A)],
    ),
    glowStrength: 1,
  );

  /// Light "match day" look: white cards on a pale blue background, deeper colours for
  /// text so it stays readable, and only a soft glow.
  static const AppPalette light = AppPalette(
    isDark: false,
    bgDeep: Color(0xFFFFFFFF),
    bgBase: Color(0xFFF2F6FC),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFE6EEFA),
    textPrimary: Color(0xFF0B1E4A),
    textSecondary: Color(0xFF42557F),
    textMuted: Color(0xFF5D6C91),
    border: Color(0xFFA9CDE8),
    divider: Color(0xFFD3E2F2),
    accent: Color(0xFF08772F),
    goldText: Color(0xFF8A6100),
    cyanText: Color(0xFF0B6E99),
    orangeText: Color(0xFF9A4605),
    danger: Color(0xFFC62828),
    screenGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xFFF2F6FC), Color(0xFFE3ECF8)],
    ),
    glassGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF4F8FE)],
    ),
    glowStrength: 0.35,
  );

  final bool isDark;

  // ---- Backgrounds ----
  final Color bgDeep;
  final Color bgBase;
  final Color surface;
  final Color surfaceRaised;

  // ---- Text ----
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // ---- Lines ----
  final Color border;
  final Color divider;

  // ---- Colours that are used as text or icons, so they must be readable ----
  /// Green for active items, links and focus.
  final Color accent;
  final Color goldText;
  final Color cyanText;
  final Color orangeText;
  final Color danger;

  // ---- Fills ----
  final LinearGradient screenGradient;
  final LinearGradient glassGradient;

  /// 1 = full neon glow (dark). Lower = softer glow (light).
  final double glowStrength;

  @override
  AppPalette copyWith({
    bool? isDark,
    Color? bgDeep,
    Color? bgBase,
    Color? surface,
    Color? surfaceRaised,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? accent,
    Color? goldText,
    Color? cyanText,
    Color? orangeText,
    Color? danger,
    LinearGradient? screenGradient,
    LinearGradient? glassGradient,
    double? glowStrength,
  }) {
    return AppPalette(
      isDark: isDark ?? this.isDark,
      bgDeep: bgDeep ?? this.bgDeep,
      bgBase: bgBase ?? this.bgBase,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      goldText: goldText ?? this.goldText,
      cyanText: cyanText ?? this.cyanText,
      orangeText: orangeText ?? this.orangeText,
      danger: danger ?? this.danger,
      screenGradient: screenGradient ?? this.screenGradient,
      glassGradient: glassGradient ?? this.glassGradient,
      glowStrength: glowStrength ?? this.glowStrength,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    return AppPalette(
      isDark: t < 0.5 ? isDark : other.isDark,
      bgDeep: mix(bgDeep, other.bgDeep),
      bgBase: mix(bgBase, other.bgBase),
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      border: mix(border, other.border),
      divider: mix(divider, other.divider),
      accent: mix(accent, other.accent),
      goldText: mix(goldText, other.goldText),
      cyanText: mix(cyanText, other.cyanText),
      orangeText: mix(orangeText, other.orangeText),
      danger: mix(danger, other.danger),
      screenGradient: t < 0.5 ? screenGradient : other.screenGradient,
      glassGradient: t < 0.5 ? glassGradient : other.glassGradient,
      glowStrength: lerpDouble(glowStrength, other.glowStrength, t) ?? glowStrength,
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// Colours of the current look. If the theme has no palette (a plain test app), the
  /// palette that matches the theme's brightness is used.
  AppPalette get palette {
    final ThemeData theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark ? AppPalette.dark : AppPalette.light);
  }
}
