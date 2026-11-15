import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_view.dart';

/// Shown for any address the app does not know.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  static const String message = 'This page does not exist.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: StateView(
        icon: Icons.search_off,
        title: message,
        actionLabel: 'Go to Home',
        onAction: () => context.go(AppRoutes.home),
      ),
    );
  }
}
