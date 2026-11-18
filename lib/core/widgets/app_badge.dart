import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
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

  ({Color background, Color foreground, Color border}) get _colors {
    switch (tone) {
      case AppBadgeTone.success:
        return (
          background: const Color(0x3322E55C),
          foreground: AppColors.neonGreen,
          border: AppColors.borderGreen,
        );
      case AppBadgeTone.warning:
        return (
          background: const Color(0x33FFC928),
          foreground: AppColors.gold,
          border: const Color(0x99FFC928),
        );
      case AppBadgeTone.danger:
        return (
          background: AppColors.redDeep,
          foreground: AppColors.textPrimary,
          border: AppColors.liveRed,
        );
      case AppBadgeTone.info:
        return (
          background: const Color(0x3335B8E8),
          foreground: AppColors.cyan,
          border: AppColors.borderCyan,
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
      case AppBadgeTone.orange:
        return (
          background: const Color(0x33F08A24),
          foreground: AppColors.orange,
          border: const Color(0x99F08A24),
        );
      case AppBadgeTone.neutral:
        return (
          background: AppColors.surfaceRaised,
          foreground: AppColors.textSecondary,
          border: AppColors.borderCyan,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
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
