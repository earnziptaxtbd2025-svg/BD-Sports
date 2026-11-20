import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';

/// Round profile picture: the person's photo, or the first letter of the name, or a
/// person icon when there is no name yet.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.name = '', this.photo, this.size = 56});

  final String name;
  final Uint8List? photo;
  final double size;

  /// First letter of the name, or empty.
  static String initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Uint8List? bytes = photo;
    final String letter = initial(name);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surfaceRaised,
        border: Border.all(color: p.accent, width: 2),
        image: bytes == null
            ? null
            : DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
      ),
      child: bytes != null
          ? null
          : (letter.isEmpty
              ? Icon(Icons.person_outline, color: p.accent, size: size * 0.55)
              : Text(
                  letter,
                  style: context.appText.title.copyWith(
                    fontSize: size * 0.42,
                    color: p.accent,
                  ),
                )),
    );
  }
}
