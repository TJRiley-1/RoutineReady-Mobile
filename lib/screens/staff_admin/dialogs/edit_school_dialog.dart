import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/staff_admin_provider.dart';

class EditSchoolDialog extends ConsumerStatefulWidget {
  final String orgId;
  final Map<String, dynamic>? school;

  const EditSchoolDialog({super.key, required this.orgId, this.school});

  @override
  ConsumerState<EditSchoolDialog> createState() => _EditSchoolDialogState();
}

class _EditSchoolDialogState extends ConsumerState<EditSchoolDialog> {
  late final TextEditingController _schoolNameController;
  late final TextEditingController _classNameController;
  late final TextEditingController _teacherNameController;
  late final TextEditingController _deviceNameController;
  bool _loading = false;

  bool get _isEditing => widget.school != null;

  @override
  void initState() {
    super.initState();
    _schoolNameController = TextEditingController(
      text: widget.school?['school_name'] as String? ?? '',
    );
    _classNameController = TextEditingController(
      text: widget.school?['class_name'] as String? ?? '',
    );
    _teacherNameController = TextEditingController(
      text: widget.school?['teacher_name'] as String? ?? '',
    );
    _deviceNameController = TextEditingController(
      text: widget.school?['device_name'] as String? ?? 'Display 1',
    );
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _classNameController.dispose();
    _teacherNameController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Classroom' : 'Add Classroom'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _schoolNameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'School Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _teacherNameController,
              decoration: const InputDecoration(
                labelText: 'Teacher Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deviceNameController,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final actions = ref.read(staffAdminActionsProvider);
      if (_isEditing) {
        await actions.updateSchool(
          schoolId: widget.school!['id'] as String,
          orgId: widget.orgId,
          schoolName: _schoolNameController.text.trim(),
          className: _classNameController.text.trim(),
          teacherName: _teacherNameController.text.trim(),
          deviceName: _deviceNameController.text.trim(),
        );
      } else {
        await actions.createSchool(
          orgId: widget.orgId,
          schoolName: _schoolNameController.text.trim(),
          className: _classNameController.text.trim(),
          teacherName: _teacherNameController.text.trim(),
          deviceName: _deviceNameController.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
