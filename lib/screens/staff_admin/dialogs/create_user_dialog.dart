import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/staff_admin_provider.dart';

class CreateUserDialog extends ConsumerStatefulWidget {
  const CreateUserDialog({super.key});

  @override
  ConsumerState<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<CreateUserDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedOrgId;
  String _selectedRole = 'teacher';
  bool _loading = false;
  bool _assignToOrg = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(staffAdminOrgsProvider);

    return AlertDialog(
      title: const Text('Create User'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Assign to organization'),
              value: _assignToOrg,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _assignToOrg = v ?? false),
            ),
            if (_assignToOrg) ...[
              const SizedBox(height: 8),
              orgsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading orgs: $e'),
                data: (orgs) => DropdownButtonFormField<String>(
                  initialValue: _selectedOrgId,
                  decoration: const InputDecoration(
                    labelText: 'Organization',
                    border: OutlineInputBorder(),
                  ),
                  items: orgs
                      .map((o) => DropdownMenuItem(
                            value: o['id'] as String,
                            child: Text(o['name'] as String? ?? ''),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedOrgId = v),
                ),
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
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ref.read(staffAdminActionsProvider).createUser(
            email: email,
            password: password,
            orgId: _assignToOrg ? _selectedOrgId : null,
            role: _assignToOrg ? _selectedRole : null,
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
