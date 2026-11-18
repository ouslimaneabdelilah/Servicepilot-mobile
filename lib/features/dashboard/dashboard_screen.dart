import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_header.dart';
import '../auth/auth_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? company;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadContext();
  }

  Future<void> loadContext() async {
    try {
      final res = await ApiClient.instance.dio.get('/auth/me');
      final user = res.data['data']['user'];
      setState(() {
        company = user['current_company'];
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = company?['name'] ?? 'ServicePilot Workspace';
    final businessType = (company?['business_type'] ?? 'HVAC / Field Service').toString().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'Business Overview',
        subtitle: '$companyName • $businessType',
        showCompanySwitcher: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Company Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    businessType,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  companyName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'End-to-End Field Operations & Cashflow',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Action Bar
          Row(
            children: [
              Expanded(
                child: _quickAction(
                  context,
                  Icons.person_add_alt,
                  'Customer',
                  () => context.push('/customers/new'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickAction(
                  context,
                  Icons.add_task,
                  'Request',
                  () => context.push('/service-requests/new'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickAction(
                  context,
                  Icons.request_quote_outlined,
                  'Estimate',
                  () => context.push('/estimates/new'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'BUSINESS MODULES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),

          _tile(
            context,
            Icons.people_alt_outlined,
            'Customers Directory',
            'Accounts, locations, and service history',
            const Color(0xFF3B82F6),
            () => context.push('/customers'),
          ),
          _tile(
            context,
            Icons.assignment_outlined,
            'Service Requests',
            'Dispatch, job intake, priority triage',
            const Color(0xFF8B5CF6),
            () => context.push('/service-requests'),
          ),
          _tile(
            context,
            Icons.request_quote_outlined,
            'Estimates & Quotes',
            'Itemized quotes and digital customer approvals',
            const Color(0xFF10B981),
            () => context.push('/estimates'),
          ),
          _tile(
            context,
            Icons.construction_outlined,
            'Work Orders',
            'Field execution, checklists, and sign-offs',
            const Color(0xFFF59E0B),
            () => context.push('/work-orders'),
          ),
          _tile(
            context,
            Icons.receipt_long_outlined,
            'Invoices & Payments',
            'Billing, balance tracking, and card processing',
            const Color(0xFFEC4899),
            () => context.push('/invoices'),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF2457D6)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
