import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/storage/shared_preferences_provider.dart';
import 'core/sync/sync_handler.dart';
import 'features/dev_tools/data/demo_sync_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // The backend is optional at this stage so the app always starts, even
  // before Supabase keys are provided (see README.md).
  if (Env.isSupabaseConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Register one handler per offline action type here. Real handlers
        // (match score events, team registration, ...) are added with their features.
        syncHandlersProvider.overrideWith(
          (ref) => <String, SyncHandler>{
            if (Env.devToolsEnabled)
              DemoSyncHandler.type: DemoSyncHandler(
                () => ref.read(fakeServerModeProvider),
              ),
          },
        ),
      ],
      child: const BdSportsApp(),
    ),
  );
}
