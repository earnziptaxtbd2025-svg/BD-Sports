import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';

/// Whether Supabase keys were provided at build time.
final backendConfiguredProvider = Provider<bool>(
  (ref) => Env.isSupabaseConfigured,
);
