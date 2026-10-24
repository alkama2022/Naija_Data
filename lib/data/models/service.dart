import 'package:flutter/material.dart';

/// The VTU services offered in addition to data bundles.
///
/// The label and description live here so the home screen and the purchase
/// screen always describe a service the same way.
enum ServiceKind {
  airtime(
    title: 'Buy Airtime',
    tileLabel: 'Airtime',
    description: 'Top up any Nigerian network instantly.',
    icon: Icons.phone_iphone,
  ),
  cable(
    title: 'Cable TV',
    tileLabel: 'Cable TV',
    description: 'Renew DSTV, GOtv, Startimes or Showmax.',
    icon: Icons.tv,
  ),
  electricity(
    title: 'Electricity',
    tileLabel: 'Electricity',
    description: 'Pay your prepaid or postpaid electricity bill.',
    icon: Icons.bolt,
  ),
  bulkSms(
    title: 'Bulk SMS',
    tileLabel: 'Bulk SMS',
    description: 'Send one message to many recipients at once.',
    icon: Icons.sms_outlined,
  ),
  eduPin(
    title: 'Edu Pins',
    tileLabel: 'Edu Pins',
    description: 'Buy WAEC, NECO, NABTEB and JAMB pins.',
    icon: Icons.school_outlined,
  ),
  rechargePin(
    title: 'Recharge Pin',
    tileLabel: 'Recharge Pin',
    description: 'Buy a recharge PIN and get it by SMS.',
    icon: Icons.pin_outlined,
  ),
  swarp(
    title: 'Swarp',
    tileLabel: 'Swarp',
    description: 'Turn airtime into wallet cash in seconds.',
    icon: Icons.swap_horiz,
  );

  const ServiceKind({
    required this.title,
    required this.tileLabel,
    required this.description,
    required this.icon,
  });

  final String title;
  final String tileLabel;
  final String description;
  final IconData icon;

  /// Whether the customer enters the amount themselves.
  bool get usesAmount =>
      this == ServiceKind.airtime ||
      this == ServiceKind.electricity ||
      this == ServiceKind.rechargePin ||
      this == ServiceKind.swarp;

  /// Whether the customer picks a network or provider first.
  bool get usesProvider =>
      this != ServiceKind.bulkSms && this != ServiceKind.eduPin;
}

/// A selectable bundle or package for a service.
class ServicePackage {
  const ServicePackage({
    required this.name,
    required this.detail,
    required this.price,
  });

  final String name;
  final String detail;
  final int price;
}
