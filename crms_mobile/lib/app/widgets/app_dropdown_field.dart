import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Same rounded "filled" container as AppTextField, wrapping a dropdown.
class AppDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  // Optional display labels parallel to `options` (e.g. "Hospital Manager"
  // for the value "HospitalManager"). Falls back to the raw option string.
  final List<String>? optionLabels;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.optionLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.fieldBorder, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
              style: const TextStyle(fontSize: 14.5, color: AppColors.ink, fontFamily: 'Poppins'),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
              items: options
                  .asMap()
                  .entries
                  .map((e) => DropdownMenuItem(value: e.value, child: Text(optionLabels?[e.key] ?? e.value)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
