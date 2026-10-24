import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/phone_validator.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/network_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen>
    with AppStateListener<AirtimeScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (isValidNigerianPhone(appStore.phone)) {
      _phoneController.text = appStore.phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    return isValidNigerianPhone(_phoneController.text) && amount >= 50;
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
                  'Buy Airtime',
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
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 26),
                    const Text(
                      'Select Network',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 18),
                    AppInput(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _amountController,
                      label: 'Amount',
                      hint: 'Enter amount (min ₦50)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
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
                onPressed: _canProceed
                    ? () {
                        appStore.setPhone(_phoneController.text);
                        final amount = int.parse(_amountController.text.trim());
                        final tx = appRepository.purchaseData(
                          network: appStore.selectedNetwork,
                          type: 'Airtime ₦$amount',
                          price: amount,
                          phone: _phoneController.text,
                        );
                        if (tx == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Not enough balance. Fund your wallet.'),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.success,
                          (route) => route.settings.name == AppRoutes.home,
                        );
                      }
                    : null,
                child: const Text('Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
