import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/account_role.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/auth/current_user_provider.dart';
import '../../../core/config/env.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/route_guard.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/security/input_validators.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/home_button_if_root.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/neon_text_field.dart';
import '../../../core/widgets/stadium_background.dart';
import 'auth_messages.dart';

/// Sign-in screen (Step 1.1): the person types a mobile number and gets a code by SMS.
/// Development builds can also sign in as a test person to try the screens.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key, this.from});

  /// Where to go after signing in. Checked by [safeReturnPath].
  final String? from;

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final s = context.s;
    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider).sendCode(_phone.text);
      if (!mounted) {
        return;
      }
      final phone = InputValidators.normalizeBdPhone(_phone.text);
      final from = widget.from;
      context.push(
        Uri(
          path: AppRoutes.verify,
          queryParameters: <String, String>{
            if (phone != null) 'phone': phone,
            if (from != null) 'from': from,
          },
        ).toString(),
      );
    } on AppAuthException catch (error) {
      if (mounted) {
        setState(() => _error = authFailureText(s, error.failure));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = s.authSomethingWrong);
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final p = context.palette;
    final t = context.appText;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: homeButtonIfRoot(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: s.languageTitle,
            onPressed: () => context.push(AppRoutes.language),
          ),
        ],
      ),
      body: StadiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              const Center(child: AppLogo(size: 96)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                s.authWelcomeBack,
                textAlign: TextAlign.center,
                style: t.title.copyWith(fontSize: 28, color: p.accent),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.authSignInSubtitle,
                textAlign: TextAlign.center,
                style: t.caption,
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassCard(
                glowColor: p.accent,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NeonTextField(
                        label: s.authPhoneLabel,
                        hint: s.authPhoneHint,
                        controller: _phone,
                        prefixIcon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        isRequired: true,
                        enabled: !_sending,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9০-৯+\s-]'),
                          ),
                          LengthLimitingTextInputFormatter(18),
                        ],
                        validator: (value) {
                          final issue = InputValidators.validatePhone(value);
                          return issue == null ? null : s.validation(issue);
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _error!,
                          style: t.caption.copyWith(color: p.danger),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      NeonButton(
                        label: s.authSendCode,
                        icon: Icons.sms_outlined,
                        isLoading: _sending,
                        onPressed: _send,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                s.authTermsNote,
                textAlign: TextAlign.center,
                style: t.caption.copyWith(fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(s.continueWithoutSigningIn),
              ),
              if (Env.devToolsEnabled) ...[
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Developer sign-in', style: t.heading),
                      const SizedBox(height: AppSpacing.sm),
                      for (final role in AccountRole.values)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: NeonButton(
                            label: 'Sign in as ${role.label}',
                            style: NeonButtonStyle.outline,
                            onPressed: () {
                              ref.read(currentUserProvider.notifier).signInAs(role);
                              context.go(safeReturnPath(widget.from) ?? AppRoutes.home);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
