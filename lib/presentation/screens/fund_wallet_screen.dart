import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fund Wallet screen — bank transfer, card/USSD, quick amounts.
class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen>
    with AppStateListener<FundWalletScreen> {
  final _amountController = TextEditingController(text: '1000');

  @override
  void initState() {
    super.initState();
    _amountController.text = appStore.fundAmount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _amount {
    return int.tryParse(_amountController.text) ?? 0;
  }

  bool get _canFund => _amount >= 100;

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
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.wallet);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Fund Wallet',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              // KYC-gated bank transfer section
              if (!appStore.kycVerified) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.5,
                      color: kAccent,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Get your funding account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Verify with your BVN or NIN to get a personal account number. It takes about a minute.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextMuted,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        child: const Text('Verify now'),
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.kyc),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Bank transfer details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.5, color: kAccent),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pay from any bank or wallet app',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        MockData.defaultAccountNumber,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.08,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Chinedu Okafor · [BANK NAME]',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Copy this account number and send any amount from your favourite app. Your wallet is credited automatically.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextMuted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        variant: ButtonVariant.primary,
                        child: const Text('Copy account number'),
                        onPressed: () async {
                          await Clipboard.setData(
                            const ClipboardData(
                              text: MockData.defaultAccountNumber,
                            ),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account number copied'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      AppLinkButton(
                        child: const Text(
                          'Demo: simulate a ₦2,000 transfer',
                        ),
                        onPressed: () {
                          appRepository.fundWallet(2000, 'Bank Transfer');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('₦2,000 received. Wallet credited.'),
                            ),
                          );
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.wallet);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Card/USSD section
              const Text(
                'Or pay with card or USSD',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              AppInput(
                controller: _amountController,
                label: 'Enter Amount',
                hint: '',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                ],
                // Keep typing local. The store is updated when the customer
                // continues, so a keystroke does not notify every screen.
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: [1000, 2000, 5000, 10000].length,
                  itemBuilder: (context, i) {
                    final amount = [1000, 2000, 5000, 10000][i];
                    final isSelected = _amount == amount;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          _amountController.text = amount.toString();
                          appStore.setFundAmount(amount.toString());
                          setState(() {});
                        },
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.5,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : kBorderMedium,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            color: isSelected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1)
                                : kBackground,
                          ),
                          child: Center(
                            child: Text(
                              formatNaira(amount),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : kTextPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...['Card Payment', 'USSD'].map((method) {
                final isSelected = appStore.paymentMethod == method;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: ElevatedButton(
                      onPressed: () {
                        appStore.setPaymentMethod(method);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)
                            : kSurface,
                        foregroundColor: isSelected
                            ? Theme.of(context).primaryColor
                            : kTextPrimary,
                        elevation: 0,
                        side: BorderSide(
                          width: 1.5,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : kBorderMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size(0, 56),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              method,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSelected ? 'Selected' : '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.all(kPagePadding),
                child: AppButton(
                  onPressed: _canFund
                      ? () {
                          appStore.setFundAmount(_amountController.text);
                          appRepository.fundWallet(
                              _amount, appStore.paymentMethod);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Wallet funded with ${formatNaira(_amount)}'),
                            ),
                          );
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.wallet);
                          }
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
