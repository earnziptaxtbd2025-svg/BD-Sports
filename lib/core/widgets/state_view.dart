import 'package:flutter/material.dart';

/// The one way to show loading, empty, error and offline states.
/// Every screen that loads data uses it, so the app feels the same everywhere.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  const StateView.loading({Key? key, String? message})
      : this(key: key, loading: true, message: message);

  const StateView.empty({
    Key? key,
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) : this(
          key: key,
          icon: Icons.inbox_outlined,
          title: title,
          message: message,
          actionLabel: actionLabel,
          onAction: onAction,
        );

  const StateView.error({
    Key? key,
    String title = 'Something went wrong',
    String? message,
    VoidCallback? onRetry,
  }) : this(
          key: key,
          icon: Icons.error_outline,
          title: title,
          message: message,
          actionLabel: onRetry == null ? null : 'Try again',
          onAction: onRetry,
        );

  const StateView.offline({Key? key, String? message})
      : this(
          key: key,
          icon: Icons.cloud_off_outlined,
          title: 'You are offline',
          message: message ??
              'Showing saved information. It updates when the internet is back.',
        );

  final IconData? icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator()
            else if (icon != null)
              Icon(icon, size: 56, color: theme.colorScheme.primary),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
