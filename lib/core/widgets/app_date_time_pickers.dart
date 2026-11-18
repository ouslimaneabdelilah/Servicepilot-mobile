import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Form picker for standard US formatted Dates.
class AppDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;

  const AppDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365)),
      lastDate: lastDate ?? now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? formatted;
    if (selectedDate != null) {
      formatted = '${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.year}';
    }

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: 'MM/DD/YYYY',
          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded, size: 24),
        ),
        child: Text(
          formatted ?? 'MM/DD/YYYY',
          style: formatted != null
              ? AppTypography.input
              : AppTypography.caption.copyWith(color: AppColors.textMutedLight, fontSize: 14),
        ),
      ),
    );
  }
}

/// Form picker for standard 12-hour Time.
class AppTimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool isRequired;

  const AppTimePickerField({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
    this.isRequired = false,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? formatted;
    if (selectedTime != null) {
      final hour = selectedTime!.hourOfPeriod == 0 ? 12 : selectedTime!.hourOfPeriod;
      final minute = selectedTime!.minute.toString().padLeft(2, '0');
      final period = selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
      formatted = '$hour:$minute $period';
    }

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: 'hh:mm AM/PM',
          prefixIcon: const Icon(Icons.access_time_rounded, size: 20),
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded, size: 24),
        ),
        child: Text(
          formatted ?? 'hh:mm AM/PM',
          style: formatted != null
              ? AppTypography.input
              : AppTypography.caption.copyWith(color: AppColors.textMutedLight, fontSize: 14),
        ),
      ),
    );
  }
}
