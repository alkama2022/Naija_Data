import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Select Data Bundle screen — Step 2: choose data type and plan.
class SelectBundleScreen extends StatefulWidget {
  const SelectBundleScreen({super.key});

  @override
  State<SelectBundleScreen> createState() => _SelectBundleScreenState();
}

class _SelectBundleScreenState extends State<SelectBundleScreen>
    with AppStateListener<SelectBundleScreen> {
  @override
  Widget build(BuildContext context) {
    final net = MockData.networks.firstWhere(
      (n) => n.name == appStore.selectedNetwork,
    );
    final typeConfig = MockData.dataTypes[appStore.dataType]!;

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
                      .pushReplacementNamed(AppRoutes.buyData),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Data Bundle',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: net.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          net.abbreviation,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: net.fgColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      net.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
                AppLinkButton(
                  child: const Text('Change'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Choose data type',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: MockData.dataTypes.keys.length,
                itemBuilder: (context, i) {
                  final typeName = MockData.dataTypes.keys.elementAt(i);
                  final isSelected = typeName == appStore.dataType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        appStore.setDataType(typeName);
                        // Two families do not sell the same sizes, so make
                        // sure the chosen plan belongs to the new family.
                        final plans = MockData.dataTypes[typeName]!.plans;
                        if (plans.isNotEmpty) {
                          final plan = plans.first;
                          appStore.selectPlan(
                            plan.gb,
                            plan.days,
                            plan.price,
                          );
                        }
                      },
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            typeName,
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
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                typeConfig.description,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: typeConfig.plans.length,
                itemBuilder: (context, i) {
                  final plan = typeConfig.plans[i];
                  final isSelected = appStore.selectedGb == plan.gb &&
                      appStore.selectedDays == plan.days &&
                      appStore.selectedPrice == plan.price;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          appStore.selectPlan(plan.gb, plan.days, plan.price);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Theme.of(context).primaryColor
                              : kSurface,
                          foregroundColor:
                              isSelected ? kTextOnAccent : kTextPrimary,
                          elevation: 0,
                          side: isSelected
                              ? null
                              : const BorderSide(
                                  width: 1.5, color: kBorderMedium),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.gb,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    plan.days,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: kTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formatNaira(plan.price),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B7A4B),
                              ),
                            ),
                            if (plan.isHot) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1D6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Today only',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF8A5A00),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: AppButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.reviewPurchase);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
