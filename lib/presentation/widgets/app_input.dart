import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Labeled text input (`.f` with `.l` label in the prototype).
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.suffixIcon,
    this.suffixOnTap,
    this.maxLength,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final VoidCallback? suffixOnTap;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
        SizedBox(
          height: kInputMinHeight,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            maxLength: maxLength,
            style: const TextStyle(
              fontSize: kFontSizeButton,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: kFontSizeButton,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
              ),
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      onPressed: suffixOnTap,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: suffixIcon!,
                    )
                  : null,
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}
