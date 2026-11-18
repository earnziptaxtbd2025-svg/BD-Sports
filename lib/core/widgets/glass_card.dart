import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

/// Glass-style card with a thin neon outline (dark) or a clean white card (light). The
/// base container of the design.
///
/// Give [glowColor] to make the edge glow (for a live or highlighted card). Give
/// [onTap] to make the whole card tappable.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.borderColor,
    this.glowColor,
    this.fill,
    this.radius = AppRadius.lgAll,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Outline colour. Empty means the palette's normal outline.
  final Color? borderColor;

  /// When set, a soft glow of this colour is drawn around the card.
  final Color? glowColor;

  /// Background fill. Empty means the palette's glass fill.
  final Gradient? fill;
  final BorderRadius radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Color? glow = glowColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: fill ?? p.glassGradient,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? p.border),
        boxShadow: glow == null
            ? null
            : AppEffects.glow(glow, strength: 0.6 * p.glowStrength),
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
