import 'package:flutter/material.dart';

/// Basic theme. The full design system is built in Step 0.5.
class AppTheme {
  const AppTheme._();

  /// Pitch green: the primary brand colour.
  static const Color pitchGreen = Color(0xFF0B6B3A);

  /// Marigold: accent colour for highlights and live indicators.
  static const Color marigold = Color(0xFFF2A900);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: pitchGreen,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
