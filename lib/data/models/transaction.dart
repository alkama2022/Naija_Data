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
  final String typeKey; // 'd' = data, 'a' = airtime, 'w' = wallet

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

  /// Returns the display letter for the icon ('D', 'A', or 'W').
  String get letter {
    switch (typeKey) {
      case 'a':
        return 'A';
      case 'w':
        return 'W';
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
      default:
        return const Color(0xFFE6F4EC); // data (green tint)
    }
  }

  /// Returns the status pill style class name equivalent.
  String get pillClass {
    switch (status) {
      case 'Successful':
        return 'pill p-s';
      case 'Pending':
        return 'pill p-p';
      case 'Failed':
        return 'pill p-f';
      default:
        return 'pill p-s';
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
