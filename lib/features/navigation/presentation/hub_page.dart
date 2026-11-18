import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screen_spec.dart';
import '../../../core/navigation/screens.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/brand_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/screen_tile.dart';
import '../../../core/widgets/search_entry_bar.dart';
import '../../../core/widgets/stadium_background.dart';

/// A tab that lists the screens of one area (Explore, Create, My Sports).
/// Each row is a card that opens its screen. Locked cards ask the person to sign in
/// first.
///
/// - [icon]: icon of the intro card at the top.
/// - [showSearch]: adds a search box (used by Explore).
/// - [highlightFirst]: makes the first card glow (the main action of the tab).
class HubPage extends StatelessWidget {
  const HubPage({
    super.key,
    required this.title,
    required this.hub,
    required this.intro,
    this.icon = Icons.apps,
    this.showSearch = false,
    this.highlightFirst = false,
  });

  final String title;
  final HubTab hub;
  final String intro;
  final IconData icon;
  final bool showSearch;
  final bool highlightFirst;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final items = Screens.forHub(hub);
    final search = Screens.byId('discover.search');

    return Scaffold(
      appBar: BrandAppBar(title: title),
      body: StadiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.xl,
          ),
          children: [
            _IntroCard(icon: icon, text: intro),
            if (showSearch && search != null) ...[
              const SizedBox(height: AppSpacing.md),
              SearchEntryBar(
                hint: s.searchHint,
                onTap: () => context.push(search.path),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < items.length; i++) ...[
              ScreenTile(spec: items[i], highlight: highlightFirst && i == 0),
              const SizedBox(height: AppSpacing.sm + 2),
            ],
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Row(
        children: [
          Icon(icon, color: p.accent, size: 30),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: context.appText.body)),
        ],
      ),
    );
  }
}
