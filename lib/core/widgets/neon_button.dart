import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Colour style of a [NeonButton]. Meaning: green = main action, blue = secondary,
/// purple = share or submit, red = danger or stop, outline = quiet action.
enum NeonButtonStyle { green, blue, purple, red, outline }

/// Pill-shaped glowing button of the design.
///
/// - [onPressed] null: the button is disabled (dim, no glow, no tap).
/// - [isLoading] true: shows a spinner and ignores taps (stops double submit).
/// - [subLabel]: small second line, e.g. "Before Match Start".
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = NeonButtonStyle.green,
    this.icon,
    this.subLabel,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final NeonButtonStyle style;
  final IconData? icon;
  final String? subLabel;
  final bool isLoading;

  /// true: fills the available width. false: only as wide as its content.
  final bool expand;

  static const double _height = 52;

  Gradient? get _gradient {
    switch (style) {
      case NeonButtonStyle.green:
        return AppEffects.buttonGreen;
      case NeonButtonStyle.blue:
        return AppEffects.buttonBlue;
      case NeonButtonStyle.purple:
        return AppEffects.buttonPurple;
      case NeonButtonStyle.red:
        return AppEffects.buttonRed;
      case NeonButtonStyle.outline:
        return null;
    }
  }

  Color get _glowColor {
    switch (style) {
      case NeonButtonStyle.green:
        return AppColors.neonGreen;
      case NeonButtonStyle.blue:
        return AppColors.electricBlue;
      case NeonButtonStyle.purple:
        return AppColors.purple;
      case NeonButtonStyle.red:
        return AppColors.liveRed;
      case NeonButtonStyle.outline:
        return AppColors.cyan;
    }
  }

  Color get _borderColor {
    switch (style) {
      case NeonButtonStyle.green:
        return AppColors.borderGreen;
      case NeonButtonStyle.blue:
        return AppColors.borderBlue;
      case NeonButtonStyle.purple:
        return AppColors.purple;
      case NeonButtonStyle.red:
        return AppColors.borderRed;
      case NeonButtonStyle.outline:
        return AppColors.borderCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;
    final bool tappable = !disabled && !isLoading;
    final String? second = subLabel;

    final Widget leading = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.textPrimary,
            ),
          )
        : (icon == null
            ? const SizedBox.shrink()
            : Icon(icon, size: 22, color: AppColors.textPrimary));

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading || icon != null) ...<Widget>[
          leading,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: AppTextStyles.button,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (second != null)
                Text(
                  second,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ],
    );

    final Widget button = Opacity(
      opacity: disabled ? 0.45 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _gradient,
          color: _gradient == null ? AppColors.surface : null,
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: _borderColor),
          boxShadow: disabled || style == NeonButtonStyle.outline
              ? null
              : AppEffects.glow(_glowColor, strength: 0.8),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: tappable ? onPressed : null,
            borderRadius: AppRadius.pillAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _height),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                child: Center(widthFactor: 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: tappable,
      label: label,
      excludeSemantics: true,
      onTap: tappable ? onPressed : null,
      child: expand
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
