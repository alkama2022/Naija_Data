import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/network_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RechargePinScreen extends StatefulWidget {
  const RechargePinScreen({super.key});

  @override
  State<RechargePinScreen> createState() => _RechargePinScreenState();
}

class _RechargePinScreenState extends State<RechargePinScreen>
    with AppStateListener<RechargePinScreen> {
  final _quantityController = TextEditingController(text: '1');
  final _amountController = TextEditingController(text: '100');

  bool get _canProceed {
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    return qty >= 1 && amount >= 50;
  }

  int get _total {
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    return qty * amount;
  }

  void _buy() {
    if (!_canProceed) return;
    final tx = appRepository.purchaseData(
      network: appStore.selectedNetwork,
      type: 'Recharge Pin (${_quantityController.text} x ₦${_amountController.text})',
      price: _total,
      phone: appStore.phone.isNotEmpty ? appStore.phone : 'N/A',
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
    _quantityController.dispose();
    _amountController.dispose();
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
                  'Recharge Pins',
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
                      'Select Network',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: MockData.networks.length,
                        itemBuilder: (context, i) {
                          final net = MockData.networks[i];
                          final isSelected = net.name == appStore.selectedNetwork;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: NetworkChip(
                              network: net.name,
                              color: net.bgColor,
                              textColor: net.fgColor,
                              abbreviation: net.abbreviation,
                              isSelected: isSelected,
                              onTap: () {
                                appStore.setSelectedNetwork(net.name);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _amountController,
                      label: 'Denomination (₦)',
                      hint: 'e.g. 100, 200, 500',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _quantityController,
                      label: 'Quantity',
                      hint: 'Number of pins',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(formatNaira(_total),
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
                onPressed: _canProceed ? _buy : null,
                child: const Text('Generate Pins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
