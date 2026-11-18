import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Sizes and weights of the text styles, without colour.
///
/// In a widget use `context.appText.body` (coloured for the current dark or light
/// look). Use this class only to build a new coloured style.
/// Android's own Roboto is used. If a phone cannot show Bangla, a bundled font is
/// added later and only [fontFamilyFallback] changes.
class AppTextStyles {
  const AppTextStyles._();

  /// Tried in order when the main font lacks a letter.
  static const List<String> fontFamilyFallback = <String>['Noto Sans Bengali'];

  /// Big live score such as "2 - 1".
  static const TextStyle score = TextStyle(
    fontSize: 48,
    height: 1.1,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Screen title in the header.
  static const TextStyle title = TextStyle(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Card heading.
  static const TextStyle heading = TextStyle(
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Normal text.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w400,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Lighter secondary text.
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w400,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Button text.
  static const TextStyle button = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Small badge text such as "BAT" or "LIVE".
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Numbers in tables, aligned in columns.
  static const TextStyle tableNumber = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    fontFamilyFallback: fontFamilyFallback,
  );
}

/// The text styles coloured for one palette (dark or light).
class AppText {
  const AppText(this.palette);

  final AppPalette palette;

  TextStyle get score => AppTextStyles.score.copyWith(color: palette.textPrimary);
  TextStyle get title => AppTextStyles.title.copyWith(color: palette.textPrimary);
  TextStyle get heading => AppTextStyles.heading.copyWith(color: palette.textPrimary);
  TextStyle get body => AppTextStyles.body.copyWith(color: palette.textPrimary);
  TextStyle get caption =>
      AppTextStyles.caption.copyWith(color: palette.textSecondary);
  TextStyle get button => AppTextStyles.button.copyWith(color: palette.textPrimary);
  TextStyle get badge => AppTextStyles.badge.copyWith(color: palette.textPrimary);
  TextStyle get tableNumber =>
      AppTextStyles.tableNumber.copyWith(color: palette.textPrimary);
}

extension AppTextContext on BuildContext {
  /// Text styles for the current look: `context.appText.heading`.
  AppText get appText => AppText(palette);
}
