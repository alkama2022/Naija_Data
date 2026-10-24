import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/network_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AirtimeSwapScreen extends StatefulWidget {
  const AirtimeSwapScreen({super.key});

  @override
  State<AirtimeSwapScreen> createState() => _AirtimeSwapScreenState();
}

class _AirtimeSwapScreenState extends State<AirtimeSwapScreen>
    with AppStateListener<AirtimeSwapScreen> {
  final _amountController = TextEditingController();
  String _fromNetwork = 'MTN';
  String _toNetwork = 'Airtel';

  bool get _canProceed {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    return amount >= 100 && _fromNetwork != _toNetwork;
  }

  void _swap() {
    if (!_canProceed) return;
    final amount = int.parse(_amountController.text.trim());
    final tx = appRepository.purchaseData(
      network: _fromNetwork,
      type: 'Airtime Swap $_fromNetwork -> $_toNetwork',
      price: amount,
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
                  'Airtime Swap',
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
                      'From Network',
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
                          final isSelected = net.name == _fromNetwork;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: NetworkChip(
                              network: net.name,
                              color: net.bgColor,
                              textColor: net.fgColor,
                              abbreviation: net.abbreviation,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() => _fromNetwork = net.name);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Icon(Icons.swap_vert, size: 32, color: kAccent),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'To Network',
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
                          final isSelected = net.name == _toNetwork;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: NetworkChip(
                              network: net.name,
                              color: net.bgColor,
                              textColor: net.fgColor,
                              abbreviation: net.abbreviation,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() => _toNetwork = net.name);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _amountController,
                      label: 'Amount',
                      hint: 'Enter amount to swap (min ₦100)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: AppButton(
                onPressed: _canProceed ? _swap : null,
                child: const Text('Swap Airtime'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
