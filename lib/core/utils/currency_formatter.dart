import 'package:intl/intl.dart';

/// Formats amounts in Nigerian Naira (₦) using the en-NG locale,
/// matching the prototype's N(x) helper: '₦' + Math.abs(x).toLocaleString('en-NG').
String formatNaira(num amount) {
  final formatter = NumberFormat('#,##0.00', 'en_NG');
  return '₦${formatter.format(amount.abs())}';
}

/// Formats a whole-number amount without decimals (used for quick amounts, chips).
String formatNairaWhole(num amount) {
  final formatter = NumberFormat('#,##0', 'en_NG');
  return '₦${formatter.format(amount.abs())}';
}
