import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over SharedPreferences for persisting demo-only frontend state:
/// onboarding completion, theme accent selection, KYC status, and auth state.
/// This is strictly local storage — no backend is involved.
///
/// Writes are safe to call before [init] (they are ignored), so a widget test
/// or a screen that runs very early can never crash because storage is not
/// ready.
class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'StorageService not initialized. Call StorageService.init() first.',
      );
    }
    return prefs;
  }

  // ── Keys ────────────────────────────────────────────────────────────

  static const String _kOnboardingSeen = 'onboarding_seen';
  static const String _kThemeAccent = 'theme_accent';
  static const String _kKycVerified = 'kyc_verified';
  static const String _kIsSignedIn = 'is_signed_in';
  static const String _kFingerprintEnabled = 'fingerprint_enabled';
  static const String _kBalanceHidden = 'balance_hidden';

  // ── Onboarding ──────────────────────────────────────────────────────

  static bool get onboardingSeen => _p.getBool(_kOnboardingSeen) ?? false;
  static Future<void> setOnboardingSeen(bool value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_kOnboardingSeen, value);
  }

  // ── Theme ───────────────────────────────────────────────────────────

  static String get themeAccent => _p.getString(_kThemeAccent) ?? '0xFF0A7A4C';
  static Future<void> setThemeAccent(String hex) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_kThemeAccent, hex);
  }

  // ── KYC ─────────────────────────────────────────────────────────────

  static bool get kycVerified => _p.getBool(_kKycVerified) ?? false;
  static Future<void> setKycVerified(bool value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_kKycVerified, value);
  }

  // ── Auth ────────────────────────────────────────────────────────────

  static bool get isSignedIn => _p.getBool(_kIsSignedIn) ?? false;
  static Future<void> setSignedIn(bool value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_kIsSignedIn, value);
  }

  // ── Fingerprint ─────────────────────────────────────────────────────

  static bool get fingerprintEnabled =>
      _p.getBool(_kFingerprintEnabled) ?? false;
  static Future<void> setFingerprintEnabled(bool value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_kFingerprintEnabled, value);
  }

  // ── Balance visibility ──────────────────────────────────────────────

  static bool get balanceHidden => _p.getBool(_kBalanceHidden) ?? false;
  static Future<void> setBalanceHidden(bool value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_kBalanceHidden, value);
  }

  // ── Generic values ──────────────────────────────────────────────────

  /// Reads a string value. Used by features that persist a JSON blob
  /// (for example the Auto-Buy schedules and the wallet).
  static String? getString(String key) {
    final prefs = _prefs;
    if (prefs == null) return null;
    return prefs.getString(key);
  }

  /// Writes a string value.
  static Future<void> setString(String key, String value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(key, value);
  }
}
