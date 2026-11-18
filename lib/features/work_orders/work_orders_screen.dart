import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_header.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  List<dynamic> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await ApiClient.instance.dio.get('/work-orders', queryParameters: {'per_page': 30});
      setState(() {
        items = res.data['data'] ?? [];
      });
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Unable to load work orders.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return const Color(0xFF2563EB);
      case 'in_progress':
        return const Color(0xFFD97706);
      case 'completed':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: 'Work Orders & Jobs',
        subtitle: 'Field operations & technician progress',
        showCompanySwitcher: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: load),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : items.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.construction_outlined,
                      title: 'No Work Orders',
                      message: 'Work orders are created when estimates are approved or when service requests are dispatched.',
                    )
                  : RefreshIndicator(
                      onRefresh: load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final wo = items[index];
                          final req = wo['service_request'] ?? {};
                          final customer = req['customer'] ?? {};
                          final status = (wo['status'] ?? 'assigned').toString();
                          final tech = wo['technician'];

                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              final updated = await context.push<bool>('/work-orders/${wo['id']}');
                              if (updated == true) load();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "WO #${wo['id']}",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _statusColor(status).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _statusColor(status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    req['title'] ?? 'Job in progress',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Customer: ${customer['name'] ?? 'Unknown'}",
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                  ),
                                  if (tech != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.engineering_outlined, size: 14, color: Color(0xFF2457D6)),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Assigned: ${tech['name']}",
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2457D6)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

