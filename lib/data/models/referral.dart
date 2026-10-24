import 'dart:math';

/// A referred friend with earning status.
class ReferralFriend {
  final String name;
  final String status; // 'Active' | 'Pending'
  final int earned;

  const ReferralFriend({
    required this.name,
    required this.status,
    required this.earned,
  });

  /// Two-letter initials for the avatar.
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }
}
