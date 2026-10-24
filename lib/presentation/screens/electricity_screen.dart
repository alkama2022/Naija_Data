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

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen>
    with AppStateListener<ElectricityScreen> {
  final _meterController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedDisco = 'IKEJA ELECTRIC';
  String _meterType = 'Prepaid';

  final List<String> _discos = [
    'IKEJA ELECTRIC',
    'EKEDC',
    'IBEDC',
    'PHCN/PHED',
    'AEDC',
    'KEDCO',
    'JEDC',
    'EEDC',
  ];

  @override
  void dispose() {
    _meterController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    return _meterController.text.trim().isNotEmpty && amount >= 500;
  }

  void _pay() {
    if (!_canProceed) return;
    final amount = int.parse(_amountController.text.trim());
    final tx = appRepository.purchaseData(
      network: _selectedDisco,
      type: '$_meterType Electricity',
      price: amount,
      phone: _meterController.text.trim(),
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
                  'Electricity Bill',
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
                      'Select Disco',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDisco,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _discos
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedDisco = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Meter Type',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: ['Prepaid', 'Postpaid'].map((t) {
                        final selected = t == _meterType;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: t == 'Prepaid' ? 8 : 0),
                            child: GestureDetector(
                              onTap: () => setState(() => _meterType = t),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                      : kSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).primaryColor
                                        : kBorderMedium,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Theme.of(context).primaryColor
                                          : kTextPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _meterController,
                      label: 'Meter Number',
                      hint: 'Enter meter number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _amountController,
                      label: 'Amount',
                      hint: 'Enter amount (min ₦500)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount to Pay',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            formatNaira(int.tryParse(_amountController.text.trim()) ?? 0),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: kAccent,
                                fontSize: 16),
                          ),
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
                child: const Text('Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
