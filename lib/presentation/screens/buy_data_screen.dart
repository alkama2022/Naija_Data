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

/// Buy Data screen — Step 1: select network and enter phone number.
class BuyDataScreen extends StatefulWidget {
  const BuyDataScreen({super.key});

  @override
  State<BuyDataScreen> createState() => _BuyDataScreenState();
}

class _BuyDataScreenState extends State<BuyDataScreen>
    with AppStateListener<BuyDataScreen> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start from the number the customer signed in with, when it is valid.
    if (isValidNigerianPhone(appStore.phone)) {
      _phoneController.text = appStore.phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    return isValidNigerianPhone(_phoneController.text);
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
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.home),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Buy Data',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            // Stepper
            Row(
              children: [
                _stepDot(1, true),
                _stepLine(),
                _stepDot(2, false),
                _stepLine(),
                _stepDot(3, false),
              ],
            ),
            const SizedBox(height: 14),
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
              // Only rebuild locally while typing. The store is updated when
              // the customer moves on, so a keystroke does not fan out to
              // every listener in the app.
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            const Text(
              'e.g. 08012345678',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: AppButton(
                onPressed: _canProceed
                    ? () {
                        appStore.setPhone(_phoneController.text);
                        Navigator.of(context).pushNamed(AppRoutes.selectBundle);
                      }
                    : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot(int number, bool active) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color:
            active ? Theme.of(context).primaryColor : const Color(0xFFE3EAE6),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : kTextMuted,
          ),
        ),
      ),
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: const Color(0xFFE3EAE6),
        margin: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
