import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';

/// Round team badge showing the team's first letters. It is used until a team has
/// uploaded its own logo. Pass the team side colour with [color].
class TeamCrest extends StatelessWidget {
  const TeamCrest({
    super.key,
    required this.name,
    this.size = 56,
    this.color = AppColors.teamBlue,
  });

  final String name;
  final double size;
  final Color color;

  /// First letter of up to two words, e.g. "Rangpur FC" gives "RF".
  static String initials(String name) {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return '?';
    }
    final String first = String.fromCharCode(words.first.runes.first);
    if (words.length == 1) {
      return first.toUpperCase();
    }
    final String second = String.fromCharCode(words[1].runes.first);
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.palette.surface,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        initials(name),
        style: context.appText.heading.copyWith(fontSize: size * 0.34),
      ),
    );
  }
}
