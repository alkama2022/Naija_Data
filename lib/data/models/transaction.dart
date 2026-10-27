import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Represents a single transaction record.
///
/// Matches the prototype's `txs` array shape:
/// id, title, sub, date, amt, status, phone, ref, k (type key)
class TransactionModel {
  final int id;
  final String title;
  final String subtitle;
  final String date;
  final int amount; // positive = credit, negative = debit
  final String status; // 'Successful' | 'Pending' | 'Failed'
  final String phone;
  final String ref;
  /// 'd' = data, 'a' = airtime, 'w' = wallet, 'c' = cable,
  /// 'e' = electricity, 's' = bulk SMS, 'p' = edu pin,
  /// 'r' = recharge pin, 'x' = Swarp (airtime to wallet).
  final String typeKey;

  /// The backend transaction UUID, present for transactions loaded from
  /// the API. The display reference (`ref`) is the human-readable
  /// transaction id the customer receives.
  final String? serverId;

  /// When the backend recorded the transaction.
  final DateTime? createdAt;

  /// Balance before the transaction was applied, when the backend provided it.
  final int? previousBalance;

  /// Balance after the transaction was applied, when the backend provided it.
  final int? newBalance;

  /// Kind of movement: purchase, credit, debit, refund, reversal.
  final String? transactionType;

  /// How the money moved: wallet, bank transfer, card payment, etc.
  final String? paymentMethod;

  /// The upstream provider reference, when known.
  final String? providerRef;

  /// Fee charged for the transaction, in Naira, when any was applied.
  final int? fees;

  /// Failure or reversal details, when the transaction did not complete cleanly.
  final String? failureDetails;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.status,
    required this.phone,
    required this.ref,
    required this.typeKey,
    this.serverId,
    this.createdAt,
    this.previousBalance,
    this.newBalance,
    this.transactionType,
    this.paymentMethod,
    this.providerRef,
    this.fees,
    this.failureDetails,
  });

  /// Builds a transaction from a backend JSON row.
  ///
  /// The backend owns the numbers; the client only maps them. Fields the
  /// backend does not provide stay null so screens never invent values.
  factory TransactionModel.fromBackend(Map<String, dynamic> json) {
    return TransactionModel(
      id: 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      date: json['date']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'Successful',
      phone: json['phone'] as String? ?? '-',
      ref: json['ref'] as String? ?? '',
      typeKey: json['typeKey'] as String? ?? 'd',
      serverId: json['id'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      previousBalance: (json['previousBalance'] as num?)?.toInt(),
      newBalance: (json['newBalance'] as num?)?.toInt(),
      transactionType: json['transactionType'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      providerRef: json['providerRef'] as String?,
      fees: (json['fees'] as num?)?.toInt(),
      failureDetails: json['failureDetails'] as String?,
    );
  }

  /// Human readable type label for the icon key.
  String get typeLabel {
    switch (typeKey) {
      case 'a':
        return 'Airtime';
      case 'w':
        return 'Wallet';
      case 'c':
        return 'Cable TV';
      case 'e':
        return 'Electricity';
      case 's':
        return 'Bulk SMS';
      case 'p':
        return 'Edu PIN';
      case 'r':
        return 'Recharge PIN';
      case 'x':
        return 'Swarp';
      default:
        return 'Data';
    }
  }

  /// Human readable transaction date/time.
  String get formattedDate {
    final dateTime = createdAt ??
        (date.isNotEmpty ? DateTime.tryParse(date) : null);
    if (dateTime == null) return date;
    return DateFormat('d MMM yyyy, h:mm a').format(dateTime);
  }

  /// Returns the display letter for the icon.
  String get letter {
    switch (typeKey) {
      case 'a':
        return 'A';
      case 'w':
        return 'W';
      case 'c':
        return 'C';
      case 'e':
        return 'E';
      case 's':
        return 'S';
      case 'p':
        return 'P';
      case 'r':
        return 'R';
      case 'x':
        return 'X';
      default:
        return 'D';
    }
  }

  /// Returns the icon background color based on type.
  Color get iconColor {
    switch (typeKey) {
      case 'a':
        return const Color(0xFFFDE4E1); // .ic.a — airtime (red tint)
      case 'w':
        return const Color(0xFFE6F4EC); // wallet (green tint)
      case 'c':
        return const Color(0xFFEDE9FE); // cable TV (purple tint)
      case 'e':
        return const Color(0xFFFFF1D6); // electricity (amber tint)
      case 's':
        return const Color(0xFFE0F2FE); // bulk SMS (blue tint)
      case 'p':
        return const Color(0xFFCCFBF1); // edu pins (teal tint)
      case 'r':
        return const Color(0xFFE0E7FF); // recharge pin (indigo tint)
      case 'x':
        return const Color(0xFFDCFCE7); // Swarp (green tint)
      default:
        return const Color(0xFFE6F4EC); // data (green tint)
    }
  }

  /// Returns the status text color.
  Color get statusColor {
    switch (status) {
      case 'Successful':
        return const Color(0xFF0A5C3E);
      case 'Pending':
        return const Color(0xFF8A5A00);
      case 'Failed':
        return const Color(0xFF9B1C12);
      default:
        return const Color(0xFF0A5C3E);
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'date': date,
        'amount': amount,
        'status': status,
        'phone': phone,
        'ref': ref,
        'typeKey': typeKey,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      date: json['date'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'Successful',
      phone: json['phone'] as String? ?? '-',
      ref: json['ref'] as String? ?? '',
      typeKey: json['typeKey'] as String? ?? 'd',
    );
  }
}
