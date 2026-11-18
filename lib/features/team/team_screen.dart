import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_empty_state.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Team & Technicians',
        subtitle: 'Company staff, roles & skills',
        showBack: true,
      ),
      body: Center(
        child: AppEmptyState(
          icon: Icons.badge_rounded,
          title: 'Field Technicians & Staff',
          message: 'Manage employee accounts, dispatcher roles, and technician skill tags.',
          actionLabel: 'Invite Team Member',
          onAction: () {},
        ),
      ),
    );
  }
}
