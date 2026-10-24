import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BulkSmsScreen extends StatefulWidget {
  const BulkSmsScreen({super.key});

  @override
  State<BulkSmsScreen> createState() => _BulkSmsScreenState();
}

class _BulkSmsScreenState extends State<BulkSmsScreen>
    with AppStateListener<BulkSmsScreen> {
  final _unitsController = TextEditingController(text: '1000');
  final _senderController = TextEditingController();
  final _messageController = TextEditingController();

  final Map<int, int> _rates = {
    1000: 4000,
    2000: 7800,
    5000: 18500,
    10000: 36000,
  };

  int get _units => int.tryParse(_unitsController.text.trim()) ?? 0;
  int get _price => _rates[_units] ?? (_units * 4);

  bool get _canProceed =>
      _units >= 500 && _senderController.text.trim().isNotEmpty && _messageController.text.trim().isNotEmpty;

  void _pay() {
    if (!_canProceed) return;
    final tx = appRepository.purchaseData(
      network: 'SMS',
      type: 'Bulk SMS $_units units',
      price: _price,
      phone: _senderController.text.trim(),
    );
    if (tx == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough balance. Fund your wallet.')),
      );
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.success,
      (route) => route.settings.name == AppRoutes.home,
    );
  }

  @override
  void dispose() {
    _unitsController.dispose();
    _senderController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                    }
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bulk SMS',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      'Quick Packages',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _rates.keys.map((u) {
                        final selected = _units == u;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _unitsController.text = u.toString();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                  : kSurface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? Theme.of(context).primaryColor
                                    : kBorderMedium,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$u units',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Theme.of(context).primaryColor
                                        : kTextPrimary,
                                  ),
                                ),
                                Text(
                                  formatNaira(_rates[u]!),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _unitsController,
                      label: 'Number of Units',
                      hint: 'Enter units (min 500)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _senderController,
                      label: 'Sender ID',
                      hint: 'Enter sender name (max 11 chars)',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _messageController,
                      label: 'Message',
                      hint: 'Enter your message',
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount to Pay',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(formatNaira(_price),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: kAccent,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: AppButton(
                onPressed: _canProceed ? _pay : null,
                child: const Text('Send SMS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
