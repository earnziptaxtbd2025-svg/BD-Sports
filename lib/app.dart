import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env.dart';
import 'core/router/app_router.dart';
import 'core/sync/sync_engine.dart';
import 'core/theme/app_theme.dart';

class BdSportsApp extends ConsumerWidget {
  const BdSportsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start the background sync engine once for the whole app.
    ref.read(syncEngineProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: Env.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Light (white and green) for everyone. Dark mode becomes a user setting in
      // Step 1B.13, so the app does not change just because the phone is in dark mode.
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
