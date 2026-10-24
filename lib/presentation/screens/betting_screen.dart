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

class BettingScreen extends StatefulWidget {
  const BettingScreen({super.key});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen>
    with AppStateListener<BettingScreen> {
  final _userIdController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedBookmaker = 'Bet9ja';

  final List<String> _bookmakers = [
    'Bet9ja',
    'SportyBet',
    'Betking',
    '1xBet',
    'Bangbet',
    'Merrybet',
  ];

  bool get _canProceed {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    return _userIdController.text.trim().isNotEmpty && amount >= 100;
  }

  void _fund() {
    if (!_canProceed) return;
    final amount = int.parse(_amountController.text.trim());
    final tx = appRepository.purchaseData(
      network: _selectedBookmaker,
      type: 'Betting Top-Up',
      price: amount,
      phone: _userIdController.text.trim(),
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
    _userIdController.dispose();
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
                  'Betting Top-Up',
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
                      'Select Bookmaker',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBookmaker,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _bookmakers
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedBookmaker = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _userIdController,
                      label: 'User ID / Customer ID',
                      hint: 'Enter your bookmaker ID',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _amountController,
                      label: 'Amount',
                      hint: 'Enter amount (min ₦100)',
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
                onPressed: _canProceed ? _fund : null,
                child: const Text('Fund Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
