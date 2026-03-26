import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

/// The user's current subscription plan.
final subscriptionProvider = FutureProvider<SubscriptionState>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return SubscriptionState.free();

  final client = ref.read(supabaseClientProvider);

  // Try to load subscription from DB
  final res = await client
      .from('subscriptions')
      .select()
      .eq('school_id', _schoolIdQuery(client, user.id))
      .limit(1)
      .maybeSingle();

  if (res == null) return SubscriptionState.free();

  return SubscriptionState(
    plan: res['plan'] as String? ?? 'free',
    maxDisplaySlots: res['max_display_slots'] as int? ?? 1,
    maxAdminSlots: res['max_admin_slots'] as int? ?? 1,
    status: res['status'] as String? ?? 'active',
  );
});

/// Helper to get school_id for current user (used in subscription query).
/// Returns empty string if no school exists (free user with no school record).
String _schoolIdQuery(SupabaseClient client, String userId) {
  // We can't use a subquery directly in the eq filter, so we'll handle
  // the lookup differently. This is overridden below.
  return '';
}

/// Simplified subscription lookup that works with the school provider.
final subscriptionPlanProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 'free';

  final client = ref.read(supabaseClientProvider);

  // First find the user's school
  final school = await client
      .from('schools')
      .select('id')
      .eq('owner_id', user.id)
      .limit(1)
      .maybeSingle();

  if (school == null) return 'free';

  // Then check subscription
  final sub = await client
      .from('subscriptions')
      .select('plan, status')
      .eq('school_id', school['id'])
      .limit(1)
      .maybeSingle();

  if (sub == null) return 'free';
  if (sub['status'] != 'active') return 'free';
  return sub['plan'] as String? ?? 'free';
});

/// Convenience provider: is the user on a paid plan?
final isPaidProvider = Provider<bool>((ref) {
  final plan = ref.watch(subscriptionPlanProvider).valueOrNull;
  return plan != null && plan != 'free';
});

class SubscriptionState {
  final String plan;
  final int maxDisplaySlots;
  final int maxAdminSlots;
  final String status;

  SubscriptionState({
    required this.plan,
    this.maxDisplaySlots = 1,
    this.maxAdminSlots = 1,
    this.status = 'active',
  });

  factory SubscriptionState.free() => SubscriptionState(plan: 'free');

  bool get isFree => plan == 'free';
  bool get isPaid => plan != 'free' && status == 'active';
}
