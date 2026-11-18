import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_empty_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Business Reports',
        subtitle: 'Revenue, performance & job analytics',
        showBack: true,
      ),
      body: Center(
        child: AppEmptyState(
          icon: Icons.analytics_rounded,
          title: 'Reports & Analytics',
          message: 'Analyze monthly sales revenue, technician job completion times, and conversion rates.',
          actionLabel: 'Export Report',
          onAction: () {},
        ),
      ),
    );
  }
}
