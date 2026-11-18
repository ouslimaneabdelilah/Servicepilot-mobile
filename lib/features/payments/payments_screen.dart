import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_status_badge.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _payments = [];

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiClient.instance.dio.get('/payments');
      setState(() {
        _payments = List.from(res.data['data'] ?? []);
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message']?.toString() ?? 'Unable to load payment history.';
      });
    } catch (_) {
      setState(() => _error = 'Failed to load payments.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _methodIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'card':
        return Icons.credit_card_rounded;
      case 'check':
        return Icons.edit_note_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      case 'cash':
      default:
        return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'Payment Transactions',
        subtitle: '${_payments.length} transactions recorded',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadPayments,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _payments.isEmpty
                  ? AppEmptyState(
                      icon: Icons.payments_rounded,
                      title: 'No Payments Recorded Yet',
                      message: 'Payments can be recorded from any issued invoice to reconcile customer balances.',
                      actionLabel: 'View Invoices',
                      onAction: () => context.push('/invoices'),
                    )
                  : RefreshIndicator(
                      onRefresh: loadPayments,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.all(16),
                        itemCount: _payments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final p = _payments[idx];
                          final amount = (p['amount'] ?? '0.00').toString();
                          final method = (p['payment_method'] ?? 'cash').toString();
                          final status = (p['status'] ?? 'succeeded').toString();
                          final reference = p['reference_number']?.toString();
                          final paidAt = p['paid_at']?.toString() ?? p['created_at']?.toString() ?? '';
                          final invoiceId = p['invoice_id'];

                          return AppCard(
                            padding: const EdgeInsets.all(16),
                            onTap: invoiceId != null ? () => context.push('/invoices/$invoiceId') : null,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.successSurface,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: Icon(
                                    _methodIcon(method),
                                    color: AppColors.success,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        invoiceId != null ? 'Invoice #$invoiceId Payment' : 'Payment Transaction',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Method: ${method.replaceAll('_', ' ').toUpperCase()}${reference != null ? ' • Ref: $reference' : ''}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                      ),
                                      if (paidAt.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          paidAt.length >= 10 ? paidAt.substring(0, 10) : paidAt,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$$amount',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AppStatusBadge.fromStatus(status),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
