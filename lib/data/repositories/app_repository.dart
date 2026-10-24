import 'dart:async';
import 'dart:convert';

import 'package:data_naija_app/core/utils/storage_service.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/models/notification.dart';
import 'package:data_naija_app/data/models/referral.dart';
import 'package:data_naija_app/data/models/transaction.dart';
import 'package:flutter/foundation.dart';

/// Local data repository — the single source of truth for frontend state.
///
/// In production this would be backed by a remote API. For now it wraps
/// MockData and provides methods that simulate backend behavior.
///
/// It is a [ChangeNotifier] so screens react to a purchase or a wallet
/// funding without having to rebuild the whole application.
class AppRepository extends ChangeNotifier {
  final List<TransactionModel> _transactions = List.from(MockData.transactions);
  final List<NotificationModel> _notifications =
      List.from(MockData.notifications);
  int _balance = MockData.defaultUser.balance;
  int _referralBonus = MockData.defaultUser.referralBonus;

  /// The last purchase/funding, used by the success screen so it shows the
  /// real reference instead of a freshly generated one.
  TransactionModel? _lastTransaction;

  int _lastTransactionId = 0;

  static const String _storageKey = 'wallet_state';

  AppRepository();

  // ── Read ────────────────────────────────────────────────────────────

  int get balance => _balance;
  int get referralBonus => _referralBonus;
  TransactionModel? get lastTransaction => _lastTransaction;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  List<ReferralFriend> get friends => MockData.friends;

  // ── Persistence ─────────────────────────────────────────────────────

  /// Loads the wallet from local storage. Safe to call more than once.
  Future<void> load() async {
    final raw = StorageService.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _balance = (decoded['balance'] as num?)?.toInt() ?? _balance;
      _referralBonus =
          (decoded['referralBonus'] as num?)?.toInt() ?? _referralBonus;

      final transactions = decoded['transactions'] as List<dynamic>?;
      if (transactions != null) {
        _transactions
          ..clear()
          ..addAll(transactions.map(
            (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
          ));
      }

      final notifications = decoded['notifications'] as List<dynamic>?;
      if (notifications != null) {
        _notifications
          ..clear()
          ..addAll(notifications.map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          ));
      }

      for (final transaction in _transactions) {
        if (transaction.id > _lastTransactionId) {
          _lastTransactionId = transaction.id;
        }
      }
      _lastTransaction = _transactions.isEmpty ? null : _transactions.first;
      notifyListeners();
    } catch (_) {
      // Corrupted storage must never stop the app from starting.
    }
  }

  /// Persists the wallet. Errors are swallowed: a storage failure must not
  /// lose the in-memory state or interrupt a purchase.
  Future<void> save() async {
    try {
      final payload = jsonEncode({
        'balance': _balance,
        'referralBonus': _referralBonus,
        'transactions': _transactions.map((t) => t.toJson()).toList(),
        'notifications': _notifications.map((n) => n.toJson()).toList(),
      });
      await StorageService.setString(_storageKey, payload);
    } catch (_) {
      // Keep the state in memory; the next save will try again.
    }
  }

  /// Persists in the background and tells the UI immediately.
  void _commit() {
    notifyListeners();
    unawaited(save());
  }

  int _nextTransactionId() {
    var id = DateTime.now().millisecondsSinceEpoch;
    if (id <= _lastTransactionId) id = _lastTransactionId + 1;
    _lastTransactionId = id;
    return id;
  }

  String _newRef(int id) => 'DN${id.toString().padLeft(12, '0')}';

  TransactionModel _record({
    required String title,
    required String subtitle,
    required String date,
    required int amount,
    required String phone,
    String? ref,
    required String typeKey,
    String status = 'Successful',
  }) {
    final id = _nextTransactionId();
    final transaction = TransactionModel(
      id: id,
      title: title,
      subtitle: subtitle,
      date: date,
      amount: amount,
      status: status,
      phone: phone,
      ref: ref ?? _newRef(id),
      typeKey: typeKey,
    );
    _transactions.insert(0, transaction);
    _lastTransaction = transaction;
    return transaction;
  }

  // ── Write (simulated) ───────────────────────────────────────────────

  /// Simulates a data purchase. Deducts from balance and prepends a
  /// transaction. Returns the new transaction on success, null if
  /// insufficient balance.
  ///
  /// [dataType] is the bundle family (`SME`, `Awoof`, …). Two families
  /// sell the same size, so the backend needs it to identify the bundle
  /// and to look up the real price.
  TransactionModel? purchaseData({
    required String network,
    required String type,
    required int price,
    required String phone,
    String? dataType,
  }) {
    if (_balance < price) return null;

    final transaction = _record(
      title: 'Data Purchase',
      subtitle: '$network $type',
      date: 'Today · Just now',
      amount: -price,
      phone: phone,
      typeKey: 'd',
    );

    _balance -= price;
    _commit();
    return transaction;
  }

  /// Simulates buying any of the non-data services (airtime, cable,
  /// electricity, bulk SMS, edu pins or a recharge pin).
  ///
  /// The caller supplies the wording shown in the transaction history.
  /// Returns `null` when the wallet cannot cover [amount].
  TransactionModel? purchaseService({
    required String title,
    required String subtitle,
    required int amount,
    required String phone,
    required String typeKey,
  }) {
    if (_balance < amount) return null;

    final transaction = _record(
      title: title,
      subtitle: subtitle,
      date: 'Today · Just now',
      amount: -amount,
      phone: phone,
      typeKey: typeKey,
    );

    _balance -= amount;
    _commit();
    return transaction;
  }

  /// Simulates Swarp: converts airtime to wallet cash.
  ///
  /// The airtime is spent on the network, not from this wallet, so the
  /// customer only receives [payout]. It is recorded as a credit.
  TransactionModel swapAirtimeToWallet({
    required String network,
    required String phone,
    required int airtimeValue,
    required int payout,
  }) {
    final transaction = _record(
      title: 'Swarp',
      subtitle: '$network airtime to wallet',
      date: 'Today · Just now',
      amount: payout,
      phone: phone,
      typeKey: 'x',
    );

    _balance += payout;
    _commit();
    return transaction;
  }

  /// Simulates wallet funding. Adds to balance and prepends a transaction.
  TransactionModel fundWallet(int amount, String method) {    final transaction = _record(
      title: 'Wallet Funding',
      subtitle: method,
      date: 'Today · Just now',
      amount: amount,
      phone: '-',
      typeKey: 'w',
    );

    _balance += amount;
    _commit();
    return transaction;
  }

  /// Simulates moving referral bonus to wallet.
  bool moveReferralBonus() {
    final bonus = _referralBonus;
    if (bonus < MockData.referralMin) return false;

    _record(
      title: 'Referral Bonus',
      subtitle: 'Moved to wallet',
      date: 'Today · Just now',
      amount: bonus,
      phone: '-',
      typeKey: 'w',
    );
    _balance += bonus;
    _referralBonus = 0;
    _commit();
    return true;
  }

  /// Filters transactions by status and search query.
  List<TransactionModel> filterTransactions({
    String statusFilter = 'All',
    String query = '',
  }) {
    final needle = query.trim().toLowerCase();
    return _transactions.where((t) {
      final matchesStatus = statusFilter == 'All' || t.status == statusFilter;
      if (needle.isEmpty) return matchesStatus;
      final searchable =
          '${t.title} ${t.subtitle} ${t.phone} ${t.ref}'.toLowerCase();
      return matchesStatus && searchable.contains(needle);
    }).toList();
  }

  // ── Notifications ───────────────────────────────────────────────────

  /// Marks a notification as read.
  void markNotificationRead(NotificationModel notification) {
    final index = _notifications.indexOf(notification);
    if (index == -1 || _notifications[index].isRead) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    _commit();
  }

  // ── Auto-Buy support ────────────────────────────────────────────────

  /// Whether the wallet can cover [amount] without going negative.
  bool canAfford(int amount) => _balance >= amount;

  /// Overrides the wallet balance.
  ///
  /// Test-only helper — the balance is otherwise changed through the
  /// purchase and funding flows.
  void setBalance(int value) {
    _balance = value;
    notifyListeners();
  }

  /// Restores the demo state: the starting balance, the sample
  /// transactions and the sample notifications.
  ///
  /// Test-only helper.
  void reset() {
    _balance = MockData.defaultUser.balance;
    _referralBonus = MockData.defaultUser.referralBonus;
    _lastTransaction = null;
    _lastTransactionId = 0;
    _transactions
      ..clear()
      ..addAll(MockData.transactions);
    _notifications
      ..clear()
      ..addAll(MockData.notifications);
    notifyListeners();
  }

  /// Debits the wallet for an automatic (Auto-Buy) data purchase.
  ///
  /// Returns `null` when the balance is insufficient — the caller must not
  /// treat that as a success. The [ref] is derived from the scheduled slot
  /// by the Auto-Buy repository, so a repeated attempt can never charge the
  /// customer twice.
  TransactionModel? purchaseDataAutoBuy({
    required String network,
    required String type,
    required int price,
    required String phone,
    required String ref,
    String title = 'Auto-Buy Data Purchase',
  }) {
    if (_balance < price) return null;

    final transaction = _record(
      title: title,
      subtitle: '$network $type',
      date: 'Today · Just now',
      amount: -price,
      phone: phone,
      ref: ref,
      typeKey: 'd',
    );

    _balance -= price;
    _commit();
    return transaction;
  }

  /// Adds a notification (used by the Auto-Buy runner).
  void addNotification({
    required String title,
    required String body,
    String letter = 'D',
    String date = 'Today · Just now',
  }) {
    _notifications.insert(
      0,
      NotificationModel(
        title: title,
        body: body,
        date: date,
        letter: letter,
        isRead: false,
      ),
    );
    _commit();
  }
}
