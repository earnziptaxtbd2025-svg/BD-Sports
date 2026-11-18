import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_strings.dart';
import '../navigation/screens.dart';
import '../theme/app_spacing.dart';
import 'app_logo.dart';

/// Header of the main tabs: app logo, screen title, and the notification bell.
/// Extra buttons (for example the language button) go in [actions] before the bell.
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({super.key, required this.title, this.actions = const <Widget>[]});

  final String title;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final notifications = Screens.byId('system.notifications');

    return AppBar(
      titleSpacing: AppSpacing.md,
      title: Row(
        children: <Widget>[
          const AppLogo(size: 34),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      actions: <Widget>[
        ...actions,
        if (notifications != null)
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: notifications.titleFor(s.language),
            onPressed: () => context.push(notifications.path),
          ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
