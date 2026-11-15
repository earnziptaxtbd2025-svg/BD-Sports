import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/account_role.dart';
import '../../../core/auth/current_user_provider.dart';
import '../../../core/config/env.dart';
import '../../../core/navigation/route_guard.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/home_button_if_root.dart';

/// Sign-in screen. Real sign-in (mobile number and code) is built in Step 1.1.
/// Development builds can sign in as a test person to try the screens.
class SignInPage extends ConsumerWidget {
  const SignInPage({super.key, this.from});

  /// Where to go after signing in. Checked by [safeReturnPath].
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        leading: homeButtonIfRoot(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.login, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Sign-in is built in Step 1.1.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          if (Env.devToolsEnabled) ...[
            const SizedBox(height: 32),
            Text('Developer sign-in', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final role in AccountRole.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilledButton.tonal(
                  onPressed: () {
                    ref.read(currentUserProvider.notifier).signInAs(role);
                    context.go(safeReturnPath(from) ?? AppRoutes.home);
                  },
                  child: Text('Sign in as ${role.label}'),
                ),
              ),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Continue without signing in'),
          ),
        ],
      ),
    );
  }
}
