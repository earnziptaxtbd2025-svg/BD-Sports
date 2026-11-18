import 'dart:math' as math;

import 'package:bd_sports/core/theme/app_colors.dart';
import 'package:bd_sports/core/theme/app_effects.dart';
import 'package:bd_sports/core/theme/app_spacing.dart';
import 'package:bd_sports/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast ratio between two colours (1 to 21).
double contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('text is readable on dark backgrounds', () {
    test('primary text on every background', () {
      for (final Color bg in <Color>[
        AppColors.bgDeep,
        AppColors.bgBase,
        AppColors.surface,
        AppColors.surfaceRaised,
      ]) {
        expect(contrast(AppColors.textPrimary, bg), greaterThanOrEqualTo(7));
      }
    });

    test('secondary and muted text on cards', () {
      expect(contrast(AppColors.textSecondary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
      expect(contrast(AppColors.textMuted, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('gold and neon green highlights on the screen background', () {
      expect(contrast(AppColors.gold, AppColors.bgBase),
          greaterThanOrEqualTo(4.5));
      expect(contrast(AppColors.neonGreen, AppColors.bgBase),
          greaterThanOrEqualTo(4.5));
    });
  });

  group('spacing and radius', () {
    test('spacing grows step by step', () {
      final List<double> steps = <double>[
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ];
      for (int i = 1; i < steps.length; i++) {
        expect(steps[i], greaterThan(steps[i - 1]));
      }
    });

    test('tap target is at least 48', () {
      expect(AppSpacing.minTap, greaterThanOrEqualTo(48));
    });
  });

  group('glow', () {
    test('strength 0 gives no shadow', () {
      expect(AppEffects.glow(AppColors.neonGreen, strength: 0), isEmpty);
    });

    test('strength out of range is clamped', () {
      final List<BoxShadow> full = AppEffects.glow(AppColors.neonGreen);
      final List<BoxShadow> over =
          AppEffects.glow(AppColors.neonGreen, strength: 5);
      expect(over.first.color, full.first.color);
    });
  });

  group('themes', () {
    test('neon theme is dark and green', () {
      final ThemeData t = AppTheme.neonNight();
      expect(t.brightness, Brightness.dark);
      expect(t.colorScheme.primary, AppColors.neonGreen);
      expect(t.scaffoldBackgroundColor, AppColors.bgBase);
    });

    test('light theme is still available', () {
      expect(AppTheme.light().brightness, Brightness.light);
    });
  });
}
