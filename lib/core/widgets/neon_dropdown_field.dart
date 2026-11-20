import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Choice field in the style of [NeonTextField]: label above, rounded outline. Tapping
/// it opens a list from the bottom of the screen, which is easy to use on a phone.
///
/// If [clearLabel] is given, the list starts with a row that clears the choice.
class NeonDropdownField<T> extends StatelessWidget {
  const NeonDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.prefixIcon,
    this.clearLabel,
  });

  final String label;
  final T? value;
  final String? hint;
  final IconData? prefixIcon;
  final String? clearLabel;

  /// The choices: value and the text shown for it.
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;

  String? get _selectedText {
    for (final (T, String) item in items) {
      if (item.$1 == value) {
        return item.$2;
      }
    }
    return null;
  }

  Future<void> _open(BuildContext context) async {
    final AppPalette p = context.palette;
    final AppText t = context.appText;
    final String? clear = clearLabel;

    final _Pick<T>? picked = await showModalBottomSheet<_Pick<T>>(
      context: context,
      backgroundColor: p.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Text(label, style: t.heading),
                ),
                if (clear != null)
                  ListTile(
                    title: Text(clear, style: t.body.copyWith(color: p.textSecondary)),
                    trailing: value == null
                        ? Icon(Icons.check_circle, color: p.accent)
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(_Pick<T>(null)),
                  ),
                for (final (T, String) item in items)
                  ListTile(
                    title: Text(item.$2, style: t.body),
                    trailing: item.$1 == value
                        ? Icon(Icons.check_circle, color: p.accent)
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(_Pick<T>(item.$1)),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      onChanged(picked.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppText t = context.appText;
    final IconData? prefix = prefixIcon;
    final String? selected = _selectedText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.xs + 2,
          ),
          child: Text(
            label,
            style: t.caption.copyWith(
              color: p.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: label,
          value: selected ?? hint,
          excludeSemantics: true,
          onTap: () => _open(context),
          child: Material(
            color: p.surface,
            shape: StadiumBorder(side: BorderSide(color: p.border)),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => _open(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: <Widget>[
                      if (prefix != null) ...<Widget>[
                        Icon(prefix, color: p.textSecondary, size: 22),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: Text(
                          selected ?? hint ?? '',
                          style: t.body.copyWith(
                            color: selected == null ? p.textMuted : p.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: p.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// What the list returns. A wrapper, so "chosen nothing" and "list was closed" differ.
class _Pick<T> {
  const _Pick(this.value);

  final T? value;
}
