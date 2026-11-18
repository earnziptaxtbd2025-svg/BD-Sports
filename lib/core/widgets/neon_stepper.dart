import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Step indicator of multi-step forms (Create Tournament, Team Registration).
///
/// [currentStep] starts at 0. Finished steps show a tick, the current step glows,
/// the next steps are outlined.
class NeonStepper extends StatelessWidget {
  const NeonStepper({
    super.key,
    required this.labels,
    required this.currentStep,
  });

  final List<String> labels;
  final int currentStep;

  static const double _circle = 32;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final int count = labels.length;
    final int current =
        currentStep.clamp(0, count > 0 ? count - 1 : 0).toInt();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          Expanded(
            child: Semantics(
              container: true,
              label: '${i + 1} / $count: ${labels[i]}',
              selected: i == current,
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: _circle,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _Line(
                              visible: i > 0,
                              reached: i <= current,
                            ),
                          ),
                          _Dot(
                            number: i + 1,
                            done: i < current,
                            active: i == current,
                          ),
                          Expanded(
                            child: _Line(
                              visible: i < count - 1,
                              reached: i < current,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: i <= current ? p.textPrimary : p.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.visible, required this.reached});

  final bool visible;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      height: 2,
      color: !visible
          ? Colors.transparent
          : (reached ? AppColors.neonGreen : p.border),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.number, required this.done, required this.active});

  final int number;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Container(
      width: NeonStepper._circle,
      height: NeonStepper._circle,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: done || active ? AppEffects.buttonGreen : null,
        color: done || active ? null : p.bgBase,
        border: Border.all(
          color: done || active ? AppColors.neonGreen : p.border,
          width: 1.5,
        ),
        boxShadow: active
            ? AppEffects.glow(AppColors.neonGreen, strength: 0.8 * p.glowStrength)
            : null,
      ),
      child: done
          ? const Icon(Icons.check, size: 18, color: AppColors.textPrimary)
          : Text(
              '$number',
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                color: active ? AppColors.textPrimary : p.textSecondary,
              ),
            ),
    );
  }
}
