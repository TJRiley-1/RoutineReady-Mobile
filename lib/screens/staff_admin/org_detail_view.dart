import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_constants.dart';
import '../../providers/staff_admin_provider.dart';
import 'dialogs/add_member_dialog.dart';
import 'dialogs/edit_school_dialog.dart';

class OrgDetailView extends ConsumerStatefulWidget {
  final String orgId;
  const OrgDetailView({super.key, required this.orgId});

  @override
  ConsumerState<OrgDetailView> createState() => _OrgDetailViewState();
}

class _OrgDetailViewState extends ConsumerState<OrgDetailView> {
  bool _editingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(staffAdminOrgDetailProvider(widget.orgId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Detail'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.brandText,
        elevation: 1,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(staffAdminOrgDetailProvider(widget.orgId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (org) {
          final orgName = org['name'] as String? ?? '';
          final members = List<Map<String, dynamic>>.from(org['members'] as List? ?? []);
          final schools = List<Map<String, dynamic>>.from(org['schools'] as List? ?? []);

          if (!_editingName) {
            _nameController.text = orgName;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Org name + actions
                Row(
                  children: [
                    if (_editingName) ...[
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Organization Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await ref.read(staffAdminActionsProvider).updateOrganization(
                                widget.orgId,
                                _nameController.text.trim(),
                              );
                          setState(() => _editingName = false);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => setState(() => _editingName = false),
                      ),
                    ] else ...[
                      Text(
                        orgName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => setState(() => _editingName = true),
                      ),
                    ],
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDeleteOrg(context, orgName),
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Delete Org', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Schools section
                Row(
                  children: [
                    const Text(
                      'Classrooms',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => EditSchoolDialog(orgId: widget.orgId),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Classroom'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (schools.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No classrooms yet.')),
                    ),
                  )
                else
                  Card(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('School')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Teacher')),
                        DataColumn(label: Text('Device')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: schools.map((s) {
                        return DataRow(cells: [
                          DataCell(Text(s['school_name'] as String? ?? '')),
                          DataCell(Text(s['class_name'] as String? ?? '')),
                          DataCell(Text(s['teacher_name'] as String? ?? '')),
                          DataCell(Text(s['device_name'] as String? ?? '')),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => EditSchoolDialog(
                                    orgId: widget.orgId,
                                    school: s,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                onPressed: () => _confirmDeleteSchool(
                                  context,
                                  s['id'] as String,
                                  s['class_name'] as String? ?? 'this classroom',
                                ),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 32),

                // Members section
                Row(
                  children: [
                    const Text(
                      'Members',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AddMemberDialog(orgId: widget.orgId),
                      ),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Add Member'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (members.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No members yet.')),
                    ),
                  )
                else
                  Card(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: members.map((m) {
                        final memberId = m['id'] as String;
                        final role = m['role'] as String? ?? 'staff';
                        return DataRow(cells: [
                          DataCell(Text(m['email'] as String? ?? 'unknown')),
                          DataCell(_RoleDropdown(
                            value: role,
                            onChanged: (newRole) {
                              if (newRole != null && newRole != role) {
                                ref.read(staffAdminActionsProvider).updateOrgMember(
                                      memberId: memberId,
                                      role: newRole,
                                      orgId: widget.orgId,
                                    );
                              }
                            },
                          )),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.remove_circle, size: 18, color: Colors.red),
                              onPressed: () => _confirmRemoveMember(
                                context,
                                memberId,
                                m['email'] as String? ?? 'this member',
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteOrg(BuildContext context, String orgName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Organization'),
        content: Text(
          'Delete "$orgName" and all its classrooms and member assignments? This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(staffAdminActionsProvider).deleteOrganization(widget.orgId);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSchool(BuildContext context, String schoolId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Classroom'),
        content: Text('Delete "$name" and all its data? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(staffAdminActionsProvider).deleteSchool(schoolId, widget.orgId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(BuildContext context, String memberId, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove "$email" from this organization?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(staffAdminActionsProvider).removeOrgMember(memberId, widget.orgId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
        DropdownMenuItem(value: 'staff', child: Text('Staff')),
        DropdownMenuItem(value: 'display', child: Text('Display')),
        DropdownMenuItem(value: 'school_admin', child: Text('School Admin')),
      ],
      onChanged: onChanged,
    );
  }
}
