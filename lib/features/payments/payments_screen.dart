import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_empty_state.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Payment Transactions',
        subtitle: 'Cash, checks, card & reconciliations',
        showBack: true,
      ),
      body: Center(
        child: AppEmptyState(
          icon: Icons.payments_rounded,
          title: 'Recorded Payments',
          message: 'Review payment history and automatically reconcile invoice balances.',
          actionLabel: 'Record Payment',
          onAction: () {},
        ),
      ),
    );
  }
}
