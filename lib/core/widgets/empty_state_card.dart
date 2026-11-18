import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

/// A card that says "nothing here yet". [footer] can hold a small badge, for example
/// the step that builds the real list.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.message,
    this.footer,
  });

  final IconData icon;
  final String message;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Widget? bottom = footer;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Icon(icon, size: 34, color: p.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.appText.caption,
            ),
            if (bottom != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              bottom,
            ],
          ],
        ),
      ),
    );
  }
}
