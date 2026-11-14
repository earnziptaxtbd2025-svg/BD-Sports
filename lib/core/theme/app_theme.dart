import 'package:flutter/material.dart';

/// App theme. Green is the brand colour. The full design system is Step 0.5.
class AppTheme {
  const AppTheme._();

  /// Pitch green: the main brand colour.
  static const Color pitchGreen = Color(0xFF0B6B3A);

  /// Marigold: accent for highlights and live indicators.
  static const Color marigold = Color(0xFFF2A900);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

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
