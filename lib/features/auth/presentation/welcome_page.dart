import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/stadium_background.dart';
import 'profile_form.dart';

/// Shown once after the first sign-in: the person gives a name, photo, division and
/// role (Step 1.1).
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key, this.from});

  /// Where to go when done.
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final t = context.appText;
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(s.profileSetupHeading),
      ),
      body: StadiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const Center(child: AppLogo(size: 64)),
              const SizedBox(height: AppSpacing.md),
              Text(
                s.profileSetupHeading,
                textAlign: TextAlign.center,
                style: t.title.copyWith(fontSize: 26),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                s.profileSetupIntro,
                textAlign: TextAlign.center,
                style: t.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              ProfileForm(isSetup: true, from: from),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () async {
                    final router = GoRouter.of(context);
                    await ref.read(authControllerProvider).signOut();
                    router.go(AppRoutes.signIn);
                  },
                  child: Text(
                    s.profileUseOtherNumber,
                    style: TextStyle(color: p.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
