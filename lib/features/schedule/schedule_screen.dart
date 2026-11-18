import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_empty_state.dart';

/// Schedule & Dispatch calendar screen.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Dispatch & Schedule',
        subtitle: 'Technician appointments & calendars',
      ),
      body: Center(
        child: AppEmptyState(
          icon: Icons.calendar_month_rounded,
          title: 'Schedule & Dispatch Calendar',
          message: 'View daily technician bookings, assign jobs, and detect scheduling conflicts.',
          actionLabel: 'Book Appointment',
          onAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appointment booking flow opens in Phase 8.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }
}
