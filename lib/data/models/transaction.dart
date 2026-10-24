import 'package:flutter/material.dart';

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
  });

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
