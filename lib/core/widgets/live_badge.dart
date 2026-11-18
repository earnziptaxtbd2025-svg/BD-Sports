import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Red "LIVE" badge with a blinking dot. Pass a translated [label] from the caller.
///
/// The blinking stops when the phone's "reduce animations" setting is on.
class LiveBadge extends StatefulWidget {
  const LiveBadge({super.key, this.label = 'LIVE'});

  final String label;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final Animation<double> _opacity =
      Tween<double>(begin: 0.3, end: 1).animate(_controller);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppEffects.buttonRed,
          borderRadius: AppRadius.pillAll,
          boxShadow: AppEffects.glow(AppColors.liveRed, strength: 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FadeTransition(
                opacity: _opacity,
                child: const Icon(
                  Icons.circle,
                  size: 8,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                widget.label,
                style: AppTextStyles.badge.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
