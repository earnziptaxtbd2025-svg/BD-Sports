import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/state_view.dart';

/// Shown for any address the app does not know.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s.pageNotFoundTitle)),
      body: StateView(
        icon: Icons.search_off,
        title: s.pageNotFoundMessage,
        actionLabel: s.goHome,
        onAction: () => context.go(AppRoutes.home),
      ),
    );
  }
}
