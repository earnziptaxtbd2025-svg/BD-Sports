import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

/// Search box look that opens the search screen when tapped (it is not typed into).
class SearchEntryBar extends StatelessWidget {
  const SearchEntryBar({super.key, required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;

    return Semantics(
      button: true,
      label: hint,
      excludeSemantics: true,
      onTap: onTap,
      child: GlassCard(
        radius: AppRadius.pillAll,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search, color: p.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                hint,
                style: context.appText.body.copyWith(color: p.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
