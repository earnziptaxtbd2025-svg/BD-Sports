import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

/// One row card: an icon in a rounded square, a title, a short description and
/// something on the right (badge, lock, arrow). The list item of the design.
///
/// [highlight] makes the card glow green. Use it for the one main action of a list.
class GlassTile extends StatelessWidget {
  const GlassTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppText t = context.appText;
    final String? second = subtitle;
    final Widget? end = trailing;

    return GlassCard(
      onTap: onTap,
      glowColor: highlight ? AppColors.neonGreen : null,
      borderColor: highlight ? AppColors.borderGreen : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: p.accent.withAlpha(p.isDark ? 32 : 26),
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: p.accent.withAlpha(110)),
            ),
            child: Icon(icon, color: p.accent, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: t.heading.copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (second != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    second,
                    style: t.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (end != null) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            end,
          ],
        ],
      ),
    );
  }
}
