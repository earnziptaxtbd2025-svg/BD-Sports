import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// App logo. Shows `assets/images/logo.png` when it exists, otherwise a drawn shield
/// with a ball. [showName] adds "Bangladesh Sports Platform" and the tagline.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56, this.showName = false});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final Widget mark = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        AppAssets.logo,
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
              Text('Bangladesh', style: AppTextStyles.heading.copyWith(height: 1)),
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Sports ',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.neonGreen,
                        height: 1.1,
                      ),
                    ),
                    TextSpan(
                      text: 'Platform',
                      style: AppTextStyles.heading.copyWith(height: 1.1),
                    ),
                  ],
                ),
              ),
              Text(
                'Play • Organize • Connect',
                style: AppTextStyles.caption.copyWith(
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
