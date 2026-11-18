import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';
import 'neon_button.dart';

/// Big banner card with a trophy, a headline, a line of text and one button. Shows
/// `assets/images/trophy.png` when it exists, otherwise a drawn trophy icon.
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppText t = context.appText;

    return GlassCard(
      glowColor: AppColors.neonGreen,
      borderColor: AppColors.borderGreen,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: t.title.copyWith(fontSize: 20, color: p.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(body, style: t.caption),
                const SizedBox(height: AppSpacing.md + 2),
                NeonButton(
                  label: buttonLabel,
                  icon: Icons.arrow_forward,
                  expand: false,
                  onPressed: onPressed,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 84,
            height: 84,
            child: Image.asset(
              AppAssets.trophy,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  const Icon(Icons.emoji_events, size: 76, color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}
