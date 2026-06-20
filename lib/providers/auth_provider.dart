import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentSessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (state) => state.session);
});

final currentUserProvider = Provider<User?>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.user;
});

final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

/// True while the user must set a password before entering the app — either a
/// password-recovery session (reset link) or a freshly accepted invite. Set on
/// the `AuthChangeEvent.passwordRecovery` event or seeded from the launch URL
/// `type` (invite/recovery); cleared once the password is set.
final mustSetPasswordProvider = StateProvider<bool>((ref) => false);

/// The `type` param from the launch URL (e.g. 'invite', 'recovery'), captured in
/// main() before Supabase consumes the URL. Used to seed [mustSetPasswordProvider].
String? launchAuthType;

/// Extracts the auth `type` from a launch [uri] — checks query params and, for
/// the implicit flow, the URL fragment (e.g. `#access_token=...&type=invite`).
String? extractAuthType(Uri uri) {
  final fromQuery = uri.queryParameters['type'];
  if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
  if (uri.fragment.isEmpty) return null;
  return Uri.splitQueryString(uri.fragment)['type'];
}

class AuthActions {
  final Ref _ref;

  AuthActions(this._ref);

  SupabaseClient get _client => _ref.read(supabaseClientProvider);

  Future<AuthResponse> signIn(String email, String password) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    // On web, return the user to the site they requested the reset from (live or
    // localhost). On non-web, fall back to the Supabase Site URL config.
    final redirect = kIsWeb
        ? Uri(
            scheme: Uri.base.scheme,
            host: Uri.base.host,
            port: Uri.base.port,
            path: Uri.base.path,
          ).toString()
        : null;
    await _client.auth.resetPasswordForEmail(email, redirectTo: redirect);
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
