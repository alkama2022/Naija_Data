import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/checkbox_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// KYC verification screen — BVN or NIN choice, ID input, consent, verify.
class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  String _selectedType = 'BVN';
  final _idController = TextEditingController();
  bool _consent = false;
  bool _verifying = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  bool get _canVerify {
    final digits = _idController.text.replaceAll(RegExp(r'\D'), '');
    return digits.length == 11 && _consent && !_verifying;
  }

  void _handleVerify() async {
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    appStore.setKycVerified(true);
    appStore.setKycId(_idController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verified. Your account number is ready.'),
      ),
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  String get _label {
    return _selectedType == 'BVN'
        ? 'Bank Verification Number (BVN)'
        : 'National Identification Number (NIN)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  BackButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.home),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Verify your identity',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const Text(
                'Nigerian banking rules require a BVN or NIN to give you a funding account. '
                'Choose either one. We send it to our partner for checking and do not keep the number.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'BVN'),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.5,
                            color: _selectedType == 'BVN'
                                ? Theme.of(context).primaryColor
                                : kBorderMedium,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          color: _selectedType == 'BVN'
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : kBackground,
                        ),
                        child: Center(
                          child: Text(
                            'BVN',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _selectedType == 'BVN'
                                  ? Theme.of(context).primaryColor
                                  : kTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'NIN'),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.5,
                            color: _selectedType == 'NIN'
                                ? Theme.of(context).primaryColor
                                : kBorderMedium,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          color: _selectedType == 'NIN'
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : kBackground,
                        ),
                        child: Center(
                          child: Text(
                            'NIN',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _selectedType == 'NIN'
                                  ? Theme.of(context).primaryColor
                                  : kTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _idController,
                label: _label,
                hint: '11 digits',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (v) => setState(() {}),
              ),
              const SizedBox(height: 16),
              CheckboxRow(
                value: _consent,
                onChanged: (v) => setState(() => _consent = v),
                title:
                    'I agree to DataNaija checking this number with NIBSS or NIMC to create my account.',
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: _canVerify ? _handleVerify : null,
                child: Text(_verifying ? 'Checking...' : 'Verify'),
              ),
              const SizedBox(height: 12),
              const Text(
                'One ID can be linked to one DataNaija account.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
