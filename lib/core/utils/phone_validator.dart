/// Validates a Nigerian mobile number.
/// Matches the prototype regex: /^0[789][01]\d{8}$/
bool isValidNigerianPhone(String? value) {
  if (value == null || value.isEmpty) return false;
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return RegExp(r'^0[789][01]\d{8}$').hasMatch(digits);
}
