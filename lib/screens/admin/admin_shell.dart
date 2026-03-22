import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme_constants.dart';
import '../../models/task.dart';
import '../../models/template.dart';
import '../../providers/school_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/theme_utils.dart';
import '../../utils/time_utils.dart';
import 'timeline_editor.dart';
import 'template_manager.dart';
import 'display_settings_modal.dart';
import 'theme_chooser_modal.dart';
import 'theme_editor_modal.dart';
import 'user_settings_modal.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  Timer? _timer;
  int _currentTaskIndex = -1;
  double _elapsedInTask = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateProgress());
    _updateProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateProgress() {
    final schoolState = ref.read(schoolProvider).valueOrNull;
    if (schoolState == null) return;

    final progress = getCurrentTaskProgress(
      DateTime.now(),
      schoolState.timeline.startTime,
      schoolState.timeline.tasks,
    );

    if (mounted) {
      setState(() {
        _currentTaskIndex = progress.currentTaskIndex;
        _elapsedInTask = progress.elapsedInTask;
      });
    }
  }

  void _exitAdmin() {
    ref.read(displaySessionProvider.notifier).endSession();
    ref.read(sessionModeProvider.notifier).state = null;
  }

  Future<void> _saveAll() async {
    try {
      await ref.read(schoolProvider.notifier).saveAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  void _showSaveAsTemplate() {
    final schoolState = ref.read(schoolProvider).valueOrNull;
    if (schoolState == null) return;

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save as Template'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Template Name',
            hintText: 'e.g. Morning Routine',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newTemplate = TaskTemplate(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text.trim(),
                  startTime: schoolState.timeline.startTime,
                  endTime: schoolState.timeline.endTime,
                  tasks: schoolState.timeline.tasks
                      .map((t) => Task.fromJson(t.toJson()))
                      .toList(),
                );
                ref.read(schoolProvider.notifier).updateTemplates(
                    [...schoolState.templates, newTemplate]);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDisplaySettings() {
    showDialog(
      context: context,
      builder: (_) => const DisplaySettingsModal(),
    );
  }

  void _showThemeChooser() {
    showDialog(
      context: context,
      builder: (_) => ThemeChooserModal(
        onCreateCustom: () {
          Navigator.pop(context);
          _showThemeEditor(null);
        },
        onEditCustom: (theme) {
          Navigator.pop(context);
          _showThemeEditor(theme);
        },
      ),
    );
  }

  void _showThemeEditor(dynamic editingTheme) {
    showDialog(
      context: context,
      builder: (_) => ThemeEditorModal(
        editingTheme: editingTheme,
        onBack: () {
          Navigator.pop(context);
          _showThemeChooser();
        },
      ),
    );
  }

  void _showUserSettings() {
    showDialog(
      context: context,
      builder: (_) => const UserSettingsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolState = ref.watch(schoolProvider);

    return schoolState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (state) {
        if (state == null) {
          return const Scaffold(
            body: Center(child: Text('No data')),
          );
        }

        final theme = getActiveTheme(state.currentTheme, state.customThemes);

        return Scaffold(
          body: Column(
            children: [
              // Toolbar
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      // Left buttons
                      ElevatedButton.icon(
                        onPressed: state.hasUnsavedChanges && !state.isSaving
                            ? _saveAll
                            : null,
                        icon: const Icon(LucideIcons.save, size: 18),
                        label: Text(state.isSaving
                            ? 'Saving...'
                            : state.hasUnsavedChanges
                                ? 'Save Changes'
                                : 'Saved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.hasUnsavedChanges
                              ? AppColors.brandAccent
                              : Colors.grey.shade200,
                          foregroundColor: state.hasUnsavedChanges
                              ? AppColors.brandPrimaryDark
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showSaveAsTemplate,
                        icon: const Icon(LucideIcons.bookmarkPlus, size: 18),
                        label: const Text('Save as Template'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showDisplaySettings,
                        icon: const Icon(LucideIcons.monitor, size: 18),
                        label: const Text('Display Settings'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showThemeChooser,
                        icon: const Icon(LucideIcons.palette, size: 18),
                        label: const Text('Change Theme'),
                      ),
                      const Spacer(),
                      // Center title
                      Column(
                        children: [
                          const Text(
                            'Timeline Editor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandText,
                            ),
                          ),
                          Text(
                            '${state.school.schoolName} - ${state.school.className}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.brandTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Right buttons
                      OutlinedButton.icon(
                        onPressed: _showUserSettings,
                        icon: const Icon(LucideIcons.settings, size: 18),
                        label: const Text('User Settings'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _exitAdmin,
                        icon: const Icon(LucideIcons.arrowLeft, size: 18),
                        label: const Text('Exit Admin'),
                      ),
                    ],
                  ),
                ),
              ),

              // Unsaved changes banner
              if (state.hasUnsavedChanges)
                Container(
                  color: Colors.amber.shade50,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'You have unsaved changes. Click "Save Changes" to save.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: state.isSaving ? null : _saveAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandAccent,
                          foregroundColor: AppColors.brandPrimaryDark,
                        ),
                        child: Text(
                            state.isSaving ? 'Saving...' : 'Save Now'),
                      ),
                    ],
                  ),
                ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Weekly Schedule
                      TemplateManager(
                        templates: state.templates,
                        weeklySchedule: state.weeklySchedule,
                      ),
                      const SizedBox(height: 16),
                      // Task Editor
                      TimelineEditor(
                        timeline: state.timeline,
                        displaySettings: state.displaySettings,
                        theme: theme,
                        currentTaskIndex: _currentTaskIndex,
                        elapsedInTask: _elapsedInTask,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
