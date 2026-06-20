import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme_constants.dart';
import '../../models/school.dart';
import '../../providers/auth_provider.dart';
import '../../providers/membership_provider.dart';
import '../../providers/staff_admin_provider.dart';

/// All-orgs classroom picker for RoutineReady staff. Classrooms are grouped
/// under their school/org heading. Selecting one opens it in the editor.
class AllClassroomsPickerScreen extends ConsumerWidget {
  const AllClassroomsPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(staffAllClassroomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Classrooms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Staff Admin',
          onPressed: () =>
              ref.read(staffViewAsMemberProvider.notifier).state = false,
        ),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(authActionsProvider).signOut(),
            icon: const Icon(LucideIcons.logOut, size: 16),
            label: const Text('Sign Out'),
          ),
        ],
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading classrooms: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(staffAllClassroomsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
              child: Text(
                'No classrooms found in any organization.',
                style: TextStyle(color: AppColors.brandTextMuted, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: groups.length,
            itemBuilder: (context, i) {
              final group = groups[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 28, bottom: 12),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.building2,
                            size: 18, color: AppColors.brandPrimary),
                        const SizedBox(width: 8),
                        Text(
                          group.org.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${group.classrooms.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.brandTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: group.classrooms
                        .map((c) => _ClassroomCard(classroom: c))
                        .toList(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ClassroomCard extends ConsumerWidget {
  final School classroom;

  const _ClassroomCard({required this.classroom});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () =>
              ref.read(selectedClassroomProvider.notifier).state = classroom,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.school,
                    size: 32,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  classroom.className,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  classroom.teacherName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.brandTextMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
