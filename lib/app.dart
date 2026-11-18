import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env.dart';
import 'core/l10n/app_language.dart';
import 'core/l10n/app_strings.dart';
import 'core/l10n/language_provider.dart';
import 'core/router/app_router.dart';
import 'core/sync/sync_engine.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

class BdSportsApp extends ConsumerWidget {
  const BdSportsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start the background sync engine once for the whole app.
    ref.read(syncEngineProvider);

    final router = ref.watch(appRouterProvider);
    final language = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: Env.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.neonDay(),
      darkTheme: AppTheme.neonNight(),
      // Dark is the default (the approved design). The person can choose light or
      // "same as phone" in Profile > Appearance.
      themeMode: themeMode,
      locale: language.locale,
      supportedLocales: [
        for (final item in AppLanguage.values) item.locale,
      ],
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
