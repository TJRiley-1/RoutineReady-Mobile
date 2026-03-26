/// RevenueCat API keys — configure these when accounts are set up.
///
/// Get these from the RevenueCat dashboard:
/// https://app.revenuecat.com/ → Project → API Keys
class RevenueCatConfig {
  // TODO: Replace with actual API keys from RevenueCat dashboard
  static const String appleApiKey = '';
  static const String googleApiKey = '';
  static const String webApiKey = '';

  /// The entitlement ID configured in RevenueCat dashboard.
  /// All paid products grant this single entitlement.
  static const String entitlementId = 'pro';

  /// Whether RevenueCat is configured (has at least one API key).
  static bool get isConfigured =>
      appleApiKey.isNotEmpty ||
      googleApiKey.isNotEmpty ||
      webApiKey.isNotEmpty;
}
