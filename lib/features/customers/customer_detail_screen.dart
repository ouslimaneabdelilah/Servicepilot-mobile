import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Map<String, dynamic>? customer;
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
      final res = await ApiClient.instance.dio.get('/customers/${widget.customerId}');
      setState(() {
        customer = res.data['data'];
      });
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Failed to load customer details.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteCustomer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: const Text('Are you sure you want to delete this customer? This action will archive their record.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiClient.instance.dio.delete('/customers/${widget.customerId}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer deleted.')));
          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not delete customer.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error ?? 'Customer not found', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final name = customer!['name'] ?? 'Unnamed';
    final custNum = customer!['customer_number'] ?? '';
    final phone = customer!['phone'] ?? '';
    final email = customer!['email'] ?? '';
    final notes = customer!['notes'] ?? '';
    final addresses = customer!['addresses'] as List<dynamic>? ?? [];
    final requests = customer!['service_requests'] as List<dynamic>? ?? [];
    final invoices = customer!['invoices'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(custNum.isNotEmpty ? custNum : 'Customer'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await context.push<bool>('/customers/new', extra: customer);
              if (updated == true) load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: deleteCustomer,
          ),
        ],
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
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEF7EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (customer!['status'] ?? 'active').toString().toUpperCase(),
                        style: const TextStyle(color: Color(0xFF03543F), fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                if (customer!['company_name'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    customer!['company_name'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                  ),
                ],
                const SizedBox(height: 16),
                if (phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF2457D6)),
                        const SizedBox(width: 10),
                        Text(phone, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                if (email.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 18, color: Color(0xFF2457D6)),
                      const SizedBox(width: 10),
                      Text(email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Addresses
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
                const Text('SERVICE LOCATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                if (addresses.isEmpty)
                  const Text('No addresses registered.', style: TextStyle(color: Color(0xFF94A3B8)))
                else
                  ...addresses.map((a) {
                    final isDefault = a['is_default'] == true;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 20, color: isDefault ? const Color(0xFF2457D6) : const Color(0xFF94A3B8)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(a['label'] ?? 'Address', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    if (isDefault) ...[
                                      const SizedBox(width: 8),
                                      const Text('(Primary)', style: TextStyle(color: Color(0xFF2457D6), fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ],
                                ),
                                Text(
                                  "${a['street_address']}${a['apartment'] != null ? ' ${a['apartment']}' : ''}, ${a['city']}, ${a['state']} ${a['postal_code']}",
                                  style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          if (notes.isNotEmpty) ...[
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
                  const Text('INTERNAL NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Text(notes, style: const TextStyle(color: Color(0xFF334155), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // History Summary
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
                const Text('ACTIVITY SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statBox('Service Requests', requests.length.toString(), Icons.assignment_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statBox('Invoices', invoices.length.toString(), Icons.receipt_long_outlined),
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

  Widget _statBox(String label, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF2457D6)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

