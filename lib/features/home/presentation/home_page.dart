import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screens.dart';
import '../../../core/providers/backend_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/brand_app_bar.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../core/widgets/glass_tile.dart';
import '../../../core/widgets/promo_banner.dart';
import '../../../core/widgets/quick_action_card.dart';
import '../../../core/widgets/screen_tile.dart';
import '../../../core/widgets/search_entry_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stadium_background.dart';

/// Home tab. Step 0.5 gives it the final look (banner, quick actions, sections). The
/// real tournament and match lists arrive in Step 1.5, so the sections show an empty
/// card until then.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// Screens offered as quick links on Home.
  static const List<String> shortcutIds = <String>[
    'discover.search',
    'discover.map',
    'discover.calendar',
    'system.notifications',
  ];

  /// Opens a screen from the screen list, if it exists.
  void _open(BuildContext context, String id) {
    final spec = Screens.byId(id);
    if (spec != null) {
      context.push(spec.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final configured = ref.watch(backendConfiguredProvider);

    return Scaffold(
      appBar: BrandAppBar(
        title: Env.appName,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: s.languageTitle,
            onPressed: () => context.push(AppRoutes.language),
          ),
        ],
      ),
      body: StadiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.xl,
          ),
          children: [
            SearchEntryBar(
              hint: s.searchHint,
              onTap: () => _open(context, 'discover.search'),
            ),
            const SizedBox(height: AppSpacing.md),
            PromoBanner(
              title: s.homeBannerTitle,
              body: s.homeBannerBody,
              buttonLabel: s.actionCreateTournament,
              onPressed: () => _open(context, 'create.tournament'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.emoji_events_outlined,
                    title: s.quickDiscoverTitle,
                    body: s.quickDiscoverBody,
                    color: QuickActionColor.blue,
                    onTap: () => _open(context, 'explore.tournaments'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.add_circle_outline,
                    title: s.actionCreateTournament,
                    body: s.quickCreateBody,
                    color: QuickActionColor.green,
                    onTap: () => _open(context, 'create.tournament'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.groups_outlined,
                    title: s.quickJoinTitle,
                    body: s.quickJoinBody,
                    color: QuickActionColor.purple,
                    onTap: () => _open(context, 'explore.tournaments'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: s.trendingTitle,
              icon: Icons.local_fire_department_outlined,
              actionLabel: s.seeAll,
              onAction: () => _open(context, 'explore.trending'),
            ),
            EmptyStateCard(
              icon: Icons.emoji_events_outlined,
              message: s.trendingEmpty,
              footer: AppBadge(
                label: s.stepLabel('1.5'),
                tone: AppBadgeTone.info,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: s.liveMatchesTitle,
              icon: Icons.sensors,
            ),
            EmptyStateCard(
              icon: Icons.sports_soccer,
              message: s.liveEmpty,
              footer: AppBadge(
                label: s.stepLabel('2.4'),
                tone: AppBadgeTone.info,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(title: s.quickLinks, icon: Icons.bolt),
            for (final id in shortcutIds)
              if (Screens.byId(id) case final spec?) ...[
                ScreenTile(spec: spec),
                const SizedBox(height: AppSpacing.sm + 2),
              ],
            // Developer information, hidden in production builds.
            if (Env.devToolsEnabled) ...[
              const SizedBox(height: AppSpacing.md),
              _BackendStatusCard(configured: configured),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackendStatusCard extends StatelessWidget {
  const _BackendStatusCard({required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    return GlassTile(
      icon: configured ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
      title: 'Backend',
      subtitle: configured
          ? 'Supabase keys found.'
          : 'Supabase keys not set yet. The app runs in offline preview.',
    );
  }
}
