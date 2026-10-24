import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/models/data_plan.dart';
import 'package:data_naija_app/data/models/faq.dart';
import 'package:data_naija_app/data/models/network.dart';
import 'package:data_naija_app/data/models/notification.dart';
import 'package:data_naija_app/data/models/referral.dart';
import 'package:data_naija_app/data/models/transaction.dart';
import 'package:data_naija_app/data/models/user.dart';
import 'package:flutter/material.dart';

/// Sample data mirroring the prototype's hardcoded state.
///
/// This is a local-only data source. A real backend would replace this.
class MockData {
  // ── User ────────────────────────────────────────────────────────────

  static const UserModel defaultUser = UserModel(
    name: 'Chinedu Okafor',
    email: 'chinedu@example.com',
    phone: '08012345678',
    balance: 5000,
    kycVerified: false,
    fingerprintEnabled: false,
    balanceHidden: false,
    referralBonus: 450,
  );

  static const String defaultAccountNumber = '0123456789';

  // ── Networks ────────────────────────────────────────────────────────

  /// Matches the prototype's NETS map:
  /// { MTN: ['#FFCC00', '#10231A', 'MTN'],
  ///   Airtel: ['#E40000', '#fff', 'Ai'],
  ///   Glo: ['#17A34A', '#fff', 'glo'],
  ///   '9mobile': ['#1F2937', '#B7F34A', '9m'] }
  static const List<NetworkModel> networks = [
    NetworkModel(
      name: 'MTN',
      bgColor: Color(0xFFFFCC00),
      fgColor: Color(0xFF10231A),
      abbreviation: 'MTN',
    ),
    NetworkModel(
      name: 'Airtel',
      bgColor: Color(0xFFE40000),
      fgColor: Color(0xFFFFFFFF),
      abbreviation: 'Ai',
    ),
    NetworkModel(
      name: 'Glo',
      bgColor: Color(0xFF17A34A),
      fgColor: Color(0xFFFFFFFF),
      abbreviation: 'glo',
    ),
    NetworkModel(
      name: '9mobile',
      bgColor: Color(0xFF1F2937),
      fgColor: Color(0xFFB7F34A),
      abbreviation: '9m',
    ),
  ];

  // ── Data plan types ─────────────────────────────────────────────────

  /// Matches the prototype's TYPES map.
  /// Each entry: [description, [[gb, days, price, hot?], ...]]
  static const Map<String, DataTypeConfig> dataTypes = {
    'SME': DataTypeConfig(
      description: 'Lowest price for everyday browsing.',
      plans: [
        DataPlanModel(gb: '500MB', days: '30 Days', price: 160),
        DataPlanModel(gb: '1GB', days: '30 Days', price: 300),
        DataPlanModel(gb: '2GB', days: '30 Days', price: 600),
        DataPlanModel(gb: '5GB', days: '30 Days', price: 1500),
        DataPlanModel(gb: '10GB', days: '30 Days', price: 3000),
      ],
    ),
    'SME2': DataTypeConfig(
      description: 'An alternative route at a similar price.',
      plans: [
        DataPlanModel(gb: '1GB', days: '30 Days', price: 310),
        DataPlanModel(gb: '2GB', days: '30 Days', price: 620),
        DataPlanModel(gb: '5GB', days: '30 Days', price: 1550),
        DataPlanModel(gb: '10GB', days: '30 Days', price: 3100),
      ],
    ),
    'Gifting': DataTypeConfig(
      description: 'Sent to the number as a data gift.',
      plans: [
        DataPlanModel(gb: '1GB', days: '30 Days', price: 350),
        DataPlanModel(gb: '2GB', days: '30 Days', price: 700),
        DataPlanModel(gb: '5GB', days: '30 Days', price: 1750),
      ],
    ),
    'Corporate Gifting': DataTypeConfig(
      description: 'Best value on larger bundles.',
      plans: [
        DataPlanModel(gb: '2GB', days: '30 Days', price: 590),
        DataPlanModel(gb: '5GB', days: '30 Days', price: 1450),
        DataPlanModel(gb: '10GB', days: '30 Days', price: 2900),
        DataPlanModel(gb: '20GB', days: '30 Days', price: 5800),
      ],
    ),
    'Awoof': DataTypeConfig(
      description: 'Limited-time deals while stock lasts.',
      plans: [
        DataPlanModel(gb: '1.5GB', days: '2 Days', price: 250, isHot: true),
        DataPlanModel(gb: '3GB', days: '7 Days', price: 500, isHot: true),
        DataPlanModel(gb: '7GB', days: '7 Days', price: 1000, isHot: true),
      ],
    ),
  };

  // ── Popular bundles (home screen) ───────────────────────────────────

  static const List<PopularBundle> popularBundles = [
    PopularBundle(network: 'MTN', gb: '1GB', price: 300, days: '30 Days'),
    PopularBundle(network: 'Airtel', gb: '2GB', price: 600, days: '30 Days'),
    PopularBundle(network: 'Glo', gb: '1GB', price: 300, days: '30 Days'),
    PopularBundle(network: '9mobile', gb: '500MB', price: 160, days: '30 Days'),
  ];

  // ── Transactions ────────────────────────────────────────────────────

  static const List<TransactionModel> transactions = [
    TransactionModel(
      id: 1,
      title: 'Data Purchase',
      subtitle: 'MTN 1GB',
      date: 'Apr 25, 2025 · 02:15 PM',
      amount: -1000,
      status: 'Successful',
      phone: '08012345678',
      ref: 'DN123456789',
      typeKey: 'd',
    ),
    TransactionModel(
      id: 2,
      title: 'Airtime Purchase',
      subtitle: 'Airtel ₦500',
      date: 'Apr 24, 2025 · 11:20 AM',
      amount: -500,
      status: 'Successful',
      phone: '08098765432',
      ref: 'DN123456742',
      typeKey: 'a',
    ),
    TransactionModel(
      id: 3,
      title: 'Wallet Funding',
      subtitle: 'Bank Transfer',
      date: 'Apr 23, 2025 · 09:45 AM',
      amount: 5000,
      status: 'Successful',
      phone: '-',
      ref: 'DN123456701',
      typeKey: 'w',
    ),
    TransactionModel(
      id: 4,
      title: 'Data Purchase',
      subtitle: 'Glo 2GB',
      date: 'Apr 21, 2025 · 04:30 PM',
      amount: -2000,
      status: 'Failed',
      phone: '07012345678',
      ref: 'DN123456655',
      typeKey: 'd',
    ),
    TransactionModel(
      id: 5,
      title: 'Data Purchase',
      subtitle: '9mobile 1GB',
      date: 'Apr 20, 2025 · 08:05 AM',
      amount: -1000,
      status: 'Pending',
      phone: '09012345678',
      ref: 'DN123456610',
      typeKey: 'd',
    ),
  ];

  // ── Notifications ───────────────────────────────────────────────────

  static const List<NotificationModel> notifications = [
    NotificationModel(
      title: 'Purchase Successful',
      body: 'Your data purchase was successful.',
      date: 'Apr 25, 2025 · 02:15 PM',
      letter: 'D',
      isRead: true,
    ),
    NotificationModel(
      title: 'Wallet Funding',
      body: 'Your wallet has been funded with ₦5,000.',
      date: 'Apr 23, 2025 · 09:45 AM',
      letter: 'W',
      isRead: true,
    ),
    NotificationModel(
      title: 'Welcome to DataNaija',
      body: 'Thanks for joining us!',
      date: 'Apr 20, 2025 · 10:00 AM',
      letter: 'N',
      isRead: false,
    ),
    NotificationModel(
      title: 'System Update',
      body: "We've improved your experience.",
      date: 'Apr 18, 2025 · 08:30 PM',
      letter: 'S',
      isRead: false,
    ),
  ];

  // ── FAQs ────────────────────────────────────────────────────────────

  static const List<FaqItem> faqs = [
    FaqItem(
      question: 'How do I fund my wallet?',
      answer:
          'Open Fund Wallet, enter an amount, pick a payment method and continue.',
    ),
    FaqItem(
      question: 'How do I buy data?',
      answer:
          'Go to Buy Data, choose a network, enter the number, pick a bundle and confirm.',
    ),
    FaqItem(
      question: 'Why is my transaction pending?',
      answer:
          'Some purchases take a little longer. Check Transactions again shortly.',
    ),
    FaqItem(
      question: 'Can I get a refund?',
      answer: 'Failed purchases are refunded to your wallet automatically.',
    ),
    FaqItem(
      question: 'How do I reset my password?',
      answer: 'Use Forgot Password on the sign-in screen and follow the steps.',
    ),
  ];

  // ── Referral friends ────────────────────────────────────────────────

  static const List<ReferralFriend> friends = [
    ReferralFriend(name: 'Amina B.', status: 'Active', earned: 320),
    ReferralFriend(name: 'Tunde A.', status: 'Active', earned: 130),
    ReferralFriend(name: 'Funke A.', status: 'Pending', earned: 0),
  ];

  // ── Referral config ─────────────────────────────────────────────────

  /// Matches the prototype's REF config.
  static const int referralFirstBonus = 100;
  static const int referralPct = 20;
  static const int referralCap = 5000;
  static const int referralMin = 100;
  static const bool referralLife = true;
}

/// Configuration for a data plan type.
class DataTypeConfig {
  final String description;
  final List<DataPlanModel> plans;

  const DataTypeConfig({
    required this.description,
    required this.plans,
  });
}

/// A popular bundle shown on the home screen.
class PopularBundle {
  final String network;
  final String gb;
  final int price;
  final String days;

  const PopularBundle({
    required this.network,
    required this.gb,
    required this.price,
    required this.days,
  });

  String get priceText => formatNaira(price);
}
