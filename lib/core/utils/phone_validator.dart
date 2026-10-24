/// Validates a Nigerian mobile number.
/// Matches the prototype regex: /^0[789][01]\d{8}$/
bool isValidNigerianPhone(String? value) {
  if (value == null || value.isEmpty) return false;
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return RegExp(r'^0[789][01]\d{8}$').hasMatch(digits);
}

/// Strips non-digit characters and truncates to 11 digits,
/// mirroring the prototype's setPhone handler.
String sanitizePhone(String value) {
  return value
      .replaceAll(RegExp(r'\D'), '')
      .substring(0, 11.clamp(0, value.replaceAll(RegExp(r'\D'), '').length));
}
