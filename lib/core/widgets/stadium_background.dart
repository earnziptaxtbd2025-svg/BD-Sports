import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';

/// Screen background: dark navy gradient, with the stadium photo on top when the
/// image file exists. A dark layer keeps the text readable over the photo.
///
/// Put it around the body of a screen: `StadiumBackground(child: ...)`.
class StadiumBackground extends StatelessWidget {
  const StadiumBackground({
    super.key,
    required this.child,
    this.imageAsset = AppAssets.stadiumBackground,
    this.darkness = 0.55,
  });

  final Widget child;

  /// Asset path of the photo. Empty means gradient only.
  final String? imageAsset;

  /// How much the photo is darkened, 0 (none) to 1 (black).
  final double darkness;

  @override
  Widget build(BuildContext context) {
    final String? path = imageAsset;
    final int alpha = (255 * darkness.clamp(0.0, 1.0)).round();

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppEffects.screenBackground),
        ),
        if (path != null)
          Image.asset(
            path,
            fit: BoxFit.cover,
            color: AppColors.bgDeep.withAlpha(alpha),
            colorBlendMode: BlendMode.srcOver,
            excludeFromSemantics: true,
            errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                const SizedBox.shrink(),
          ),
        child,
      ],
    );
  }
}
