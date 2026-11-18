import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/widgets/neon_bottom_nav.dart';
import '../../../core/widgets/sync_status_banner.dart';

/// Bottom navigation: Home, Explore, Create, My Sports, Profile.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: navigationShell),
          const SyncStatusBanner(),
        ],
      ),
      bottomNavigationBar: NeonBottomNav(
        selectedIndex: navigationShell.currentIndex,
        centerIndex: 2,
        onChanged: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          NeonNavItem(
            label: s.tabHome,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
          ),
          NeonNavItem(label: s.tabExplore, icon: Icons.search),
          NeonNavItem(label: s.tabCreate, icon: Icons.add),
          NeonNavItem(
            label: s.tabMySports,
            icon: Icons.emoji_events_outlined,
            selectedIcon: Icons.emoji_events,
          ),
          NeonNavItem(
            label: s.tabProfile,
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
          ),
        ],
      ),
    );
  }
}
