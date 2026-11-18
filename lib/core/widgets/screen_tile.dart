import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_strings.dart';
import '../navigation/screen_spec.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import 'app_badge.dart';
import 'glass_tile.dart';

/// A card that opens one screen of the app (title and description come from the
/// screen list). Shows a lock when the person must sign in, and the step label while
/// the real screen is not built yet.
class ScreenTile extends StatelessWidget {
  const ScreenTile({super.key, required this.spec, this.highlight = false});

  final ScreenSpec spec;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final s = context.s;

    return GlassTile(
      icon: spec.icon,
      title: spec.titleFor(s.language),
      subtitle: spec.descriptionFor(s.language),
      highlight: highlight,
      onTap: () => context.push(spec.path),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (spec.access != ScreenAccess.public)
            Icon(Icons.lock_outline, size: 16, color: p.textSecondary),
          if (!spec.isBuilt) ...<Widget>[
            if (spec.access != ScreenAccess.public)
              const SizedBox(height: AppSpacing.xs),
            AppBadge(label: s.stepLabel(spec.step), tone: AppBadgeTone.info),
          ] else
            Icon(Icons.chevron_right, color: p.textSecondary),
        ],
      ),
    );
  }
}
