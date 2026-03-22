import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';

class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  final _schoolNameController = TextEditingController();
  final _classNameController = TextEditingController();
  final _teacherNameController = TextEditingController();
  final _deviceNameController = TextEditingController(text: 'Display 1');
  int _step = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _schoolNameController.dispose();
    _classNameController.dispose();
    _teacherNameController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (_schoolNameController.text.isEmpty ||
        _classNameController.text.isEmpty ||
        _teacherNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(schoolProvider.notifier).createSchool(
            userId: user.id,
            schoolName: _schoolNameController.text.trim(),
            className: _classNameController.text.trim(),
            teacherName: _teacherNameController.text.trim(),
            deviceName: _deviceNameController.text.trim().isEmpty
                ? 'Display 1'
                : _deviceNameController.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _skipSetup() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(schoolProvider.notifier).createSchool(
            userId: user.id,
            schoolName: 'Not Configured',
            className: 'Not Configured',
            teacherName: 'Not Configured',
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\u2705',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Routine Ready',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Let\'s set up your classroom display',
                  style: TextStyle(color: AppColors.brandTextMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step $_step of 3',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                if (_step == 1) ...[
                  TextField(
                    controller: _schoolNameController,
                    decoration: const InputDecoration(
                      labelText: 'School Name *',
                      hintText: 'e.g. Sunshine Primary School',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : _skipSetup,
                        child: const Text('Skip Setup'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_schoolNameController.text.isNotEmpty) {
                            setState(() => _step = 2);
                          }
                        },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ] else if (_step == 2) ...[
                  TextField(
                    controller: _classNameController,
                    decoration: const InputDecoration(
                      labelText: 'Class Name *',
                      hintText: 'e.g. Year 4 - Mrs Johnson\'s Class',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _teacherNameController,
                    decoration: const InputDecoration(
                      labelText: 'Teacher Name *',
                      hintText: 'e.g. Mrs Johnson',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _step = 1),
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_classNameController.text.isNotEmpty &&
                              _teacherNameController.text.isNotEmpty) {
                            setState(() => _step = 3);
                          }
                        },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ] else ...[
                  TextField(
                    controller: _deviceNameController,
                    decoration: const InputDecoration(
                      labelText: 'Device Name',
                      hintText: 'e.g. Display 1',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This helps identify which display is which if you have multiple screens.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.brandTextMuted),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _step = 2),
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _completeSetup,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Complete Setup'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
