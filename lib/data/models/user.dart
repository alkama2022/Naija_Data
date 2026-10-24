/// The logged-in user profile.
class UserModel {
  final String name;
  final String email;
  final String phone;
  final int balance;
  final bool kycVerified;
  final bool fingerprintEnabled;
  final bool balanceHidden;
  final int referralBonus;

  const UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.balance,
    this.kycVerified = false,
    this.fingerprintEnabled = false,
    this.balanceHidden = false,
    this.referralBonus = 450,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    int? balance,
    bool? kycVerified,
    bool? fingerprintEnabled,
    bool? balanceHidden,
    int? referralBonus,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      kycVerified: kycVerified ?? this.kycVerified,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      balanceHidden: balanceHidden ?? this.balanceHidden,
      referralBonus: referralBonus ?? this.referralBonus,
    );
  }
}
