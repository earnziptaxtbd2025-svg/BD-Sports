import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../security/input_validators.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Boxes for a code sent by SMS, one box per digit. The person taps the boxes and
/// types on the number keyboard. Bangla digits are turned into 0-9.
///
/// [onCompleted] runs once when the last digit is typed.
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
    this.enabled = true,
    this.hasError = false,
    this.semanticLabel = 'Code',
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  /// Draws red boxes.
  final bool hasError;
  final String semanticLabel;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final FocusNode _focus = FocusNode();
  String _lastReported = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(OtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    final text = widget.controller.text;
    if (text.length == widget.length && text != _lastReported) {
      _lastReported = text;
      widget.onCompleted?.call(text);
    } else if (text.length < widget.length) {
      _lastReported = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;

    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: SizedBox(
        height: 58,
        child: Stack(
          children: <Widget>[
            ExcludeSemantics(
              child: IgnorePointer(
                child: ListenableBuilder(
                  listenable: Listenable.merge(<Listenable>[widget.controller, _focus]),
                  builder: (BuildContext context, Widget? child) {
                    final String text = widget.controller.text;
                    return Row(
                      children: <Widget>[
                        for (int i = 0; i < widget.length; i++) ...<Widget>[
                          if (i > 0) const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _Box(
                              digit: i < text.length ? text[i] : '',
                              active: _focus.hasFocus &&
                                  widget.enabled &&
                                  i == (text.length < widget.length
                                      ? text.length
                                      : widget.length - 1),
                              error: widget.hasError,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enableInteractiveSelection: false,
                showCursor: false,
                autocorrect: false,
                enableSuggestions: false,
                // The typed text is hidden. The boxes above show the digits.
                style: const TextStyle(color: Color(0x00000000), fontSize: 1),
                cursorColor: const Color(0x00000000),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  counterText: '',
                  fillColor: p.surface,
                ),
                inputFormatters: <TextInputFormatter>[
                  _AsciiDigitsFormatter(widget.length),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.digit, required this.active, required this.error});

  final String digit;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final Color border =
        error ? p.danger : (active ? p.accent : p.border);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: border, width: active || error ? 2 : 1),
        boxShadow: active
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.neonGreen.withAlpha((70 * p.glowStrength).round()),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Text(
        digit,
        style: AppTextStyles.title.copyWith(color: p.textPrimary, fontSize: 24),
      ),
    );
  }
}

/// Keeps only digits, turns Bangla digits into 0-9 and stops at [length].
class _AsciiDigitsFormatter extends TextInputFormatter {
  _AsciiDigitsFormatter(this.length);

  final int length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = InputValidators.toAsciiDigits(newValue.text)
        .replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > length) {
      digits = digits.substring(0, length);
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
