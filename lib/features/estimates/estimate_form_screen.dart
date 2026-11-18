import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_loading_button.dart';
import '../../core/widgets/app_text_field.dart';

class EstimateFormScreen extends StatefulWidget {
  const EstimateFormScreen({super.key});

  @override
  State<EstimateFormScreen> createState() => _EstimateFormScreenState();
}

class _LineItemInput {
  final description = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final unitPrice = TextEditingController(text: '0.00');

  void dispose() {
    description.dispose();
    quantity.dispose();
    unitPrice.dispose();
  }
}

class _EstimateFormScreenState extends State<EstimateFormScreen> {
  final formKey = GlobalKey<FormState>();

  List<dynamic> customers = [];
  int? selectedCustomerId;
  final discountController = TextEditingController(text: '0.00');
  final messageController = TextEditingController();

  final List<_LineItemInput> items = [];
  bool loadingCustomers = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    items.add(_LineItemInput()); // Start with one item
    loadCustomers();
  }

  @override
  void dispose() {
    for (final it in items) {
      it.dispose();
    }
    discountController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> loadCustomers() async {
    try {
      final res = await ApiClient.instance.dio.get('/customers', queryParameters: {'per_page': 50});
      setState(() {
        customers = res.data['data'] ?? [];
        if (customers.isNotEmpty) {
          selectedCustomerId = customers[0]['id'];
        }
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => loadingCustomers = false);
    }
  }

  double get subtotal {
    double sum = 0.0;
    for (final it in items) {
      final q = double.tryParse(it.quantity.text) ?? 0.0;
      final p = double.tryParse(it.unitPrice.text) ?? 0.0;
      sum += q * p;
    }
    return sum;
  }

  double get estimatedTotal {
    final disc = double.tryParse(discountController.text) ?? 0.0;
    final taxable = (subtotal - disc).clamp(0.0, double.infinity);
    final tax = taxable * 0.08875; // Preview NY sales tax
    return taxable + tax;
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
      final itemsPayload = items.map((it) {
        return {
          'description': it.description.text.trim(),
          'quantity': double.tryParse(it.quantity.text) ?? 1.0,
          'unit_price': double.tryParse(it.unitPrice.text) ?? 0.0,
        };
      }).toList();

      await ApiClient.instance.dio.post('/estimates', data: {
        'customer_id': selectedCustomerId,
        'discount_amount': double.tryParse(discountController.text) ?? 0.0,
        'tax_rate': 0.08875,
        'customer_message': messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
        'items': itemsPayload,
      });

      if (mounted) context.pop(true);
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Failed to create estimate.';
      });
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Create Estimate', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Est. Total (Preview):', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  Text(
                    "\$${estimatedTotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2457D6)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppLoadingButton(
                onPressed: save,
                loading: saving,
                label: 'Save & Generate Quote',
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
      body: loadingCustomers
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
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

                  const Text('CLIENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  if (customers.isNotEmpty)
                    AppDropdown<int>(
                      label: 'Customer',
                      value: selectedCustomerId ?? customers[0]['id'],
                      prefixIcon: Icons.person_outline,
                      items: customers.map<DropdownMenuItem<int>>((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'],
                          child: Text("${c['name']} (${c['customer_number'] ?? ''})"),
                        );
                      }).toList(),
                      onChanged: (id) => setState(() => selectedCustomerId = id),
                    ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('LINE ITEMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                      TextButton.icon(
                        onPressed: () {
                          setState(() => items.add(_LineItemInput()));
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final it = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text("#${index + 1}", style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: it.description,
                                  decoration: const InputDecoration(
                                    hintText: 'Item / Service description',
                                    border: InputBorder.none,
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              if (items.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      items.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: it.quantity,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                                  validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: it.unitPrice,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(labelText: 'Unit Price (\$)', border: OutlineInputBorder()),
                                  validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid' : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  const Text('DISCOUNT & NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: discountController,
                    label: 'Discount (\$)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onTap: () => setState(() {}),
                  ),
                  AppTextField(
                    controller: messageController,
                    label: 'Customer Message (Terms, validity, thank you note)',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

