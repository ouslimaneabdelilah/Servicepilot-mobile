import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_date_time_pickers.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_loading_button.dart';
import '../../core/widgets/app_searchable_dropdown.dart';
import '../../core/widgets/app_status_badge.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  String? _error;
  List<dynamic> _appointments = [];
  List<dynamic> _customers = [];

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resAppts = await ApiClient.instance.dio.get('/appointments');
      final resCust = await ApiClient.instance.dio.get('/customers');

      setState(() {
        _appointments = List.from(resAppts.data['data'] ?? []);
        _customers = List.from(resCust.data['data'] ?? []);
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message']?.toString() ?? 'Unable to load schedule.';
      });
    } catch (_) {
      setState(() => _error = 'Failed to load appointments.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> get _dayAppointments {
    return _appointments.where((a) {
      final start = a['start_time']?.toString();
      if (start == null) return false;
      try {
        final dt = DateTime.parse(start);
        return dt.year == _selectedDate.year &&
            dt.month == _selectedDate.month &&
            dt.day == _selectedDate.day;
      } catch (_) {
        return true;
      }
    }).toList();
  }

  void _openBookAppointmentDialog() {
    Map<String, dynamic>? selectedCustomer = _customers.isNotEmpty ? _customers.first : null;
    DateTime apptDate = _selectedDate;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);
    final notesCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Book Field Appointment', style: AppTypography.cardTitle.copyWith(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Customer Selector
                  AppSearchableDropdown<Map<String, dynamic>>(
                    label: 'Customer',
                    hint: 'Select client...',
                    items: _customers.map((c) => Map<String, dynamic>.from(c)).toList(),
                    selectedItem: selectedCustomer,
                    itemLabel: (c) => '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}'.trim(),
                    itemSubtitle: (c) => (c['billing_address'] ?? c['phone'] ?? '').toString(),
                    onChanged: (c) => setModalState(() => selectedCustomer = c),
                  ),
                  const SizedBox(height: 12),

                  // Date Picker
                  AppDatePickerField(
                    label: 'Appointment Date',
                    selectedDate: apptDate,
                    onDateSelected: (d) => setModalState(() => apptDate = d),
                  ),
                  const SizedBox(height: 12),

                  // Times
                  Row(
                    children: [
                      Expanded(
                        child: AppTimePickerField(
                          label: 'Start Time',
                          selectedTime: startTime,
                          onTimeSelected: (t) => setModalState(() => startTime = t),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTimePickerField(
                          label: 'End Time',
                          selectedTime: endTime,
                          onTimeSelected: (t) => setModalState(() => endTime = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions / Notes',
                      hintText: 'Customer requested 30-min call ahead...',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  AppLoadingButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (selectedCustomer == null) return;
                            setModalState(() => isSaving = true);

                            final startDt = DateTime(
                              apptDate.year,
                              apptDate.month,
                              apptDate.day,
                              startTime.hour,
                              startTime.minute,
                            );

                            final endDt = DateTime(
                              apptDate.year,
                              apptDate.month,
                              apptDate.day,
                              endTime.hour,
                              endTime.minute,
                            );

                            try {
                              await ApiClient.instance.dio.post('/appointments', data: {
                                'customer_id': selectedCustomer!['id'],
                                'start_time': startDt.toIso8601String(),
                                'end_time': endDt.toIso8601String(),
                                'notes': notesCtrl.text.trim(),
                                'status': 'scheduled',
                              });

                              if (context.mounted) {
                                Navigator.of(context).pop();
                                loadSchedule();
                              }
                            } catch (_) {
                              setModalState(() => isSaving = false);
                            }
                          },
                    loading: isSaving,
                    label: 'Confirm Appointment',
                    icon: Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayAppts = _dayAppointments;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'Dispatch & Schedule',
        subtitle: '${dayAppts.length} appointments for ${DateTime.now().month}/${DateTime.now().day}',
        showCompanySwitcher: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadSchedule,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBookAppointmentDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    // Horizontal Date Selector (Week Strip)
                    _buildWeekDayStrip(),

                    // Appointments List
                    Expanded(
                      child: dayAppts.isEmpty
                          ? const AppEmptyState(
                              icon: Icons.event_available_rounded,
                              title: 'No Appointments Scheduled',
                              message: 'There are no service appointments booked for this day.',
                              actionLabel: 'Book Now',
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: dayAppts.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (ctx, idx) {
                                final a = dayAppts[idx];
                                final cust = a['customer'] ?? {};
                                final custName = '${cust['first_name'] ?? ''} ${cust['last_name'] ?? ''}'.trim();
                                final address = cust['billing_address']?.toString() ?? 'Service Address';
                                final status = a['status']?.toString() ?? 'scheduled';
                                final notes = a['notes']?.toString() ?? '';
                                final start = a['start_time']?.toString() ?? '';

                                return AppCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                              const SizedBox(width: 6),
                                              Text(
                                                start.length >= 16 ? start.substring(11, 16) : start,
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          AppStatusBadge.fromStatus(status),
                                        ],
                                      ),
                                      const Divider(height: 18),
                                      Text(
                                        custName.isNotEmpty ? custName : 'Customer',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMutedLight),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              address,
                                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (notes.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            notes,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildWeekDayStrip() {
    final now = DateTime.now();
    // 7 days around selected date
    final days = List.generate(7, (i) => now.add(Duration(days: i - 1)));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((d) {
          final isSelected = d.year == _selectedDate.year &&
              d.month == _selectedDate.month &&
              d.day == _selectedDate.day;

          final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final dayName = weekDays[d.weekday - 1];

          return InkWell(
            onTap: () => setState(() => _selectedDate = d),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white.withAlpha(200) : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
