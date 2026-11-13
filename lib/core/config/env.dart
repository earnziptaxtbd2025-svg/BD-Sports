/// Build-time configuration, injected with `--dart-define`.
///
/// Example:
/// flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///             --dart-define=SUPABASE_ANON_KEY=your-anon-key
class Env {
  const Env._();

  /// Working name. Change this in one place when the final name is chosen.
  static const String appName = 'BD Sports';

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
