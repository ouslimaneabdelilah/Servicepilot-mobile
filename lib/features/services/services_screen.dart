import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_empty_state.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Services & Pricing',
        subtitle: 'Trade categories and price books',
        showBack: true,
      ),
      body: Center(
        child: AppEmptyState(
          icon: Icons.category_rounded,
          title: 'Service Catalog',
          message: 'Configure your trade services, flat-rate pricing, and hourly labor rates.',
          actionLabel: 'Add Service',
          onAction: () {},
        ),
      ),
    );
  }
}
