import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Security screen — fingerprint toggle, change password, passcode.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen>
    with AppStateListener<SecurityScreen> {
  final _links = const [
    ['***', 'Change Password', 'Change your account password'],
    ['PIN', 'Transaction Passcode', 'Set or change your 4-digit passcode'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  BackButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.profile),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    ..._links.map((r) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EC),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              r[0],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: kAccent,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          r[1],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          r[2],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: kTextMuted,
                          ),
                        ),
                        trailing: const Text(
                          '›',
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextMuted,
                          ),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${r[1]} is not part of this demo'),
                            ),
                          );
                        },
                      );
                    }),
                    ...[
                      {
                        'ab': 'FP',
                        'name': 'Fingerprint',
                        'sub':
                            'Sign in and confirm purchases with your fingerprint',
                      },
                      {
                        'ab': 'N',
                        'name': 'Show wallet balance',
                        'sub': 'Show or hide your balance on Home',
                      },
                    ].map((r) {
                      final isFp = r['ab'] == 'FP';
                      final isActive = isFp
                          ? appStore.fingerprintEnabled
                          : !appStore.balanceHidden;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EC),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              r['ab']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: kAccent,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          r['name']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          r['sub']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: kTextMuted,
                          ),
                        ),
                        trailing: Switch(
                          value: isActive,
                          onChanged: (value) {
                            if (isFp) {
                              appStore.setFingerprintEnabled(value);
                              if (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fingerprint enabled for purchases.',
                                    ),
                                  ),
                                );
                              }
                            } else {
                              appStore.setBalanceHidden(!value);
                            }
                          },
                          activeThumbColor: kAccent,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your fingerprint stays on your phone. DataNaija never sees or stores it.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                  height: 1.45,
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
