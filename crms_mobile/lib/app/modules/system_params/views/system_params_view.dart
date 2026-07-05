import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/website_setting.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_top_bar.dart';
import '../controllers/system_params_controller.dart';

/// Mirrors systemParams.html — a per-website key/value editor (Admin only).
class SystemParamsView extends StatelessWidget {
  const SystemParamsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SystemParamsController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppTopBar(),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.loadError.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(controller.loadError.value!, style: const TextStyle(color: AppColors.error)),
            ),
          );
        }
        return _ParamsEditor(controller: controller);
      }),
    );
  }
}

class _ParamsEditor extends StatefulWidget {
  final SystemParamsController controller;
  const _ParamsEditor({required this.controller});

  @override
  State<_ParamsEditor> createState() => _ParamsEditorState();
}

class _Row {
  final TextEditingController key;
  final TextEditingController value;
  _Row(String k, String v)
      : key = TextEditingController(text: k),
        value = TextEditingController(text: v);
  void dispose() {
    key.dispose();
    value.dispose();
  }
}

class _ParamsEditorState extends State<_ParamsEditor> {
  late List<_Row> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.controller.settings.map((s) => _Row(s.key, s.value)).toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_Row('', '')));

  void _removeRow(int i) => setState(() => _rows.removeAt(i).dispose());

  Future<void> _save() async {
    final incoming = _rows.map((r) => WebsiteSetting(key: r.key.text, value: r.value.text)).toList();
    await widget.controller.save(incoming);
  }

  @override
  Widget build(BuildContext context) {
    final website = Get.find<AuthController>().activeWebsite.value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('systemParams.title'.tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navy900)),
        const SizedBox(height: 4),
        Text(
          '${'systemParams.subtitle'.tr} ${website?.name ?? ''}',
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final err = widget.controller.saveError.value;
          if (err == null) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Text(err, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
          );
        }),
        if (_rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('systemParams.empty'.tr, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          ),
        ..._rows.asMap().entries.map((e) => _buildRow(e.key, e.value)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add, size: 18),
          label: Text('systemParams.add'.tr),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final saving = widget.controller.isSaving.value;
          return Row(
            children: [
              FilledButton(
                onPressed: saving ? null : _save,
                style: FilledButton.styleFrom(backgroundColor: AppColors.blue500),
                child: saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('action.save'.tr),
              ),
              const SizedBox(width: 12),
              if (widget.controller.saved.value)
                Text('systemParams.saved'.tr, style: const TextStyle(color: Color(0xFF1F9D55), fontWeight: FontWeight.w600)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRow(int index, _Row row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              controller: row.key,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'systemParams.key'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: TextField(
              controller: row.value,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'systemParams.value'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error),
            onPressed: () => _removeRow(index),
            tooltip: 'action.delete'.tr,
          ),
        ],
      ),
    );
  }
}
