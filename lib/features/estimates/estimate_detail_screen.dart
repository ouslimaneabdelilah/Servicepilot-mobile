import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_loading_button.dart';

class EstimateDetailScreen extends StatefulWidget {
  final int estimateId;

  const EstimateDetailScreen({super.key, required this.estimateId});

  @override
  State<EstimateDetailScreen> createState() => _EstimateDetailScreenState();
}

class _EstimateDetailScreenState extends State<EstimateDetailScreen> {
  Map<String, dynamic>? estimate;
  bool loading = true;
  String? error;
  bool actionLoading = false;

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
      final res = await ApiClient.instance.dio.get('/estimates/${widget.estimateId}');
      setState(() {
        estimate = res.data['data'];
      });
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Failed to load estimate.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> sendEstimate() async {
    setState(() => actionLoading = true);
    try {
      await ApiClient.instance.dio.post('/estimates/${widget.estimateId}/send');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estimate marked as sent!')));
        load();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not mark estimate as sent.')));
      }
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> approveEstimate() async {
    final nameController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Approve Estimate'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter the customer name who approved this estimate. A work order will be automatically initialized.'),
              const SizedBox(height: 14),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Signer Name', hintText: 'e.g. John Doe'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Confirm Approval'),
          ),
        ],
      ),
    );

    if (ok == true && nameController.text.trim().isNotEmpty) {
      setState(() => actionLoading = true);
      try {
        await ApiClient.instance.dio.post('/estimates/${widget.estimateId}/approve', data: {
          'approved_by_name': nameController.text.trim(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Estimate approved! Work Order created.')),
          );
          load();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to approve estimate.')));
        }
      } finally {
        if (mounted) setState(() => actionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estimate Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || estimate == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estimate Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error ?? 'Estimate not found', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final estNum = estimate!['estimate_number'] ?? 'EST';
    final customer = estimate!['customer'] ?? {};
    final status = (estimate!['status'] ?? 'draft').toString().toLowerCase();
    final items = estimate!['items'] as List<dynamic>? ?? [];
    final subtotal = estimate!['subtotal'] ?? '0.00';
    final discount = estimate!['discount_amount'] ?? '0.00';
    final tax = estimate!['tax_amount'] ?? '0.00';
    final total = estimate!['total'] ?? '0.00';
    final workOrder = estimate!['work_order'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(estNum, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: status != 'approved'
              ? Row(
                  children: [
                    if (status == 'draft')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: actionLoading ? null : sendEstimate,
                          icon: const Icon(Icons.send_outlined, size: 16),
                          label: const Text('Mark Sent'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    if (status == 'draft') const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: AppLoadingButton(
                        onPressed: approveEstimate,
                        loading: actionLoading,
                        label: 'Approve & Create Job',
                        icon: Icons.check_circle_outline,
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                )
              : workOrder != null
                  ? AppLoadingButton(
                      onPressed: () => context.push('/work-orders/${workOrder['id']}'),
                      label: 'Open Linked Work Order',
                      icon: Icons.construction_outlined,
                    )
                  : const SizedBox.shrink(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      estNum,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'approved' ? const Color(0xFFDEF7EC) : const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: status == 'approved' ? const Color(0xFF03543F) : const Color(0xFF2457D6),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Customer: ${customer['name'] ?? 'Unknown'}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                if (customer['phone'] != null)
                  Text(
                    customer['phone'],
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items Table
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ITEMIZED QUOTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                ...items.map((it) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it['description'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(
                                "${it['quantity']} × \$${it['unit_price']}",
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "\$${it['line_total'] ?? '0.00'}",
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _summaryRow('Subtotal', "\$$subtotal"),
                if (double.tryParse(discount.toString()) != 0.0) _summaryRow('Discount', "-\$$discount"),
                _summaryRow('Tax', "\$$tax"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text(
                      "\$$total",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2457D6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

