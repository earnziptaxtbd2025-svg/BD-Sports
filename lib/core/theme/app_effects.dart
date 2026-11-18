import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradients and glow shadows of the neon design.
class AppEffects {
  const AppEffects._();

  /// Neon glow around a card or button. [strength] is 0 (none) to 1 (full).
  static List<BoxShadow> glow(Color color, {double strength = 1}) {
    final double s = strength.clamp(0.0, 1.0).toDouble();
    if (s == 0) {
      return const <BoxShadow>[];
    }
    return <BoxShadow>[
      BoxShadow(
        color: color.withAlpha((90 * s).round()),
        blurRadius: 14,
        spreadRadius: 0.5,
      ),
    ];
  }

  // ---- Screen background ----
  static const LinearGradient screenBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.bgBase, AppColors.bgDeep],
  );

  // ---- Glass card fill ----
  static const LinearGradient glassCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xCC123068), Color(0xCC0B1E4A)],
  );

  // ---- Button fills (top, bottom) ----
  static const LinearGradient buttonGreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.neonGreen, AppColors.greenDeep],
  );
  static const LinearGradient buttonBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.electricBlue, AppColors.blueDeep],
  );
  static const LinearGradient buttonPurple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.purple, AppColors.purpleDeep],
  );
  static const LinearGradient buttonRed = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.liveRed, AppColors.redDeep],
  );

  // ---- Team side header fills (left blue, right red) ----
  static const LinearGradient teamBlueFill = LinearGradient(
    colors: <Color>[AppColors.blueDeep, AppColors.surface],
  );
  static const LinearGradient teamRedFill = LinearGradient(
    colors: <Color>[AppColors.redDeep, AppColors.surface],
  );
}
