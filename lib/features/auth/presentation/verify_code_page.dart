import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/route_guard.dart';
import '../../../core/providers/backend_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/security/input_validators.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/otp_field.dart';
import '../../../core/widgets/stadium_background.dart';
import 'auth_messages.dart';

/// Second sign-in step (Step 1.1): the person types the 6-digit code from the SMS.
/// The code is checked as soon as the last digit is typed.
class VerifyCodePage extends ConsumerStatefulWidget {
  const VerifyCodePage({super.key, required this.phone, this.from});

  /// The mobile number in the form +8801XXXXXXXXX.
  final String? phone;

  /// Where to go after signing in. Checked by [safeReturnPath].
  final String? from;

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  static const int _codeLength = 6;
  static const int _cooldownSeconds = 60;

  final TextEditingController _code = TextEditingController();
  Timer? _timer;
  int _seconds = _cooldownSeconds;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  String? get _phone {
    final value = widget.phone;
    return value == null ? null : InputValidators.normalizeBdPhone(value);
  }

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _code.addListener(() => setState(() {}));
    if (_phone == null) {
      // No valid number: go back to the first step.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutes.signIn);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    _seconds = _cooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _seconds--);
      if (_seconds <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _verify(String code) async {
    final phone = _phone;
    if (_verifying || phone == null || code.length != _codeLength) {
      return;
    }

    final s = context.s;
    final router = GoRouter.of(context);
    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final outcome = await ref.read(authControllerProvider).verify(phone, code);
      if (!mounted) {
        return;
      }
      final back = safeReturnPath(widget.from);
      if (outcome.isNewUser) {
        router.go(
          Uri(
            path: AppRoutes.welcome,
            queryParameters: <String, String>{if (back != null) 'from': back},
          ).toString(),
        );
      } else {
        router.go(back ?? AppRoutes.home);
      }
    } on AppAuthException catch (error) {
      if (mounted) {
        setState(() {
          _error = authFailureText(s, error.failure);
          _verifying = false;
        });
        _code.clear();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = s.authSomethingWrong;
          _verifying = false;
        });
        _code.clear();
      }
    }
  }

  Future<void> _resend() async {
    final phone = _phone;
    if (_resending || _seconds > 0 || phone == null) {
      return;
    }

    final s = context.s;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider).sendCode(phone);
      if (!mounted) {
        return;
      }
      _code.clear();
      _startCooldown();
      messenger.showSnackBar(SnackBar(content: Text(s.authCodeResent)));
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
        setState(() => _resending = false);
      }
    }
  }

  void _changeNumber() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final p = context.palette;
    final t = context.appText;
    final configured = ref.watch(backendConfiguredProvider);
    final phone = _phone ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(s.authVerifyHeading)),
      body: StadiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.accent.withAlpha(p.isDark ? 32 : 26),
                    border: Border.all(color: p.accent, width: 2),
                  ),
                  child: Icon(Icons.sms_outlined, color: p.accent, size: 36),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                s.authVerifyHeading,
                textAlign: TextAlign.center,
                style: t.title.copyWith(fontSize: 26),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.authCodeSentTo(phone),
                textAlign: TextAlign.center,
                style: t.caption,
              ),
              const SizedBox(height: AppSpacing.xl),
              OtpField(
                controller: _code,
                length: _codeLength,
                enabled: !_verifying,
                hasError: _error != null,
                semanticLabel: s.authVerifyHeading,
                onCompleted: _verify,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: t.caption.copyWith(color: p.danger),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              NeonButton(
                label: s.authVerify,
                icon: Icons.verified_outlined,
                isLoading: _verifying,
                onPressed: _code.text.length == _codeLength
                    ? () => _verify(_code.text)
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: _seconds > 0
                    ? Text(s.authResendIn(_seconds), style: t.caption)
                    : TextButton(
                        onPressed: _resending ? null : _resend,
                        child: Text(s.authResend),
                      ),
              ),
              Center(
                child: TextButton(
                  onPressed: _changeNumber,
                  child: Text(s.authChangeNumber),
                ),
              ),
              if (!configured) ...[
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: p.cyanText),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(s.authPreviewHint, style: t.caption)),
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
