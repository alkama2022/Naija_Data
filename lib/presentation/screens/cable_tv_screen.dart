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

class CableTvScreen extends StatefulWidget {
  const CableTvScreen({super.key});

  @override
  State<CableTvScreen> createState() => _CableTvScreenState();
}

class _CableTvScreenState extends State<CableTvScreen>
    with AppStateListener<CableTvScreen> {
  final _smartcardController = TextEditingController();
  String _selectedProvider = 'DSTV';
  String _selectedBouquet = 'Compact';

  final Map<String, Map<String, int>> _bouquets = {
    'DSTV': {
      'Access': 2000,
      'Compact': 9000,
      'Compact Plus': 14250,
      'Premium': 29500,
    },
    'GOTV': {
      'Smallie': 1100,
      'Jolli': 2460,
      'Max': 4850,
    },
    'Startimes': {
      'Nova': 900,
      'Basic': 1700,
      'Smart': 2500,
      'Classic': 2900,
    },
  };

  @override
  void dispose() {
    _smartcardController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    final price = _bouquets[_selectedProvider]?[_selectedBouquet] ?? 0;
    return _smartcardController.text.trim().isNotEmpty && price > 0;
  }

  void _pay() {
    if (!_canProceed) return;
    final price = _bouquets[_selectedProvider]![_selectedBouquet]!;
    final tx = appRepository.purchaseData(
      network: _selectedProvider,
      type: 'Cable TV - $_selectedBouquet',
      price: price,
      phone: _smartcardController.text.trim(),
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
    final price = _bouquets[_selectedProvider]?[_selectedBouquet] ?? 0;
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
                  'Cable TV Subscription',
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
                      'Select Provider',
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
                      children: ['DSTV', 'GOTV', 'Startimes'].map((p) {
                        final selected = p == _selectedProvider;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedProvider = p;
                              _selectedBouquet = _bouquets[p]!.keys.first;
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
                            child: Text(
                              p,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Theme.of(context).primaryColor
                                    : kTextPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _smartcardController,
                      label: 'Smartcard/IUC Number',
                      hint: 'Enter smartcard number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Bouquet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _bouquets[_selectedProvider]!.entries.map((e) {
                        final selected = e.key == _selectedBouquet;
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
                              onTap: () => setState(() => _selectedBouquet = e.key),
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
