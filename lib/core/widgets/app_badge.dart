import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Meaning colour of an [AppBadge].
enum AppBadgeTone {
  /// Approved, open, paid.
  success,

  /// Pending, coming soon.
  warning,

  /// Rejected, closed, error.
  danger,

  /// Information.
  info,

  /// Player role BAT or team side blue.
  blue,

  /// Player role ALL (all-rounder) or special.
  purple,

  /// Player role BOWL.
  orange,

  /// Plain, no special meaning.
  neutral,
}

/// Small pill label such as "Approved", "Pending Review", "BAT".
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final AppBadgeTone tone;
  final IconData? icon;

  /// Colours for the tone. Text colours come from the palette so they stay readable
  /// on both the dark and the light look.
  ({Color background, Color foreground, Color border}) _colors(AppPalette p) {
    ({Color background, Color foreground, Color border}) tinted(Color fg) => (
          background: fg.withAlpha(p.isDark ? 40 : 24),
          foreground: fg,
          border: fg.withAlpha(150),
        );

    switch (tone) {
      case AppBadgeTone.success:
        return tinted(p.accent);
      case AppBadgeTone.warning:
        return tinted(p.goldText);
      case AppBadgeTone.info:
        return tinted(p.cyanText);
      case AppBadgeTone.orange:
        return tinted(p.orangeText);
      case AppBadgeTone.danger:
        return (
          background: AppColors.redDeep,
          foreground: AppColors.textPrimary,
          border: AppColors.liveRed,
        );
      case AppBadgeTone.blue:
        return (
          background: AppColors.blueDeep,
          foreground: AppColors.textPrimary,
          border: AppColors.electricBlue,
        );
      case AppBadgeTone.purple:
        return (
          background: AppColors.purpleDeep,
          foreground: AppColors.textPrimary,
          border: AppColors.purple,
        );
      case AppBadgeTone.neutral:
        return (
          background: p.surfaceRaised,
          foreground: p.textSecondary,
          border: p.border,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context.palette);
    final IconData? leading = icon;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (leading != null) ...<Widget>[
              Icon(leading, size: 14, color: colors.foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTextStyles.badge.copyWith(color: colors.foreground),
            ),
          ],
        ),
      ),
    );
  }
}
