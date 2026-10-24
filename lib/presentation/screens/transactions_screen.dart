import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/chip_filter.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
import 'package:flutter/material.dart';

/// Transactions screen — search, filters, transaction list.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with AppStateListener<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = appRepository.filterTransactions(
      statusFilter: _filter,
      query: _query,
    );

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                BackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppInput(
              controller: _searchController,
              label: 'Search',
              hint: 'Search transactions...',
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ['All', 'Successful', 'Pending', 'Failed'].length,
                itemBuilder: (context, i) {
                  final f = ['All', 'Successful', 'Pending', 'Failed'][i];
                  final isSelected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChipFilter(
                      name: f,
                      isSelected: isSelected,
                      onTap: () => setState(() => _filter = f),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions found.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final t = filtered[i];
                        return Column(
                          children: [
                            TransactionItem(
                              transaction: t,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.transactionDetail,
                                  arguments: t,
                                );
                              },
                            ),
                            if (i < filtered.length - 1)
                              const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
