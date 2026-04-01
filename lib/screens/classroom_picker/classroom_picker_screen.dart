import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme_constants.dart';
import '../../models/org_member.dart';
import '../../models/school.dart';
import '../../providers/auth_provider.dart';
import '../../providers/membership_provider.dart';

class ClassroomPickerScreen extends ConsumerWidget {
  const ClassroomPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(organizationProvider);
    final classroomsAsync = ref.watch(classroomsProvider);
    final membershipAsync = ref.watch(membershipProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\u2705',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Routine Ready',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                orgAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (org) => org != null
                      ? Text(
                          org.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.brandTextMuted,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                membershipAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (m) => m != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _roleColor(m.role).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _roleLabel(m.role),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _roleColor(m.role),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a classroom',
                  style: TextStyle(color: AppColors.brandTextMuted),
                ),
                const SizedBox(height: 32),
                classroomsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error loading classrooms: $e'),
                  data: (classrooms) {
                    if (classrooms.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No classrooms found in your organization.\nContact your school administrator.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.brandTextMuted,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: classrooms
                          .map((c) => _ClassroomCard(classroom: c))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () {
                    ref.read(authActionsProvider).signOut();
                  },
                  icon: const Icon(LucideIcons.logOut, size: 16),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.staff:
        return 'Staff';
      case UserRole.display:
        return 'Display Device';
      case UserRole.schoolAdmin:
        return 'School Admin';
    }
  }

  static Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return AppColors.brandPrimary;
      case UserRole.staff:
        return Colors.teal;
      case UserRole.display:
        return Colors.indigo;
      case UserRole.schoolAdmin:
        return Colors.deepPurple;
    }
  }
}

class _ClassroomCard extends ConsumerWidget {
  final School classroom;

  const _ClassroomCard({required this.classroom});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(membershipProvider).valueOrNull;

    return SizedBox(
      width: 200,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () async {
            // For display role, save to secure storage
            if (membership?.role == UserRole.display) {
              await saveRememberedClassroom(classroom.id);
            }
            ref.read(selectedClassroomProvider.notifier).state = classroom;
          },
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
