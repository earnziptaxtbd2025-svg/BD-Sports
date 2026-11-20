import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/auth/auth_repository.dart';
import 'core/auth/initial_user_provider.dart';
import 'core/auth/preview_auth_repository.dart';
import 'core/auth/profile_sync_handler.dart';
import 'core/auth/supabase_auth_repository.dart';
import 'core/auth/user_store.dart';
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

  // Find the person who was signed in last time, so the app opens signed in.
  final userStore = UserStore(prefs);
  final AuthRepository authRepository = Env.isSupabaseConfigured
      ? SupabaseAuthRepository(Supabase.instance.client, userStore)
      : PreviewAuthRepository(userStore);
  final restoredUser = authRepository.restoreUser();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        initialUserProvider.overrideWithValue(restoredUser),
        // Register one handler per offline action type here. Real handlers
        // (match score events, team registration, ...) are added with their features.
        syncHandlersProvider.overrideWith(
          (ref) => <String, SyncHandler>{
            if (Env.isSupabaseConfigured) ...{
              ProfileSyncHandler.type:
                  ProfileSyncHandler(Supabase.instance.client),
              ProfilePhotoSyncHandler.type:
                  ProfilePhotoSyncHandler(Supabase.instance.client),
            },
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
