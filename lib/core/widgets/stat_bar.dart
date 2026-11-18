import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// One match statistic compared between two teams: numbers on both sides and a
/// bar split by size (e.g. Possession 58 / 42). Left team is green, right is blue.
class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.homeValue,
    required this.awayValue,
    this.suffix = '',
  });

  final String label;
  final double homeValue;
  final double awayValue;

  /// Text after each number, e.g. "%".
  final String suffix;

  /// Bar part sizes. A value below 0 counts as 0. Both 0 gives an even split. Each
  /// side keeps at least a thin part so the bar never looks empty.
  @visibleForTesting
  static (int home, int away) flexes(double home, double away) {
    final double h = math.max(0, home);
    final double a = math.max(0, away);
    final double total = h + a;
    if (total <= 0) {
      return (1, 1);
    }
    final int homeFlex = math.max(1, (h / total * 1000).round());
    final int awayFlex = math.max(1, (a / total * 1000).round());
    return (homeFlex, awayFlex);
  }

  String _format(double v) =>
      '${v == v.roundToDouble() ? v.round() : v.toStringAsFixed(1)}$suffix';

  @override
  Widget build(BuildContext context) {
    final AppText t = context.appText;
    final (int homeFlex, int awayFlex) = flexes(homeValue, awayValue);

    return Semantics(
      container: true,
      label: '$label: ${_format(homeValue)} - ${_format(awayValue)}',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(_format(homeValue), style: t.tableNumber),
                Expanded(
                  child: Text(
                    label,
                    style: t.caption,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(_format(awayValue), style: t.tableNumber),
              ],
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: SizedBox(
                height: 6,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: homeFlex,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppEffects.buttonGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: awayFlex,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
