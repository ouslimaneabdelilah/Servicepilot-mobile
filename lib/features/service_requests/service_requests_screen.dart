import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_empty_state.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> {
  List<dynamic> items = [];
  bool loading = true;
  String? error;
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({String? status}) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await ApiClient.instance.dio.get(
        '/service-requests',
        queryParameters: {
          if (status != null && status != 'all') 'status': status,
          'per_page': 30,
        },
      );
      setState(() {
        items = res.data['data'] ?? [];
      });
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Unable to load service requests.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF2563EB);
      case 'scheduled':
        return const Color(0xFF7C3AED);
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
      appBar: AppBar(
        title: const Text('Service Requests', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => load(status: selectedStatus),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/service-requests/new');
          if (created == true) load(status: selectedStatus);
        },
        backgroundColor: const Color(0xFF2457D6),
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text('New Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All', 'all'),
                  _chip('New', 'new'),
                  _chip('Scheduled', 'scheduled'),
                  _chip('In Progress', 'in_progress'),
                  _chip('Completed', 'completed'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                    : items.isEmpty
                        ? AppEmptyState(
                            icon: Icons.assignment_outlined,
                            title: 'No Service Requests',
                            message: 'Create a new service request to track incoming customer calls and dispatch jobs.',
                            actionLabel: 'New Request',
                            onAction: () async {
                              final created = await context.push<bool>('/service-requests/new');
                              if (created == true) load();
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: () => load(status: selectedStatus),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final r = items[index];
                                final customer = r['customer'] ?? {};
                                final status = r['status'] ?? 'new';
                                final priority = r['priority'] ?? 'normal';
                                final isUrgent = priority == 'urgent' || priority == 'high';

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isUrgent ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
                                      width: isUrgent ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
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
                                          if (isUrgent)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEE2E2),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                priority.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFDC2626),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        r['title'] ?? 'Untitled Request',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 15, color: Color(0xFF64748B)),
                                          const SizedBox(width: 4),
                                          Text(
                                            customer['name'] ?? 'Unknown Customer',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                          ),
                                          if (customer['phone'] != null) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              "•  ${customer['phone']}",
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (r['service_address'] != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                r['service_address'],
                                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(label),
        selectedColor: const Color(0xFF2457D6).withOpacity(0.15),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF2457D6) : const Color(0xFF475569),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
        checkmarkColor: const Color(0xFF2457D6),
        onSelected: (_) {
          setState(() => selectedStatus = value);
          load(status: value);
        },
      ),
    );
  }
}

