import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/network_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataCardScreen extends StatefulWidget {
  const DataCardScreen({super.key});

  @override
  State<DataCardScreen> createState() => _DataCardScreenState();
}

class _DataCardScreenState extends State<DataCardScreen>
    with AppStateListener<DataCardScreen> {
  final _quantityController = TextEditingController(text: '1');
  String _selectedPlan = '1GB';

  final Map<String, int> _plans = {
    '500MB': 160,
    '1GB': 300,
    '2GB': 600,
    '5GB': 1500,
  };

  bool get _canProceed {
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    return qty >= 1;
  }

  int get _total {
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    return qty * (_plans[_selectedPlan] ?? 0);
  }

  void _buy() {
    if (!_canProceed) return;
    final tx = appRepository.purchaseData(
      network: appStore.selectedNetwork,
      type: 'Data Card $_selectedPlan x${_quantityController.text}',
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
                  'Data Card',
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
                    const Text(
                      'Select Data Plan',
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
                      children: _plans.keys.map((p) {
                        final selected = p == _selectedPlan;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPlan = p),
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
                              '$p - ${formatNaira(_plans[p]!)}',
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
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Number of data cards',
                        border: OutlineInputBorder(),
                      ),
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
                child: const Text('Buy Data Cards'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
