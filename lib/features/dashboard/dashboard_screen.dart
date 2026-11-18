import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_status_badge.dart';
import '../auth/auth_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic> _metrics = {};
  List<dynamic> _upcomingAppointments = [];
  List<dynamic> _urgentRequests = [];
  List<dynamic> _automationAlerts = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiClient.instance.dio.get('/dashboard/summary');
      if (res.data != null && res.data['data'] is Map) {
        final data = res.data['data'] as Map;
        setState(() {
          _metrics = Map<String, dynamic>.from(data['metrics'] ?? {});
          _upcomingAppointments = List.from(data['upcoming_appointments'] ?? []);
          _urgentRequests = List.from(data['urgent_requests'] ?? []);
          _automationAlerts = List.from(data['automation_alerts'] ?? []);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Unable to load real-time dashboard data.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companyName = auth.currentCompany?['name']?.toString() ?? 'ServicePilot';
    final role = auth.role.toLowerCase();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(
        title: 'Business Overview',
        subtitle: companyName,
        showCompanySwitcher: true,
        actions: [
          IconButton(
            tooltip: 'Refresh metrics',
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: loadDashboardData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadDashboardData,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
              onRefresh: loadDashboardData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Role Greeting Banner
                  _buildGreetingCard(auth),
                  const SizedBox(height: 16),

                  // Automation Alerts (if any)
                  if (_automationAlerts.isNotEmpty) ...[
                    _buildAutomationAlertsSection(),
                    const SizedBox(height: 16),
                  ],

                  // KPI Metrics Grid (Tailored by Role)
                  _buildKpiMetricsGrid(role),
                  const SizedBox(height: 20),

                  // Quick Action Shortcuts
                  _buildQuickActions(),
                  const SizedBox(height: 20),

                  // Today's Appointments & Schedule
                  _buildAppointmentsSection(),
                  const SizedBox(height: 20),

                  // Urgent Requests & Needs Dispatch
                  _buildUrgentRequestsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildGreetingCard(AuthState auth) {
    final userName = auth.user?['name']?.toString() ?? 'Contractor';
    final roleStr = auth.role.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(30, 58, 138, 0.25),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                      child: Text(
                        roleStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live Workspace',
                      style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hello, $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here is what is happening across your operations today.',
                  style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('ACTIONABLE AUTOMATION ALERTS'),
        const SizedBox(height: 8),
        ..._automationAlerts.map((alert) {
          final isError = alert['severity'] == 'error';
          final bgColor = isError ? AppColors.errorSurface : AppColors.warningSurface;
          final borderColor = isError ? AppColors.errorBorder : AppColors.warningBorder;
          final textColor = isError ? AppColors.errorText : AppColors.warningText;
          final icon = isError ? Icons.warning_rounded : Icons.notifications_active_rounded;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title']?.toString() ?? 'Alert',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert['message']?.toString() ?? '',
                        style: TextStyle(color: textColor.withAlpha(220), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    final route = alert['action_route']?.toString();
                    if (route != null) context.push(route);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: textColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      'View →',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildKpiMetricsGrid(String role) {
    final revenue = _metrics['revenue_this_month'] ?? 0;
    final todayAppts = _metrics['today_appointments'] ?? 0;
    final newRequests = _metrics['new_requests'] ?? 0;
    final activeJobs = _metrics['active_jobs'] ?? 0;
    final completedJobs = _metrics['completed_jobs'] ?? 0;
    final overdueInvoices = _metrics['overdue_invoices'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('OPERATIONAL KPI METRICS'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            // Revenue this month (For Owner/Admin)
            if (role != 'technician')
              _kpiCard(
                title: 'Revenue (Month)',
                value: '\$$revenue',
                icon: Icons.attach_money_rounded,
                iconColor: AppColors.success,
                onTap: () => context.push('/invoices'),
              ),

            // Today's Appointments
            _kpiCard(
              title: "Today's Schedule",
              value: '$todayAppts',
              subtitle: 'Appointments booked',
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.primary,
              onTap: () => context.go('/schedule'),
            ),

            // Active Field Jobs
            _kpiCard(
              title: 'Active Work Orders',
              value: '$activeJobs',
              subtitle: 'Jobs in progress',
              icon: Icons.construction_rounded,
              iconColor: const Color(0xFFD97706),
              onTap: () => context.go('/work-orders'),
            ),

            // Incoming Service Requests
            _kpiCard(
              title: 'New Requests',
              value: '$newRequests',
              subtitle: 'Needs dispatch',
              icon: Icons.assignment_late_outlined,
              iconColor: const Color(0xFFDC2626),
              onTap: () => context.push('/service-requests'),
            ),

            // Completed Jobs
            _kpiCard(
              title: 'Jobs Completed',
              value: '$completedJobs',
              subtitle: 'This cycle',
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.secondary,
              onTap: () => context.go('/work-orders'),
            ),

            // Overdue Invoices
            if (role != 'technician')
              _kpiCard(
                title: 'Overdue Invoices',
                value: '$overdueInvoices',
                subtitle: 'Requires follow-up',
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.error,
                onTap: () => context.push('/invoices'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMutedLight),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('QUICK ACTIONS'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _actionPill(
                label: 'Add Customer',
                icon: Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                onTap: () => context.push('/customers/new'),
              ),
              const SizedBox(width: 8),
              _actionPill(
                label: 'New Request',
                icon: Icons.add_call,
                color: const Color(0xFF0F766E),
                onTap: () => context.push('/service-requests/new'),
              ),
              const SizedBox(width: 8),
              _actionPill(
                label: 'Create Estimate',
                icon: Icons.note_add_outlined,
                color: const Color(0xFF7C3AED),
                onTap: () => context.push('/estimates/new'),
              ),
              const SizedBox(width: 8),
              _actionPill(
                label: 'Book Schedule',
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFFD97706),
                onTap: () => context.go('/schedule'),
              ),
              const SizedBox(width: 8),
              _actionPill(
                label: 'Record Payment',
                icon: Icons.payment_rounded,
                color: AppColors.success,
                onTap: () => context.push('/payments'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionPill({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel("UPCOMING APPOINTMENTS"),
            InkWell(
              onTap: () => context.go('/schedule'),
              child: const Text(
                'View Calendar →',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_upcomingAppointments.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.event_available_rounded, size: 36, color: AppColors.textMutedLight),
                  const SizedBox(height: 8),
                  const Text(
                    'No appointments currently booked',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap "Book Schedule" to schedule your first service call.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMutedLight),
                  ),
                ],
              ),
            ),
          )
        else
          ..._upcomingAppointments.map((appt) {
            final cust = appt['customer'] ?? {};
            final custName = '${cust['first_name'] ?? ''} ${cust['last_name'] ?? ''}'.trim();
            final startTime = appt['start_time']?.toString() ?? '';
            final status = appt['status']?.toString() ?? 'scheduled';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            custName.isNotEmpty ? custName : 'Customer Appointment',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            startTime.length >= 16 ? startTime.substring(0, 16) : startTime,
                            style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    AppStatusBadge.fromStatus(status),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildUrgentRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel("URGENT SERVICE CALLS"),
            InkWell(
              onTap: () => context.push('/service-requests'),
              child: const Text(
                'All Requests →',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_urgentRequests.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: Text(
                'No pending urgent repair requests.',
                style: TextStyle(color: AppColors.textMutedLight, fontSize: 13),
              ),
            ),
          )
        else
          ..._urgentRequests.map((req) {
            final cust = req['customer'] ?? {};
            final custName = '${cust['first_name'] ?? ''} ${cust['last_name'] ?? ''}'.trim();
            final title = req['title']?.toString() ?? 'Service Request';
            final priority = req['priority']?.toString() ?? 'urgent';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(Icons.flash_on_rounded, color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            custName.isNotEmpty ? 'Customer: $custName' : 'Awaiting dispatch',
                            style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    AppStatusBadge.fromStatus(priority),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.textMutedLight,
      ),
    );
  }
}
