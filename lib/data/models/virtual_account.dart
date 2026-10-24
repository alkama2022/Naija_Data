/// A funding account the customer can transfer money to.
class VirtualAccountModel {
  const VirtualAccountModel({
    required this.provider,
    required this.accountName,
    required this.accountNumber,
  });

  final String provider;
  final String accountName;
  final String accountNumber;
}
