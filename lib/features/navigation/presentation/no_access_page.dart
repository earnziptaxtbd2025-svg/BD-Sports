import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/home_button_if_root.dart';
import '../../../core/widgets/state_view.dart';

/// Shown when a signed-in person opens a screen they are not allowed to use.
class NoAccessPage extends StatelessWidget {
  const NoAccessPage({super.key});

  static const String message = 'You do not have access to this screen.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No access'),
        leading: homeButtonIfRoot(context),
      ),
      body: StateView(
        icon: Icons.lock_outline,
        title: message,
        message: 'Ask the organizer for permission, or sign in with another account.',
        actionLabel: 'Go to Home',
        onAction: () => context.go(AppRoutes.home),
      ),
    );
  }
}
