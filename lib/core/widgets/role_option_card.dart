import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

/// A choice card with an icon, a title and a short line. The chosen card glows green
/// and shows a tick. Used for the role choice (Organizer, Player, Fan).
class RoleOptionCard extends StatelessWidget {
  const RoleOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppText t = context.appText;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $body',
      excludeSemantics: true,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          GlassCard(
            onTap: onTap,
            glowColor: selected ? AppColors.neonGreen : null,
            borderColor: selected ? p.accent : null,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 30, color: selected ? p.accent : p.textSecondary),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.heading.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: t.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          if (selected)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.accent,
                  border: Border.all(color: p.bgBase, width: 2),
                ),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: p.isDark ? const Color(0xFF03210F) : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
