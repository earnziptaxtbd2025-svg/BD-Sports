import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Input field of the design: label above, rounded neon outline, optional icon.
///
/// Works inside a [Form]: [validator] runs on `formKey.currentState!.validate()`.
/// A one-line field is a pill; a multi-line field ([maxLines] above 1) is a rounded
/// box.
class NeonTextField extends StatelessWidget {
  const NeonTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.isRequired = false,
    this.maxLength,
    this.maxLines = 1,
    this.errorText,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;

  /// true: a red star is shown after the label.
  final bool isRequired;
  final int? maxLength;
  final int maxLines;

  /// Error text from outside (e.g. from the server). The validator also shows errors.
  final String? errorText;

  static OutlineInputBorder _border(
    bool pill,
    Color color, {
    double width = 1,
  }) {
    final double radius = pill ? AppRadius.pill : AppRadius.lg;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppText t = context.appText;
    final IconData? prefix = prefixIcon;
    final bool pill = maxLines <= 1 || obscureText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.xs + 2,
          ),
          child: Text.rich(
            TextSpan(
              text: label,
              style: t.caption.copyWith(
                color: p.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              children: <InlineSpan>[
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: p.danger),
                  ),
              ],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          maxLength: maxLength,
          maxLines: obscureText ? 1 : maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          style: t.body,
          cursorColor: p.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: t.body.copyWith(color: p.textMuted),
            errorText: errorText,
            errorStyle: TextStyle(color: p.danger),
            counterStyle: t.caption,
            filled: true,
            fillColor: p.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md + 2,
            ),
            prefixIcon: prefix == null
                ? null
                : Icon(prefix, color: p.textSecondary, size: 22),
            suffixIcon: suffix,
            border: _border(pill, p.border),
            enabledBorder: _border(pill, p.border),
            disabledBorder: _border(pill, p.divider),
            focusedBorder: _border(pill, p.accent, width: 1.5),
            errorBorder: _border(pill, p.danger),
            focusedErrorBorder: _border(pill, p.danger, width: 1.5),
          ),
        ),
      ],
    );
  }
}
