import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/errors/app_failure.dart';
import 'package:data_naija_app/data/models/transaction.dart';
import 'package:data_naija_app/data/services/api_service.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/chip_filter.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
import 'package:flutter/material.dart';

/// Transactions screen — search, filters, transaction list.
///
/// The list comes from the signed-in customer's backend account through
/// [ApiService]. The screen owns the loading, empty, offline and error states
/// with a retry action, so the history is never fabricated locally.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, this.apiService});

  final ApiService? apiService;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with AppStateListener<TransactionsScreen> {
  final _searchController = TextEditingController();
  late final ApiService _api = widget.apiService ?? ApiService();

  List<TransactionModel> _transactions = const [];
  bool _isLoading = true;
  String? _error;

  String _filter = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final rows = await _api.getTransactions(status: _filter, query: _query);
      final transactions = rows
          .map(
            (row) => TransactionModel.fromBackend(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _error = null;
        _isLoading = false;
      });
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.isOffline
            ? AppFailure.noInternetMessage
            : failure.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
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
              onChanged: (v) {
                setState(() => _query = v);
                _load();
              },
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
                      onTap: () {
                        setState(() => _filter = f);
                        _load();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kPagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined, size: 44, color: kTextMuted),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading && _transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions found.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kTextMuted,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: kPagePadding, vertical: 4),
        itemCount: _transactions.length,
        itemBuilder: (context, i) {
          final t = _transactions[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TransactionItem(
              transaction: t,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.transactionDetail,
                  arguments: t,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
