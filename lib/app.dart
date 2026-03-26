import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/school_provider.dart';
import 'providers/session_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_wizard_screen.dart';
import 'screens/mode_select/mode_select_screen.dart';
import 'screens/display/display_screen.dart';
import 'screens/admin/admin_shell.dart';

class RoutineReadyApp extends ConsumerWidget {
  const RoutineReadyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Routine Ready',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const LoginScreen(),
      data: (state) {
        if (state.session == null) {
          return const LoginScreen();
        }
        return const _AuthenticatedRouter();
      },
    );
  }
}

class _AuthenticatedRouter extends ConsumerWidget {
  const _AuthenticatedRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolState = ref.watch(schoolProvider);
    final sessionMode = ref.watch(sessionModeProvider);
    final isPaid = ref.watch(isPaidProvider);

    return schoolState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading data: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(schoolProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (state) {
        // No school record:
        // - Paid users → setup wizard
        // - Free users → mode select with in-memory defaults (school provider handles this)
        if (state == null) {
          if (isPaid) {
            return const SetupWizardScreen();
          }
          // Free user: initialize in-memory data and go to mode select
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(schoolProvider.notifier).initFreeMode();
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No mode selected = mode select screen
        if (sessionMode == null) {
          return const ModeSelectScreen();
        }

        // Display or Admin mode
        if (sessionMode == 'display') {
          return const DisplayScreen();
        }

        return const AdminShell();
      },
    );
  }
}
