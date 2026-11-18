import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_palette.dart';

/// Screen background: dark navy gradient, with the stadium photo on top when the
/// image file exists. A dark layer keeps the text readable over the photo.
///
/// Put it around the body of a screen: `StadiumBackground(child: ...)`.
class StadiumBackground extends StatelessWidget {
  const StadiumBackground({
    super.key,
    required this.child,
    this.imageAsset = AppAssets.stadiumBackground,
    this.darkness,
  });

  final Widget child;

  /// Asset path of the photo. Empty means gradient only.
  final String? imageAsset;

  /// How strongly the photo is covered by the screen colour, 0 (none) to 1 (fully).
  /// Empty means a good value for the dark look (0.55) or the light look (0.88).
  final double? darkness;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final String? path = imageAsset;
    final double cover = (darkness ?? (p.isDark ? 0.55 : 0.88)).clamp(0.0, 1.0).toDouble();
    final int alpha = (255 * cover).round();

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(decoration: BoxDecoration(gradient: p.screenGradient)),
        if (path != null)
          Image.asset(
            path,
            fit: BoxFit.cover,
            color: (p.isDark ? p.bgDeep : p.bgBase).withAlpha(alpha),
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
