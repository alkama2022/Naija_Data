import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

class ExamPinsScreen extends StatefulWidget {
  const ExamPinsScreen({super.key});

  @override
  State<ExamPinsScreen> createState() => _ExamPinsScreenState();
}

class _ExamPinsScreenState extends State<ExamPinsScreen>
    with AppStateListener<ExamPinsScreen> {
  String _selectedType = 'JAMB';

  final Map<String, int> _prices = {
    'JAMB e-PIN': 7000,
    'JAMB Change of Course': 2500,
  };

  void _buy() {
    final price = _prices[_selectedType]!;
    final tx = appRepository.purchaseData(
      network: _selectedType,
      type: 'Exam PIN',
      price: price,
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
  Widget build(BuildContext context) {
    final price = _prices[_selectedType]!;
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
                  'JAMB/Exam Pins',
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
                      'Select Service',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _prices.entries.map((e) {
                        final selected = e.key == _selectedType;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                e.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: kTextPrimary),
                              ),
                              trailing: Text(
                                formatNaira(e.value),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: kAccent),
                              ),
                              onTap: () => setState(() => _selectedType = e.key),
                              leading: Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? Theme.of(context).primaryColor
                                    : kTextMuted,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount to Pay',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(formatNaira(price),
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
                onPressed: _buy,
                child: const Text('Buy PIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
