import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/home_button_if_root.dart';
import '../../../core/widgets/state_view.dart';

/// Shown when a signed-in person opens a screen they are not allowed to use.
class NoAccessPage extends StatelessWidget {
  const NoAccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.noAccessTitle),
        leading: homeButtonIfRoot(context),
      ),
      body: StateView(
        icon: Icons.lock_outline,
        title: s.noAccessMessage,
        message: s.noAccessHint,
        actionLabel: s.goHome,
        onAction: () => context.go(AppRoutes.home),
      ),
    );
  }
}
