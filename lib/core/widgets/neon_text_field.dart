import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
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

  OutlineInputBorder _border(Color color, {double width = 1}) {
    final double radius = maxLines > 1 ? AppRadius.lg : AppRadius.pill;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IconData? prefix = prefixIcon;

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
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              children: <InlineSpan>[
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.liveRed),
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
          style: AppTextStyles.body,
          cursorColor: AppColors.neonGreen,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            errorText: errorText,
            errorStyle: const TextStyle(color: AppColors.liveRed),
            counterStyle: AppTextStyles.caption,
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md + 2,
            ),
            prefixIcon: prefix == null
                ? null
                : Icon(prefix, color: AppColors.textSecondary, size: 22),
            suffixIcon: suffix,
            border: _border(AppColors.borderCyan),
            enabledBorder: _border(AppColors.borderCyan),
            disabledBorder: _border(AppColors.divider),
            focusedBorder: _border(AppColors.neonGreen, width: 1.5),
            errorBorder: _border(AppColors.liveRed),
            focusedErrorBorder: _border(AppColors.liveRed, width: 1.5),
          ),
        ),
      ],
    );
  }
}
