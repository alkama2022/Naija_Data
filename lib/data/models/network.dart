import 'package:flutter/material.dart';

/// Mobile network carrier configuration.
///
/// Matches the prototype's NETS map:
/// { name: [bgColor, fgColor, abbreviation] }
class NetworkModel {
  final String name;
  final Color bgColor;
  final Color fgColor;
  final String abbreviation;

  const NetworkModel({
    required this.name,
    required this.bgColor,
    required this.fgColor,
    required this.abbreviation,
  });
}
