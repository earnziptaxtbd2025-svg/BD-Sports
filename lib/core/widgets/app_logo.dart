import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';

/// App logo. Shows `assets/images/logo.png` when it exists, otherwise a drawn shield
/// with a ball. [showName] adds "Bangladesh Sports Platform" and the tagline.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showName = false,
    this.imageAsset = AppAssets.logo,
  });

  final double size;
  final bool showName;

  /// The logo file. If it does not exist, a drawn shield is shown instead.
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppText t = context.appText;
    final Widget mark = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        imageAsset,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
            _FallbackMark(size: size),
      ),
    );

    if (!showName) {
      return Semantics(label: 'Bangladesh Sports Platform', child: mark);
    }

    return Semantics(
      label: 'Bangladesh Sports Platform',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          mark,
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Bangladesh', style: t.heading.copyWith(height: 1)),
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Sports ',
                      style: t.heading.copyWith(color: p.accent, height: 1.1),
                    ),
                    TextSpan(
                      text: 'Platform',
                      style: t.heading.copyWith(height: 1.1),
                    ),
                  ],
                ),
              ),
              Text(
                'Play • Organize • Connect',
                style: t.caption.copyWith(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallbackMark extends StatelessWidget {
  const _FallbackMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Icon(Icons.shield, size: size, color: AppColors.greenDeep),
        Icon(Icons.shield_outlined, size: size, color: AppColors.neonGreen),
        Icon(Icons.sports_soccer, size: size * 0.45, color: AppColors.textPrimary),
      ],
    );
  }
}
