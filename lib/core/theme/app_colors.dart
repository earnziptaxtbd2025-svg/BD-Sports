import 'package:flutter/material.dart';

/// Colour palette of the "stadium night" design (Step 0.5, part 1).
///
/// Every colour used by the neon dark design lives here, so a colour is changed in
/// one place only. Screens must use these names and never write raw colour values.
class AppColors {
  const AppColors._();

  // ---- Backgrounds (dark navy, darkest first) ----
  static const Color bgDeep = Color(0xFF040B1F);
  static const Color bgBase = Color(0xFF071433);
  static const Color surface = Color(0xFF0B1E4A);
  static const Color surfaceRaised = Color(0xFF123068);

  // ---- Brand and action colours (bright colour, then its deeper shade) ----
  static const Color neonGreen = Color(0xFF22E55C);
  static const Color greenDeep = Color(0xFF0B8F3A);
  static const Color electricBlue = Color(0xFF2F6BFF);
  static const Color blueDeep = Color(0xFF1A3FA8);
  static const Color purple = Color(0xFF7B3FF2);
  static const Color purpleDeep = Color(0xFF4B1FA8);

  // ---- Team sides: left team is blue, right team is red ----
  static const Color teamBlue = electricBlue;
  static const Color teamRed = Color(0xFFE5262F);
  static const Color redDeep = Color(0xFF8E1119);

  // ---- Highlights ----
  /// Trophy, captain, money, target.
  static const Color gold = Color(0xFFFFC928);

  /// Bowler badge, substitution arrows.
  static const Color orange = Color(0xFFF08A24);

  /// LIVE badge and live scoring.
  static const Color liveRed = Color(0xFFFF2D3D);

  /// Thin glass-card outlines and info accents.
  static const Color cyan = Color(0xFF35B8E8);

  // ---- Text ----
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8C4E0);
  static const Color textMuted = Color(0xFF7F8DB0);

  // ---- Outlines (colour with transparency) ----
  static const Color borderCyan = Color(0x6635B8E8);
  static const Color borderGreen = Color(0x9922E55C);
  static const Color borderBlue = Color(0x802F6BFF);
  static const Color borderRed = Color(0x80E5262F);
  static const Color divider = Color(0x3335B8E8);

  // ---- Meaning colours ----
  static const Color success = neonGreen;
  static const Color warning = gold;
  static const Color danger = liveRed;
  static const Color info = cyan;
}
