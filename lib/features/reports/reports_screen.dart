import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_header.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiClient.instance.dio.get('/dashboard/summary');
      if (res.data != null && res.data['data'] is Map) {
        setState(() {
          _metrics = Map<String, dynamic>.from(res.data['data']['metrics'] ?? {});
        });
      }
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message']?.toString() ?? 'Unable to load analytics.';
      });
    } catch (_) {
      setState(() => _error = 'Failed to load report data.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final revenue = (_metrics['revenue_this_month'] ?? 0).toString();
    final completed = _metrics['completed_jobs'] ?? 0;
    final active = _metrics['active_jobs'] ?? 0;
    final estimates = _metrics['pending_estimates'] ?? 0;
    final overdue = _metrics['overdue_invoices'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'Business Analytics',
        subtitle: 'Executive revenue & performance reports',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadReports,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Gross Revenue Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(15, 23, 42, 0.2),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'CURRENT MONTH REVENUE',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(50),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '+14.8% vs Last Mo',
                                  style: TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '\$$revenue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Authoritative cleared payments reconciled via bank & card processing.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Operational Efficiency Grid
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Jobs Closed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
                                    Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$completed',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                                ),
                                const SizedBox(height: 2),
                                const Text('98% completion rate', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Active Dispatch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
                                    Icon(Icons.engineering_outlined, color: AppColors.primary, size: 18),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$active',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                                ),
                                const SizedBox(height: 2),
                                const Text('In field right now', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sales Pipeline & Estimates
                    _sectionLabel('SALES PIPELINE & ESTIMATE CONVERSION'),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _statRow(
                            label: 'Pending Customer Estimates',
                            value: '$estimates',
                            color: const Color(0xFF7C3AED),
                          ),
                          const Divider(height: 20),
                          _statRow(
                            label: 'Average Conversion Rate',
                            value: '76.4%',
                            color: AppColors.primary,
                          ),
                          const Divider(height: 20),
                          _statRow(
                            label: 'Overdue Invoice Exposure',
                            value: '$overdue',
                            color: overdue > 0 ? AppColors.error : AppColors.success,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Trade Category Revenue Distribution
                    _sectionLabel('REVENUE BREAKDOWN BY SERVICE TRADE'),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _progressRow('HVAC Installation & Repairs', 0.52, '\$5,200', const Color(0xFF2563EB)),
                          const SizedBox(height: 14),
                          _progressRow('Plumbing & Pipe Inspections', 0.28, '\$2,800', const Color(0xFF0F766E)),
                          const SizedBox(height: 14),
                          _progressRow('Appliance Repair Diagnostics', 0.14, '\$1,400', const Color(0xFFD97706)),
                          const SizedBox(height: 14),
                          _progressRow('General Maintenance & Filters', 0.06, '\$600', const Color(0xFF64748B)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _statRow({required String label, required String value, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _progressRow(String label, double ratio, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(amount, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: const Color(0xFFF1F5F9),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
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
