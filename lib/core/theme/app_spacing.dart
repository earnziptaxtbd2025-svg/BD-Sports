import 'package:flutter/widgets.dart';

/// Spacing scale. Use these instead of loose numbers so every screen has the same rhythm.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Space at the left and right edge of every screen.
  static const double screenH = 12;

  /// Smallest tappable height. Android recommends 48; this is the app-wide floor.
  static const double minTap = 48;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: screenH);
  static const EdgeInsets card = EdgeInsets.all(md);
}

/// Corner radius scale. The design is rounded: cards are soft, buttons are pills.
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
