import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/staff_admin_provider.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  final String orgId;
  const AddMemberDialog({super.key, required this.orgId});

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  String? _selectedUserId;
  String _selectedRole = 'teacher';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(staffAdminUsersProvider);

    return AlertDialog(
      title: const Text('Add Member'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            usersAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (users) {
                // Filter out users already in this org
                final available = users.where((u) {
                  final memberships = List<Map<String, dynamic>>.from(
                    u['memberships'] as List? ?? [],
                  );
                  return !memberships.any((m) => m['org_id'] == widget.orgId);
                }).toList();

                if (available.isEmpty) {
                  return const Text('All users are already members of this organization.');
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'User',
                    border: OutlineInputBorder(),
                  ),
                  items: available
                      .map((u) => DropdownMenuItem(
                            value: u['id'] as String,
                            child: Text(u['email'] as String? ?? ''),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedUserId = v),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'staff', child: Text('Staff')),
                DropdownMenuItem(value: 'display', child: Text('Display')),
                DropdownMenuItem(value: 'school_admin', child: Text('School Admin')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v ?? 'teacher'),
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
          onPressed: _loading || _selectedUserId == null ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_selectedUserId == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(staffAdminActionsProvider).addOrgMember(
            orgId: widget.orgId,
            userId: _selectedUserId!,
            role: _selectedRole,
          );
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
