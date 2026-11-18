import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles of the design. Android's own Roboto is used. If a phone cannot show
/// Bangla, a bundled font is added in Step 0.5 part 4 and only [fontFamilyFallback]
/// changes.
class AppTextStyles {
  const AppTextStyles._();

  /// Tried in order when the main font lacks a letter.
  static const List<String> fontFamilyFallback = <String>['Noto Sans Bengali'];

  /// Big live score such as "2 - 1".
  static const TextStyle score = TextStyle(
    fontSize: 48,
    height: 1.1,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Screen title in the header.
  static const TextStyle title = TextStyle(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Card heading.
  static const TextStyle heading = TextStyle(
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Normal text.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Lighter secondary text.
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Button text.
  static const TextStyle button = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Small badge text such as "BAT" or "LIVE".
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Numbers in tables, aligned in columns.
  static const TextStyle tableNumber = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    fontFamilyFallback: fontFamilyFallback,
  );
}
