import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A labelled dropdown with the same rounded "filled" look as AppTextField,
/// generic over the option value type (e.g. int ids or String enums) with a
/// nullable selection + placeholder hint.
class AppFormDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const AppFormDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
        const SizedBox(height: 8),
        Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.fieldBorder, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: Text(hint, style: const TextStyle(fontSize: 14.5, color: AppColors.muted)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
                style: const TextStyle(fontSize: 14.5, color: AppColors.ink, fontFamily: 'Poppins'),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(14),
                items: items,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
