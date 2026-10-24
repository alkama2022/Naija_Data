import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/core/utils/phone_validator.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/mock/service_catalog.dart';
import 'package:data_naija_app/data/models/network.dart';
import 'package:data_naija_app/data/models/service.dart';
import 'package:data_naija_app/data/models/transaction.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/network_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared purchase screen for Airtime, Cable TV, Electricity, Bulk SMS,
/// Edu Pins, Recharge Pin and Swarp.
///
/// The service is chosen by the [kind] the home screen passes in, and the
/// catalogue decides which providers, packages and fields are shown.
class ServicePurchaseScreen extends StatefulWidget {
  const ServicePurchaseScreen({super.key, required this.kind});

  final ServiceKind kind;

  @override
  State<ServicePurchaseScreen> createState() => _ServicePurchaseScreenState();
}

class _ServicePurchaseScreenState extends State<ServicePurchaseScreen>
    with AppStateListener<ServicePurchaseScreen> {
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _senderController = TextEditingController(text: 'DataNaija');
  final _messageController = TextEditingController();

  String? _provider;
  String _meterType = 'Prepaid';
  ServicePackage? _package;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    final providers = ServiceCatalog.providers[widget.kind] ?? const <String>[];
    _provider = providers.isEmpty ? null : providers.first;

    final packages = ServiceCatalog.packagesFor(widget.kind, _provider);
    _package = packages.isEmpty ? null : packages.first;

    _amountController.text = switch (widget.kind) {
      ServiceKind.airtime => '500',
      ServiceKind.electricity => '1000',
      ServiceKind.rechargePin => '500',
      ServiceKind.swarp => '500',
      _ => '',
    };

    if (isValidNigerianPhone(appStore.phone)) {
      _numberController.text = appStore.phone;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    _senderController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  int get _enteredAmount => int.tryParse(_amountController.text) ?? 0;

  int get _amount =>
      widget.kind.usesAmount ? _enteredAmount : (_package?.price ?? 0);

  int get _payout => ServiceCatalog.swarpPayout(_amount);

  List<String> get _recipients => _numberController.text
      .split(RegExp(r'[,\s]+'))
      .where((value) => value.isNotEmpty)
      .toList();

  bool get _decoderValid => _numberController.text
          .replaceAll(RegExp(r'[^0-9A-Za-z]'), '')
          .length >=
      8;

  bool get _meterValid =>
      _numberController.text.replaceAll(RegExp(r'\D'), '').length >= 10;

  bool get _canProceed {
    if (widget.kind.usesProvider && _provider == null) return false;

    switch (widget.kind) {
      case ServiceKind.airtime:
        return isValidNigerianPhone(_numberController.text) &&
            _enteredAmount >= 50;
      case ServiceKind.cable:
        return _package != null && _decoderValid;
      case ServiceKind.electricity:
        return _meterValid && _enteredAmount >= 500;
      case ServiceKind.bulkSms:
        return _package != null &&
            _recipients.isNotEmpty &&
            _recipients.every(isValidNigerianPhone) &&
            _senderController.text.trim().isNotEmpty &&
            _messageController.text.trim().isNotEmpty;
      case ServiceKind.eduPin:
        return _package != null && isValidNigerianPhone(_numberController.text);
      case ServiceKind.rechargePin:
        return isValidNigerianPhone(_numberController.text) &&
            _enteredAmount >= 100;
      case ServiceKind.swarp:
        return isValidNigerianPhone(_numberController.text) &&
            _enteredAmount >= 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabel = widget.kind == ServiceKind.swarp
        ? 'Swap for ${formatNairaWhole(_payout)}'
        : 'Pay ${formatNairaWhole(_amount)}';

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                BackButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.home);
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.kind.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: kPagePadding,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 18),
                    _serviceIntro(),
                    _providerSection(),
                    _packageSection(),
                    _amountSection(),
                    _detailsSection(),
                    _summarySection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: AppButton(
                enabled: _canProceed && !_submitting,
                onPressed: _canProceed && !_submitting ? _submit : null,
                child: Text(_submitting ? 'Processing...' : buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceIntro() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            widget.kind.icon,
            size: 23,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.kind.description,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kTextMuted,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _providerSection() {
    if (!widget.kind.usesProvider) return const SizedBox.shrink();

    final providers =
        ServiceCatalog.providers[widget.kind] ?? const <String>[];
    final isNetwork = widget.kind == ServiceKind.airtime ||
        widget.kind == ServiceKind.rechargePin ||
        widget.kind == ServiceKind.swarp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(
          isNetwork ? 'Select Network' : 'Select Provider',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        if (isNetwork)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: providers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final name = providers[i];
                final net = _networkByName(name);
                if (net == null) return _providerChip(name);
                return NetworkChip(
                  network: net.name,
                  color: net.bgColor,
                  textColor: net.fgColor,
                  abbreviation: net.abbreviation,
                  isSelected: name == _provider,
                  onTap: () => _selectProvider(name),
                );
              },
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in providers) _providerChip(name),
            ],
          ),
      ],
    );
  }

  Widget _providerChip(String name) {
    final selected = _provider == name;
    return GestureDetector(
      onTap: () => _selectProvider(name),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : kBackground,
          border: Border.all(
            width: 1.5,
            color: selected
                ? Theme.of(context).primaryColor
                : kBorderMedium,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Theme.of(context).primaryColor : kTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _packageSection() {
    final packages = ServiceCatalog.packagesFor(widget.kind, _provider);
    if (packages.isEmpty) return const SizedBox.shrink();

    final title = switch (widget.kind) {
      ServiceKind.cable => 'Choose a package',
      ServiceKind.bulkSms => 'Choose an SMS bundle',
      ServiceKind.eduPin => 'Choose a pin',
      _ => 'Choose a package',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        for (final package in packages) _packageCard(package),
      ],
    );
  }

  Widget _packageCard(ServicePackage package) {
    final isSelected = _package == package;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () => setState(() => _package = package),
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
          minimumSize: const Size(double.infinity, 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    package.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    package.detail,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? kTextOnAccent.withValues(alpha: 0.8)
                          : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatNairaWhole(package.price),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected ? kTextOnAccent : const Color(0xFF0B7A4B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountSection() {
    if (!widget.kind.usesAmount) return const SizedBox.shrink();

    final quickAmounts = ServiceCatalog.amountsFor(widget.kind);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        AppInput(
          controller: _amountController,
          label: 'Amount',
          hint: 'Enter amount',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7),
          ],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final amount in quickAmounts) _amountChip(amount),
          ],
        ),
      ],
    );
  }

  Widget _amountChip(int amount) {
    final selected = _enteredAmount == amount;
    return GestureDetector(
      onTap: () {
        _amountController.text = amount.toString();
        setState(() {});
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : kBackground,
          border: Border.all(
            width: 1.5,
            color: selected
                ? Theme.of(context).primaryColor
                : kBorderMedium,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            formatNairaWhole(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Theme.of(context).primaryColor : kTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsSection() {
    switch (widget.kind) {
      case ServiceKind.airtime:
        return _phoneField();
      case ServiceKind.cable:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            AppInput(
              controller: _numberController,
              label: 'Smartcard / Decoder Number',
              hint: 'Enter smartcard number',
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]')),
                LengthLimitingTextInputFormatter(16),
              ],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            const Text(
              'Found on your decoder or cable TV bill.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
              ),
            ),
          ],
        );
      case ServiceKind.electricity:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            const Text(
              'Meter Type',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final type in const ['Prepaid', 'Postpaid'])
                  GestureDetector(
                    onTap: () => setState(() => _meterType = type),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _meterType == type
                            ? Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)
                            : kBackground,
                        border: Border.all(
                          width: 1.5,
                          color: _meterType == type
                              ? Theme.of(context).primaryColor
                              : kBorderMedium,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _meterType == type
                                ? Theme.of(context).primaryColor
                                : kTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppInput(
              controller: _numberController,
              label: 'Meter Number',
              hint: 'Enter meter number',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            const Text(
              'We will credit the meter number you enter.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
              ),
            ),
          ],
        );
      case ServiceKind.bulkSms:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            AppInput(
              controller: _numberController,
              label: 'Recipient Numbers',
              hint: 'e.g. 08012345678, 08098765432',
              keyboardType: TextInputType.phone,
              minLines: 2,
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            const Text(
              'Separate each number with a comma or a space.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
              ),
            ),
            AppInput(
              controller: _senderController,
              label: 'Sender ID',
              hint: 'e.g. DataNaija',
              maxLength: 11,
              onChanged: (_) => setState(() {}),
            ),
            AppInput(
              controller: _messageController,
              label: 'Message',
              hint: 'Type your message',
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 4,
              maxLength: 160,
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
      case ServiceKind.eduPin:
        return _phoneField(
          note: 'Your PIN will be sent to this number by SMS.',
        );
      case ServiceKind.rechargePin:
        return _phoneField(
          note: 'Your recharge PIN will be sent to this number by SMS.',
        );
      case ServiceKind.swarp:
        return _phoneField(
          note: 'Airtime on this number will be converted to wallet cash.',
        );
    }
  }

  Widget _phoneField({String? note}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          controller: _numberController,
          label: 'Phone Number',
          hint: 'Enter phone number',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text(
          note ?? 'e.g. 08012345678',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kTextMuted,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _summarySection() {
    if (_amount <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _kvRow('Service', widget.kind.title),
              if (_provider != null) _kvRow('Provider', _provider!),
              if (_package != null) _kvRow('Package', _package!.name),
              if (_numberController.text.trim().isNotEmpty)
                _kvRow(_recipientLabel, _recipientSummary),
              if (widget.kind == ServiceKind.swarp) ...[
                _kvRow('Airtime Value', formatNairaWhole(_amount)),
                _kvRow(
                  'You Receive',
                  formatNairaWhole(_payout),
                  isTotal: true,
                ),
              ] else
                _kvRow('Amount', formatNairaWhole(_amount), isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  String get _recipientLabel {
    switch (widget.kind) {
      case ServiceKind.cable:
        return 'Smartcard Number';
      case ServiceKind.electricity:
        return 'Meter Number';
      case ServiceKind.bulkSms:
        return 'Recipients';
      default:
        return 'Phone Number';
    }
  }

  String get _recipientSummary {
    if (widget.kind != ServiceKind.bulkSms) {
      return _numberController.text.trim();
    }
    final count = _recipients.length;
    return '$count recipient${count == 1 ? '' : 's'}';
  }

  Widget _kvRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? kTextPrimary : kTextMuted,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isTotal ? const Color(0xFF0B7A4B) : kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  NetworkModel? _networkByName(String name) {
    for (final network in MockData.networks) {
      if (network.name == name) return network;
    }
    return null;
  }

  void _selectProvider(String name) {
    final packages = ServiceCatalog.packagesFor(widget.kind, name);
    setState(() {
      _provider = name;
      _package = packages.isEmpty ? null : packages.first;
    });
  }

  String get _contact {
    if (widget.kind == ServiceKind.bulkSms) {
      return _recipients.isEmpty ? '-' : _recipients.first;
    }
    return _numberController.text.trim();
  }

  String get _transactionSubtitle {
    switch (widget.kind) {
      case ServiceKind.airtime:
        return '$_provider ${formatNairaWhole(_amount)}';
      case ServiceKind.cable:
        return '$_provider · ${_package?.name ?? ''}';
      case ServiceKind.electricity:
        return '$_provider · $_meterType ${formatNairaWhole(_amount)}';
      case ServiceKind.bulkSms:
        final count = _recipients.length;
        return '${_package?.name ?? ''} · $count recipient'
            '${count == 1 ? '' : 's'}';
      case ServiceKind.eduPin:
        return _package?.name ?? '';
      case ServiceKind.rechargePin:
        return '$_provider ${formatNairaWhole(_amount)}';
      case ServiceKind.swarp:
        return '$_provider airtime to wallet';
    }
  }

  String get _transactionTitle {
    switch (widget.kind) {
      case ServiceKind.airtime:
        return 'Airtime Purchase';
      case ServiceKind.cable:
        return 'Cable TV';
      case ServiceKind.electricity:
        return 'Electricity';
      case ServiceKind.bulkSms:
        return 'Bulk SMS';
      case ServiceKind.eduPin:
        return 'Edu PIN';
      case ServiceKind.rechargePin:
        return 'Recharge PIN';
      case ServiceKind.swarp:
        return 'Swarp';
    }
  }

  String get _typeKey {
    switch (widget.kind) {
      case ServiceKind.airtime:
        return 'a';
      case ServiceKind.cable:
        return 'c';
      case ServiceKind.electricity:
        return 'e';
      case ServiceKind.bulkSms:
        return 's';
      case ServiceKind.eduPin:
        return 'p';
      case ServiceKind.rechargePin:
        return 'r';
      case ServiceKind.swarp:
        return 'x';
    }
  }

  Future<void> _submit() async {
    if (_submitting || !_canProceed) return;

    final amount = _amount;
    if (widget.kind != ServiceKind.swarp && appRepository.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough balance. Fund your wallet.'),
        ),
      );
      return;
    }

    if (!await _authorise()) return;
    if (!mounted) return;

    setState(() => _submitting = true);
    // A short pause mirrors the processing step used by the data flow.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    final TransactionModel? transaction;
    if (widget.kind == ServiceKind.swarp) {
      transaction = appRepository.swapAirtimeToWallet(
        network: _provider ?? 'MTN',
        phone: _contact,
        airtimeValue: amount,
        payout: _payout,
      );
    } else {
      transaction = appRepository.purchaseService(
        title: _transactionTitle,
        subtitle: _transactionSubtitle,
        amount: amount,
        phone: _contact,
        typeKey: _typeKey,
      );
    }

    if (transaction == null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough balance. Fund your wallet and retry.'),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.success,
      arguments: transaction,
    );
  }

  Future<bool> _authorise() async {
    if (!appStore.fingerprintEnabled) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirm with fingerprint',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Touch the sensor to authorise this purchase.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextMuted,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Use fingerprint'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}
