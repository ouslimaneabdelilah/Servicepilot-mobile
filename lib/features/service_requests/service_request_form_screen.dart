import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_loading_button.dart';
import '../../core/widgets/app_text_field.dart';

class ServiceRequestFormScreen extends StatefulWidget {
  const ServiceRequestFormScreen({super.key});

  @override
  State<ServiceRequestFormScreen> createState() => _ServiceRequestFormScreenState();
}

class _ServiceRequestFormScreenState extends State<ServiceRequestFormScreen> {
  final formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final description = TextEditingController();
  final address = TextEditingController();

  List<dynamic> customers = [];
  int? selectedCustomerId;
  String priority = 'normal';
  bool loadingCustomers = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> loadCustomers() async {
    try {
      final res = await ApiClient.instance.dio.get('/customers', queryParameters: {'per_page': 50});
      setState(() {
        customers = res.data['data'] ?? [];
        if (customers.isNotEmpty) {
          _selectCustomer(customers[0]);
        }
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => loadingCustomers = false);
    }
  }

  void _selectCustomer(dynamic cust) {
    selectedCustomerId = cust['id'];
    final addresses = cust['addresses'] as List<dynamic>? ?? [];
    if (addresses.isNotEmpty) {
      final a = addresses[0];
      address.text = "${a['street_address']}, ${a['city']}, ${a['state']} ${a['postal_code']}";
    }
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedCustomerId == null) {
      setState(() => error = 'Please select a customer.');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      await ApiClient.instance.dio.post('/service-requests', data: {
        'customer_id': selectedCustomerId,
        'title': title.text.trim(),
        'description': description.text.trim().isNotEmpty ? description.text.trim() : null,
        'service_address': address.text.trim(),
        'priority': priority,
        'status': 'new',
      });

      if (mounted) context.pop(true);
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Failed to create service request.';
      });
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppHeader(
        title: 'New Service Request',
        subtitle: 'Log incoming repair call & dispatch',
        showBack: true,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: AppLoadingButton(
          onPressed: save,
          loading: saving,
          label: 'Create Request',
          icon: Icons.check,
        ),
      ),
      body: loadingCustomers
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  if (error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(error!, style: const TextStyle(color: Color(0xFF991B1B))),
                    ),

                  const Text('CUSTOMER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  if (customers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Text('No customers found. Create a customer first.'),
                    )
                  else
                    AppDropdown<int>(
                      label: 'Select Customer',
                      value: selectedCustomerId ?? customers[0]['id'],
                      prefixIcon: Icons.person_outline,
                      items: customers.map<DropdownMenuItem<int>>((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'],
                          child: Text("${c['name']} (${c['customer_number'] ?? ''})"),
                        );
                      }).toList(),
                      onChanged: (id) {
                        if (id != null) {
                          final cust = customers.firstWhere((element) => element['id'] == id);
                          setState(() => _selectCustomer(cust));
                        }
                      },
                    ),

                  const SizedBox(height: 14),
                  const Text('JOB DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: title,
                    label: 'Job Title / Issue Summary',
                    hint: 'e.g. AC leaking water on floor',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  AppTextField(
                    controller: address,
                    label: 'Service Address',
                    prefixIcon: Icons.location_on_outlined,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  AppDropdown<String>(
                    label: 'Priority',
                    value: priority,
                    prefixIcon: Icons.flag_outlined,
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                      DropdownMenuItem(value: 'normal', child: Text('Normal Priority')),
                      DropdownMenuItem(value: 'high', child: Text('High Priority')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent (Same Day)')),
                    ],
                    onChanged: (v) => setState(() => priority = v ?? 'normal'),
                  ),
                  AppTextField(
                    controller: description,
                    label: 'Detailed Description (Optional)',
                    hint: 'Equipment model, symptoms described by customer...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
    );
  }
}

