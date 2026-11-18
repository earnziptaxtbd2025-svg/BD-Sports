import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';

/// Dark glass-style card with a thin neon outline. The base container of the design.
///
/// Give [glowColor] to make the edge glow (for a live or highlighted card). Give
/// [onTap] to make the whole card tappable.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.borderColor = AppColors.borderCyan,
    this.glowColor,
    this.fill = AppEffects.glassCard,
    this.radius = AppRadius.lgAll,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  /// When set, a soft glow of this colour is drawn around the card.
  final Color? glowColor;
  final Gradient fill;
  final BorderRadius radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color? glow = glowColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: fill,
        borderRadius: radius,
        border: Border.all(color: borderColor),
        boxShadow: glow == null ? null : AppEffects.glow(glow, strength: 0.6),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
