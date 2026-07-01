import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Generalized version of AuthField's rounded "filled" look (label above +
/// soft border + focus glow) for use in dialogs/forms outside the login
/// screen, where an icon isn't always wanted.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.maxLines = 1,
    this.suffix,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _hasFocus = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hasFocus ? Colors.white : AppColors.fieldBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hasFocus ? AppColors.blue500 : AppColors.fieldBorder, width: 1.5),
            boxShadow: _hasFocus
                ? [BoxShadow(color: AppColors.blue500.withOpacity(0.14), blurRadius: 0, spreadRadius: 4)]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 14, right: widget.suffix != null ? 4 : 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    autofocus: widget.autofocus,
                    keyboardType: widget.keyboardType,
                    maxLines: widget.maxLines,
                    onSubmitted: widget.onSubmitted,
                    style: const TextStyle(fontSize: 14.5, color: AppColors.ink),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                if (widget.suffix != null) widget.suffix!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
