import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_user.dart';

/// The person found signed in when the app starts. Set in main() from the saved
/// session. Empty in tests.
final initialUserProvider = Provider<AppUser?>((ref) => null);
