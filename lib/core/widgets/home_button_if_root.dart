import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

/// Back arrow replacement for screens opened straight from a shared link, where
/// there is nothing to go back to. Returns null when a normal back arrow works.
Widget? homeButtonIfRoot(BuildContext context) {
  if (context.canPop()) {
    return null;
  }
  return IconButton(
    icon: const Icon(Icons.home_outlined),
    tooltip: 'Home',
    onPressed: () => context.go(AppRoutes.home),
  );
}
