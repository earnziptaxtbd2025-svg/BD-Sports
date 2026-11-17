import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

enum _StateKind { custom, loading, error, offline }

/// The one way to show loading, empty, error and offline states.
/// Every screen that loads data uses it, so the app feels the same everywhere.
/// Default texts follow the app language.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  }) : _kind = _StateKind.custom;

  const StateView.loading({super.key, this.message})
      : _kind = _StateKind.loading,
        icon = null,
        title = null,
        actionLabel = null,
        onAction = null;

  const StateView.empty({
    super.key,
    required String this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  })  : _kind = _StateKind.custom,
        icon = Icons.inbox_outlined;

  /// [title] and [message] default to a general text in the app language.
  /// A "Try again" button shows only when [onRetry] is given.
  const StateView.error({super.key, this.title, this.message, VoidCallback? onRetry})
      : _kind = _StateKind.error,
        icon = Icons.error_outline,
        actionLabel = null,
        onAction = onRetry;

  const StateView.offline({super.key, this.message})
      : _kind = _StateKind.offline,
        icon = Icons.cloud_off_outlined,
        title = null,
        actionLabel = null,
        onAction = null;

  final _StateKind _kind;
  final IconData? icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.s;

    final shownTitle = switch (_kind) {
      _StateKind.error => title ?? s.errorTitle,
      _StateKind.offline => s.offlineTitle,
      _ => title,
    };
    final shownMessage = _kind == _StateKind.offline
        ? (message ?? s.offlineMessage)
        : message;
    final shownAction = _kind == _StateKind.error && onAction != null
        ? s.tryAgain
        : actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_kind == _StateKind.loading)
              const CircularProgressIndicator()
            else if (icon != null)
              Icon(icon, size: 56, color: theme.colorScheme.primary),
            if (shownTitle != null) ...[
              const SizedBox(height: 16),
              Text(
                shownTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
            if (shownMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                shownMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (shownAction != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(shownAction)),
            ],
          ],
        ),
      ),
    );
  }
}
