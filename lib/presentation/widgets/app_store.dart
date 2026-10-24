import 'dart:async';
import 'dart:ui' show Color;

import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/storage_service.dart';
import 'package:data_naija_app/data/repositories/app_repository.dart';
import 'package:data_naija_app/data/repositories/auto_buy_repository.dart';
import 'package:flutter/foundation.dart';

/// Global singleton store instance.
final appStore = AppStore();

/// Global singleton repository instance.
final appRepository = AppRepository();

/// Global singleton Auto-Buy repository.
///
/// It spends from [appRepository], so the wallet stays the single source of
/// truth for the balance and the transaction history.
final autoBuyRepository = AutoBuyRepository(wallet: appRepository);

/// Everything a screen can read from.
///
/// Screens listen to this instead of the whole `MaterialApp`, so a wallet
/// change does not rebuild the theme, the navigator and every route.
final Listenable appStateListenable = Listenable.merge([
  appStore,
  appRepository,
  autoBuyRepository,
]);

/// Lightweight frontend state store.
///
/// Holds UI state that must survive navigation (balance, auth, KYC, theme,
/// form values). Uses ChangeNotifier so screens can rebuild reactively.
///
/// This is intentionally minimal — no external state-management package.
class AppStore extends ChangeNotifier {
  // ── Auth / session ──────────────────────────────────────────────────

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  void setSignedIn(bool value) {
    if (_isSignedIn == value) return;
    _isSignedIn = value;
    unawaited(StorageService.setSignedIn(value));
    notifyListeners();
  }

  // ── KYC ─────────────────────────────────────────────────────────────

  bool _kycVerified = false;
  bool get kycVerified => _kycVerified;

  void setKycVerified(bool value) {
    if (_kycVerified == value) return;
    _kycVerified = value;
    unawaited(StorageService.setKycVerified(value));
    notifyListeners();
  }

  // ── Fingerprint ─────────────────────────────────────────────────────

  bool _fingerprintEnabled = false;
  bool get fingerprintEnabled => _fingerprintEnabled;

  void setFingerprintEnabled(bool value) {
    if (_fingerprintEnabled == value) return;
    _fingerprintEnabled = value;
    unawaited(StorageService.setFingerprintEnabled(value));
    notifyListeners();
  }

  // ── Balance visibility ──────────────────────────────────────────────

  bool _balanceHidden = false;
  bool get balanceHidden => _balanceHidden;

  void toggleBalanceVisibility() {
    setBalanceHidden(!_balanceHidden);
  }

  void setBalanceHidden(bool value) {
    if (_balanceHidden == value) return;
    _balanceHidden = value;
    unawaited(StorageService.setBalanceHidden(value));
    notifyListeners();
  }

  // ── Theme accent ────────────────────────────────────────────────────

  int _accentIndex = 0;

  /// Only changes when the accent changes, so `MaterialApp` can rebuild the
  /// theme without rebuilding on every unrelated store update.
  final ValueNotifier<int> accentIndexNotifier = ValueNotifier<int>(0);

  // ── Onboarding ──────────────────────────────────────────────────────

  bool _onboardingSeen = false;
  bool get onboardingSeen => _onboardingSeen;

  void setOnboardingSeen(bool value) {
    if (_onboardingSeen == value) return;
    _onboardingSeen = value;
    unawaited(StorageService.setOnboardingSeen(value));
    notifyListeners();
  }

  /// Loads the values that survive an app restart.
  ///
  /// Called once from `main()` after `StorageService.init`.
  void restore() {
    _onboardingSeen = StorageService.onboardingSeen;
    _isSignedIn = StorageService.isSignedIn;
    _kycVerified = StorageService.kycVerified;
    _fingerprintEnabled = StorageService.fingerprintEnabled;
    _balanceHidden = StorageService.balanceHidden;
    _accentIndex = _indexForHex(StorageService.themeAccent);
    accentIndexNotifier.value = _accentIndex;
  }

  static int _indexForHex(String hex) {
    for (var i = 0; i < kThemeAccentOptions.length; i++) {
      if (_colorToHex(kThemeAccentOptions[i]) == hex) return i;
    }
    return 0;
  }

  static String _colorToHex(Color color) {
    return '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Restores the starting state.
  ///
  /// Test-only helper — the store is otherwise changed by the screens.
  void reset() {
    _isSignedIn = false;
    _kycVerified = false;
    _fingerprintEnabled = false;
    _balanceHidden = false;
    _accentIndex = 0;
    accentIndexNotifier.value = 0;
    _onboardingSeen = false;
    _selectedNetwork = 'MTN';
    _phone = '';
    _dataType = 'SME';
    _selectedGb = '1GB';
    _selectedDays = '30 Days';
    _selectedPrice = 300;
    _fundAmount = '1000';
    _paymentMethod = 'Card Payment';
    _obscurePassword = true;
    notifyListeners();
  }

  // ── Buy flow state ──────────────────────────────────────────────────

  String _selectedNetwork = 'MTN';
  String get selectedNetwork => _selectedNetwork;

  void setSelectedNetwork(String network) {
    if (_selectedNetwork == network) return;
    _selectedNetwork = network;
    notifyListeners();
  }

  String _phone = '';
  String get phone => _phone;

  void setPhone(String value) {
    if (_phone == value) return;
    _phone = value;
    notifyListeners();
  }

  String _dataType = 'SME';
  String get dataType => _dataType;

  void setDataType(String type) {
    if (_dataType == type) return;
    _dataType = type;
    notifyListeners();
  }

  String _selectedGb = '1GB';
  String get selectedGb => _selectedGb;

  String _selectedDays = '30 Days';
  String get selectedDays => _selectedDays;

  int _selectedPrice = 300;
  int get selectedPrice => _selectedPrice;

  void selectPlan(String gb, String days, int price) {
    if (_selectedGb == gb && _selectedDays == days && _selectedPrice == price) {
      return;
    }
    _selectedGb = gb;
    _selectedDays = days;
    _selectedPrice = price;
    notifyListeners();
  }

  // ── Wallet funding state ────────────────────────────────────────────

  String _fundAmount = '1000';
  String get fundAmount => _fundAmount;

  void setFundAmount(String value) {
    if (_fundAmount == value) return;
    _fundAmount = value;
    notifyListeners();
  }

  String _paymentMethod = 'Card Payment';
  String get paymentMethod => _paymentMethod;

  void setPaymentMethod(String method) {
    if (_paymentMethod == method) return;
    _paymentMethod = method;
    notifyListeners();
  }

  // ── Form UI state ───────────────────────────────────────────────────

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // ── KYC form ────────────────────────────────────────────────────────

  String _kycId = '';
  String get kycId => _kycId;

  void setKycId(String value) {
    if (_kycId == value) return;
    _kycId = value;
    notifyListeners();
  }
}
