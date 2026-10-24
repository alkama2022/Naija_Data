import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/auto_buy_frequency.dart';
import 'package:data_naija_app/core/utils/auto_buy_schedule_engine.dart';
import 'package:data_naija_app/core/utils/auto_buy_time.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/core/utils/phone_validator.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/data/models/data_plan.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/checkbox_row.dart';
import 'package:data_naija_app/presentation/widgets/network_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Auto-Buy setup screen.
///
/// The customer picks the network, the number, the bundle, how often it
/// should be bought and at what time. The summary at the bottom and the
/// confirmation sheet make it clear exactly what will happen before the
/// rule is activated.
class AutoBuySetupScreen extends StatefulWidget {
  const AutoBuySetupScreen({super.key, this.existing});

  /// The rule being edited. `null` creates a new rule.
  final AutoBuySchedule? existing;

  @override
  State<AutoBuySetupScreen> createState() => _AutoBuySetupScreenState();
}

class _AutoBuySetupScreenState extends State<AutoBuySetupScreen> {
  late final TextEditingController _phoneController;

  late String _network;
  late String _dataType;
  late DataPlanModel? _plan;
  late String _frequencyKey;
  late int _customInterval;
  late AutoBuyUnit _customUnit;
  late Set<int> _daysOfWeek;
  late String _timeOfDay;
  late DateTime? _startDate;
  bool _consent = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _network = existing?.network ?? 'MTN';
    _dataType = existing?.planType ?? 'SME';
    _plan = _findPlan(
      existing?.planType ?? _dataType,
      existing?.planGb,
      existing?.planDays,
    );
    _frequencyKey = existing?.frequency ?? AutoBuyFrequencies.defaultKey;
    _customInterval = existing?.interval ?? 3;
    _customUnit = existing?.unitType ?? AutoBuyUnit.days;
    _daysOfWeek = {...?existing?.daysOfWeek};
    _timeOfDay = existing?.timeOfDay ?? '08:00';
    _startDate = null;
    _phoneController = TextEditingController(
      text: existing?.phone ?? MockData.defaultUser.phone,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  DataPlanModel? _findPlan(String type, String? gb, String? days) {
    final config = MockData.dataTypes[type];
    if (config == null || gb == null || days == null) return null;
    for (final plan in config.plans) {
      if (plan.gb == gb && plan.days == days) return plan;
    }
    return null;
  }

  AutoBuyFrequencyOption get _frequencyOption =>
      AutoBuyFrequencies.byKey(_frequencyKey) ??
      AutoBuyFrequencies.byKey(AutoBuyFrequencies.defaultKey)!;

  /// The effective interval and unit of the rule.
  ({int interval, AutoBuyUnit unit}) get _resolved {
    if (_frequencyKey == 'custom') {
      return (interval: _customInterval, unit: _customUnit);
    }
    return (interval: _frequencyOption.interval, unit: _frequencyOption.unit);
  }

  /// The preview of the next purchase, shown live while the customer
  /// picks the schedule.
  DateTime get _previewNextRun {
    final resolved = _resolved;
    final now = DateTime.now().toUtc();
    final anchorAt = AutoBuyScheduleEngine.resolveAnchor(
      from: now,
      unit: resolved.unit,
      interval: resolved.interval,
      daysOfWeek: _daysOfWeek.toList(),
      timeOfDay: _timeOfDay,
      startDate: _startDate == null
          ? null
          : formatAutoBuyDateString(
              DateTime.utc(
                _startDate!.year,
                _startDate!.month,
                _startDate!.day,
              ),
            ),
    );
    final spec = AutoBuyScheduleSpec(
      frequency: _frequencyKey,
      interval: resolved.interval,
      unit: resolved.unit,
      daysOfWeek: _daysOfWeek.toList(),
      timeOfDay: _timeOfDay,
      timezone: kAutoBuyTimezone,
      anchorAt: anchorAt,
    );
    return AutoBuyScheduleEngine.computeNextRun(spec, now);
  }

  bool get _canActivate {
    if (_plan == null) return false;
    if (!isValidNigerianPhone(_phoneController.text)) return false;
    if (_resolved.unit == AutoBuyUnit.weeks && _daysOfWeek.isEmpty) {
      return false;
    }
    if (_frequencyKey == 'custom' &&
        (_customInterval < AutoBuyFrequencies.customIntervalMin ||
            _customInterval > AutoBuyFrequencies.customIntervalMax)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolved;
    final preview = _previewNextRun;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                BackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing ? 'Edit Auto-Buy' : 'New Auto-Buy',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  kPagePadding,
                  8,
                  kPagePadding,
                  16,
                ),
                children: [
                  _sectionTitle('Select Network'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: MockData.networks.length,
                      itemBuilder: (context, i) {
                        final net = MockData.networks[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: NetworkChip(
                            network: net.name,
                            color: net.bgColor,
                            textColor: net.fgColor,
                            abbreviation: net.abbreviation,
                            isSelected: net.name == _network,
                            onTap: () => setState(() => _network = net.name),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Phone Number'),
                  const SizedBox(height: 4),
                  AppInput(
                    controller: _phoneController,
                    label: '',
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Select Data Bundle'),
                  const SizedBox(height: 10),
                  _buildTypeChips(),
                  const SizedBox(height: 10),
                  _buildPlanList(),
                  const SizedBox(height: 18),
                  _sectionTitle('How often?'),
                  const SizedBox(height: 10),
                  _buildFrequencyList(),
                  if (_frequencyKey == 'custom') ...[
                    const SizedBox(height: 12),
                    _buildCustomControls(),
                  ],
                  if (resolved.unit == AutoBuyUnit.weeks) ...[
                    const SizedBox(height: 14),
                    _sectionTitle('Which days?'),
                    const SizedBox(height: 8),
                    _buildWeekdayPicker(),
                  ],
                  const SizedBox(height: 18),
                  _sectionTitle('When should it run?'),
                  const SizedBox(height: 10),
                  _buildTimeRow(),
                  const SizedBox(height: 10),
                  _buildStartDateRow(),
                  const SizedBox(height: 18),
                  _buildSummaryCard(preview),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(kPagePadding),
              decoration: const BoxDecoration(
                color: kSurface,
                border:
                    Border(top: BorderSide(width: 1.0, color: kBorderLight)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Price per purchase',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTextMuted,
                        ),
                      ),
                      Text(
                        formatNaira(_plan?.price ?? 0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kAmountPositive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    enabled: _canActivate && !_saving,
                    onPressed: _canActivate ? _openConfirmation : null,
                    child: Text(
                      _isEditing ? 'Save Changes' : 'Activate Auto-Buy',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: kTextPrimary,
      ),
    );
  }

  Widget _buildTypeChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: MockData.dataTypes.keys.length,
        itemBuilder: (context, i) {
          final typeName = MockData.dataTypes.keys.elementAt(i);
          final isSelected = typeName == _dataType;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() {
                _dataType = typeName;
                _plan = null;
              }),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.5,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : kBorderMedium,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  color: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : kBackground,
                ),
                child: Center(
                  child: Text(
                    typeName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : kTextPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanList() {
    final config = MockData.dataTypes[_dataType]!;
    if (config.plans.isEmpty) {
      return const Text(
        'No bundles available for this data type.',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: kTextMuted,
        ),
      );
    }

    return Column(
      children: config.plans.map((plan) {
        final isSelected = _plan?.gb == plan.gb && _plan?.days == plan.days;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => setState(() => _plan = plan),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? Theme.of(context).primaryColor : kSurface,
                foregroundColor: isSelected ? kTextOnAccent : kTextPrimary,
                elevation: 0,
                side: isSelected
                    ? null
                    : const BorderSide(width: 1.5, color: kBorderMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.centerLeft,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.gb,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          plan.days,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatNaira(plan.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B7A4B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencyList() {
    return Column(
      children: AutoBuyFrequencies.all.map((option) {
        final isSelected = option.key == _frequencyKey;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: InkWell(
            onTap: () => setState(() {
              _frequencyKey = option.key;
              if (option.key == 'custom') {
                _customUnit = option.unit;
                _customInterval = option.interval;
              }
              if (option.unit != AutoBuyUnit.weeks) {
                _daysOfWeek.clear();
              }
            }),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.5,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : kBorderMedium,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                    : kSurface,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : kTextMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? kTextPrimary : kTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomControls() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Repeat every',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _stepperButton(
                icon: Icons.remove,
                onPressed:
                    _customInterval > AutoBuyFrequencies.customIntervalMin
                        ? () => setState(() => _customInterval--)
                        : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_customInterval',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                ),
              ),
              _stepperButton(
                icon: Icons.add,
                onPressed:
                    _customInterval < AutoBuyFrequencies.customIntervalMax
                        ? () => setState(() => _customInterval++)
                        : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: AutoBuyUnit.values.map((unit) {
              final isSelected = unit == _customUnit;
              return GestureDetector(
                onTap: () => setState(() => _customUnit = unit),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.5,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : kBorderMedium,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : kSurface,
                  ),
                  child: Text(
                    unit.key,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : kTextPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: kBorderMedium),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onPressed == null ? kBorderMedium : kTextPrimary,
        ),
      ),
    );
  }

  Widget _buildWeekdayPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = _daysOfWeek.contains(day);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _daysOfWeek.remove(day);
            } else {
              _daysOfWeek.add(day);
            }
          }),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : kSurface,
              border: Border.all(
                width: 1.5,
                color:
                    isSelected ? Theme.of(context).primaryColor : kBorderMedium,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              kAutoBuyWeekdayLabels[i].substring(0, 1),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? kTextOnAccent : kTextPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeRow() {
    final parsed = parseAutoBuyTimeOfDay(_timeOfDay);
    final label = parsed == null
        ? _timeOfDay
        : formatAutoBuyClock(parsed.hour, parsed.minute);

    return _selectRow(
      icon: Icons.access_time,
      label: 'Purchase time',
      value: '$label (WAT)',
      onTap: _pickTime,
    );
  }

  Widget _buildStartDateRow() {
    final date = _startDate;
    return _selectRow(
      icon: Icons.calendar_today,
      label: 'Starts on',
      value: date == null ? 'Today' : '${date.day}/${date.month}/${date.year}',
      onTap: _pickStartDate,
    );
  }

  Widget _selectRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: kBorderMedium),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: kTextMuted),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 20, color: kTextMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(DateTime preview) {
    final resolved = _resolved;
    final spec = AutoBuyScheduleSpec(
      frequency: _frequencyKey,
      interval: resolved.interval,
      unit: resolved.unit,
      daysOfWeek: _daysOfWeek.toList(),
      timeOfDay: _timeOfDay,
      timezone: kAutoBuyTimezone,
      anchorAt: preview,
    );

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _summaryRow(
            'Bundle',
            _plan == null ? 'Not selected' : '${_plan!.gb} · ${_plan!.days}',
          ),
          _summaryRow('Network', _network),
          _summaryRow('Number', _phoneController.text),
          _summaryRow('Price', formatNaira(_plan?.price ?? 0)),
          _summaryRow('Schedule', AutoBuyScheduleEngine.describe(spec)),
          _summaryRow(
            'Next purchase',
            AutoBuyScheduleEngine.formatSlotLabel(preview),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextMuted,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final parsed = parseAutoBuyTimeOfDay(_timeOfDay) ?? (hour: 8, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parsed.hour, minute: parsed.minute),
    );
    if (picked == null) return;
    setState(() {
      _timeOfDay = formatAutoBuyTimeOfDay(picked.hour, picked.minute);
    });
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _startDate = picked);
  }

  /// Shows the confirmation sheet. The customer must tick the consent box
  /// before the rule is activated.
  Future<void> _openConfirmation() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kBorderRadiusSheet),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Confirm Auto-Buy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(_previewNextRun),
                    const SizedBox(height: 12),
                    CheckboxRow(
                      value: _consent,
                      onChanged: (value) =>
                          setSheetState(() => _consent = value),
                      title: 'I authorise DataNaija to buy this bundle '
                          'automatically from my wallet',
                      subtitle: 'You can pause or delete this rule at any '
                          'time.',
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      enabled: _consent,
                      onPressed: _consent
                          ? () => Navigator.of(sheetContext).pop(true)
                          : null,
                      child: const Text('Confirm & Activate'),
                    ),
                    const SizedBox(height: 6),
                    AppLinkButton(
                      fullWidth: true,
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) return;
    await _save();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final resolved = _resolved;
    final plan = _plan!;

    try {
      if (_isEditing) {
        await autoBuyRepository.update(
          widget.existing!.id,
          network: _network,
          planType: _dataType,
          planGb: plan.gb,
          planDays: plan.days,
          price: plan.price,
          phone: _phoneController.text,
          frequency: _frequencyKey,
          interval: resolved.interval,
          unit: resolved.unit,
          daysOfWeek: _daysOfWeek.toList(),
          timeOfDay: _timeOfDay,
          startDate: _startDate == null
              ? null
              : formatAutoBuyDateString(
                  DateTime.utc(
                    _startDate!.year,
                    _startDate!.month,
                    _startDate!.day,
                  ),
                ),
        );
      } else {
        await autoBuyRepository.create(
          network: _network,
          planType: _dataType,
          planGb: plan.gb,
          planDays: plan.days,
          price: plan.price,
          phone: _phoneController.text,
          frequency: _frequencyKey,
          interval: resolved.interval,
          unit: resolved.unit,
          daysOfWeek: _daysOfWeek.toList(),
          timeOfDay: _timeOfDay,
          startDate: _startDate == null
              ? null
              : formatAutoBuyDateString(
                  DateTime.utc(
                    _startDate!.year,
                    _startDate!.month,
                    _startDate!.day,
                  ),
                ),
        );
      }

      if (!mounted) return;
      await _showSuccess();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.autoBuyList,
        (route) => route.settings.name == AppRoutes.autoBuyList,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save the schedule: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showSuccess() async {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusCard),
        ),
        title: const Text(
          'Auto-Buy activated',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
          ),
        ),
        content: const Text(
          'Your bundle will be bought automatically on the schedule you '
          'chose. We will let you know after every purchase.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextMuted,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
