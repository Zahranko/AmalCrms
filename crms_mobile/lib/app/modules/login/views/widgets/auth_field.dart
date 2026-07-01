import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Mirrors .field / .field__control in styles.css, including the
/// focus-within border + glow treatment.
class AuthField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
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
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hasFocus ? Colors.white : AppColors.fieldBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hasFocus ? AppColors.blue500 : AppColors.fieldBorder,
              width: 1.5,
            ),
            boxShadow: _hasFocus
                ? [BoxShadow(color: AppColors.blue500.withOpacity(0.14), blurRadius: 0, spreadRadius: 4)]
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(widget.icon, size: 18, color: AppColors.muted),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  style: const TextStyle(fontSize: 14.5, color: AppColors.ink),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  ),
                ),
              ),
              if (widget.suffix != null) widget.suffix!,
            ],
          ),
        ),
      ],
    );
  }
}
