import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_empty_state.dart';

class AutomationsScreen extends StatelessWidget {
  const AutomationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Business Automations',
        subtitle: 'Auto-invoice, auto-jobs & reminders',
        showBack: true,
      ),
      body: Center(
        child: AppEmptyState(
          icon: Icons.auto_mode_rounded,
          title: 'Automated Operations',
          message: 'Configure triggers for automatic work order creation, job invoicing, and overdue reminders.',
          actionLabel: 'Configure Rules',
          onAction: () {},
        ),
      ),
    );
  }
}
