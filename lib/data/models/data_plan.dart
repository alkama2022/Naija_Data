/// A single data bundle plan.
///
/// Matches the prototype plan entries: [gb, days, price, hot?]
class DataPlanModel {
  final String gb;
  final String days;
  final int price;
  final bool isHot;

  const DataPlanModel({
    required this.gb,
    required this.days,
    required this.price,
    this.isHot = false,
  });
}
