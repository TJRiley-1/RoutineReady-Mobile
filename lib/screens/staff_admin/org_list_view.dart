import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_constants.dart';
import '../../providers/staff_admin_provider.dart';
import 'dialogs/create_org_dialog.dart';
import 'org_detail_view.dart';

class OrgListView extends ConsumerWidget {
  const OrgListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgsAsync = ref.watch(staffAdminOrgsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Text(
                'Organizations',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const CreateOrgDialog(),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Create Organization'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Content
        Expanded(
          child: orgsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: $e'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(staffAdminOrgsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (orgs) {
              if (orgs.isEmpty) {
                return const Center(
                  child: Text('No organizations yet. Create one to get started.'),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: orgs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final org = orgs[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.brandPrimaryBg,
                        child: Icon(Icons.business, color: AppColors.brandPrimary),
                      ),
                      title: Text(
                        org['name'] as String? ?? 'Unnamed',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${org['member_count']} members \u2022 ${org['school_count']} classrooms',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrgDetailView(orgId: org['id'] as String),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
