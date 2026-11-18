import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Colour of a [QuickActionCard]. Text on these cards is white in both looks.
enum QuickActionColor { blue, green, purple }

/// Coloured square-ish card with an icon, a title and a short line. Used in a row of
/// three on Home (Discover, Create, Join).
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final QuickActionColor color;
  final VoidCallback onTap;

  static const LinearGradient _green = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.greenDeep, Color(0xFF06622A)],
  );

  LinearGradient get _gradient {
    switch (color) {
      case QuickActionColor.blue:
        return AppEffects.buttonBlue;
      case QuickActionColor.green:
        return _green;
      case QuickActionColor.purple:
        return AppEffects.buttonPurple;
    }
  }

  Color get _glow {
    switch (color) {
      case QuickActionColor.blue:
        return AppColors.electricBlue;
      case QuickActionColor.green:
        return AppColors.neonGreen;
      case QuickActionColor.purple:
        return AppColors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;

    return Semantics(
      button: true,
      label: '$title. $body',
      excludeSemantics: true,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: _glow.withAlpha(150)),
          boxShadow: AppEffects.glow(_glow, strength: 0.6 * p.glowStrength),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.lgAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 112),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, size: 30, color: AppColors.textPrimary),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
