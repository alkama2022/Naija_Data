import 'package:data_naija_app/data/models/service.dart';

/// Local catalogue for the services sold alongside data bundles.
///
/// These are demo prices, like the rest of [MockData]. A real backend would
/// return the current catalogue and prices.
class ServiceCatalog {
  /// Networks / providers shown for each service that needs one.
  static const Map<ServiceKind, List<String>> providers = {
    ServiceKind.airtime: ['MTN', 'Airtel', 'Glo', '9mobile'],
    ServiceKind.cable: ['DSTV', 'GOtv', 'Startimes', 'Showmax'],
    ServiceKind.electricity: [
      'EKEDC',
      'IKEDC',
      'AEDC',
      'PHED',
      'KEDCO',
      'IBEDC',
      'EEDC',
    ],
    ServiceKind.rechargePin: ['MTN', 'Airtel', 'Glo', '9mobile'],
    ServiceKind.swarp: ['MTN', 'Airtel', 'Glo', '9mobile'],
  };

  /// Cable packages, grouped by provider.
  static const Map<String, List<ServicePackage>> cablePackages = {
    'DSTV': [
      ServicePackage(name: 'Padi', detail: '1 month', price: 4400),
      ServicePackage(name: 'Yanga', detail: '1 month', price: 6500),
      ServicePackage(name: 'Confam', detail: '1 month', price: 11000),
      ServicePackage(name: 'Compact', detail: '1 month', price: 19000),
      ServicePackage(name: 'Compact Plus', detail: '1 month', price: 30000),
      ServicePackage(name: 'Premium', detail: '1 month', price: 44500),
    ],
    'GOtv': [
      ServicePackage(name: 'Smallie', detail: '1 month', price: 1900),
      ServicePackage(name: 'Jinja', detail: '1 month', price: 3900),
      ServicePackage(name: 'Jolli', detail: '1 month', price: 5700),
      ServicePackage(name: 'Max', detail: '1 month', price: 8500),
      ServicePackage(name: 'Supa', detail: '1 month', price: 11400),
    ],
    'Startimes': [
      ServicePackage(name: 'Nova', detail: '1 month', price: 1900),
      ServicePackage(name: 'Basic', detail: '1 month', price: 3300),
      ServicePackage(name: 'Smart', detail: '1 month', price: 4700),
      ServicePackage(name: 'Classic', detail: '1 month', price: 5700),
      ServicePackage(name: 'Super', detail: '1 month', price: 8000),
    ],
    'Showmax': [
      ServicePackage(name: 'Mobile', detail: '1 month', price: 1600),
      ServicePackage(name: 'Entertainment', detail: '1 month', price: 3200),
      ServicePackage(name: 'Premier League', detail: '1 month', price: 4000),
      ServicePackage(name: 'Full', detail: '1 month', price: 6400),
    ],
  };

  /// Bulk SMS bundles. The price is for the whole bundle.
  static const List<ServicePackage> bulkSmsPackages = [
    ServicePackage(name: '100 SMS', detail: '₦7.00 per SMS', price: 700),
    ServicePackage(name: '500 SMS', detail: '₦6.00 per SMS', price: 3000),
    ServicePackage(name: '1,000 SMS', detail: '₦5.50 per SMS', price: 5500),
    ServicePackage(name: '5,000 SMS', detail: '₦5.00 per SMS', price: 25000),
    ServicePackage(name: '10,000 SMS', detail: '₦4.50 per SMS', price: 45000),
  ];

  /// Examination result-checker and registration pins.
  static const List<ServicePackage> eduPinPackages = [
    ServicePackage(
      name: 'WAEC Result Checker',
      detail: 'Scratch card PIN',
      price: 3500,
    ),
    ServicePackage(
      name: 'NECO Result Checker',
      detail: 'Scratch card PIN',
      price: 2500,
    ),
    ServicePackage(
      name: 'NABTEB Result Checker',
      detail: 'Scratch card PIN',
      price: 2000,
    ),
    ServicePackage(
      name: 'JAMB Registration PIN',
      detail: 'Profile PIN + mock PIN',
      price: 4500,
    ),
  ];

  static const List<int> airtimeAmounts = [100, 200, 500, 1000, 2000, 5000];
  static const List<int> electricityAmounts = [1000, 2000, 5000, 10000, 20000];
  static const List<int> rechargePinAmounts = [100, 200, 500, 1000, 2000, 5000];
  static const List<int> swarpAmounts = [500, 1000, 2000, 5000, 10000];

  /// The percentage of the airtime value paid into the wallet by Swarp.
  static const int swarpPercent = 85;

  /// The packages shown for [kind] and [provider].
  static List<ServicePackage> packagesFor(
    ServiceKind kind,
    String? provider,
  ) {
    switch (kind) {
      case ServiceKind.cable:
        return cablePackages[provider] ?? const [];
      case ServiceKind.bulkSms:
        return bulkSmsPackages;
      case ServiceKind.eduPin:
        return eduPinPackages;
      default:
        return const [];
    }
  }

  /// The quick amounts shown for [kind].
  static List<int> amountsFor(ServiceKind kind) {
    switch (kind) {
      case ServiceKind.airtime:
        return airtimeAmounts;
      case ServiceKind.electricity:
        return electricityAmounts;
      case ServiceKind.rechargePin:
        return rechargePinAmounts;
      case ServiceKind.swarp:
        return swarpAmounts;
      default:
        return const [];
    }
  }

  static int swarpPayout(int airtimeValue) {
    return airtimeValue * swarpPercent ~/ 100;
  }
}
