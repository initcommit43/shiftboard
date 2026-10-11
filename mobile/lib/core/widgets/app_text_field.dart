import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// A text input with its label above; the look comes from the input theme.
///
/// With [obscure] it becomes a password field with a visibility toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.maxLength,
    this.obscure = false,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;

  /// An error that does not come from [validator], such as one from the API.
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  /// For a value that is picked instead of typed; [onTap] opens the picker.
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final bool obscure;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The field announces the label itself.
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: AppTypography.subhead.copyWith(color: colors.inkSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: widget.label,
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            validator: widget.validator,
            forceErrorText: widget.errorText,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            autofillHints: widget.autofillHints,
            autocorrect: false,
            enableSuggestions: !widget.obscure,
            obscureText: _hidden,
            inputFormatters: [
              if (widget.maxLength case final maxLength?)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style: AppTypography.body.copyWith(
              color: widget.enabled ? colors.ink : colors.inkDisabled,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              suffixIcon: widget.obscure
                  ? IconButton(
                      onPressed: () => setState(() => _hidden = !_hidden),
                      tooltip: _hidden ? l10n.passwordShow : l10n.passwordHide,
                      icon: Icon(
                        _hidden ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
