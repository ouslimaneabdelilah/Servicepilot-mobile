import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_loading_button.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Map<String, dynamic>? invoice;
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
      final res = await ApiClient.instance.dio.get('/invoices/${widget.invoiceId}');
      setState(() {
        invoice = res.data['data'];
      });
    } on DioException catch (e) {
      setState(() {
        error = e.response?.data?['message']?.toString() ?? 'Failed to load invoice.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> recordPayment() async {
    final balance = double.tryParse((invoice!['balance_due'] ?? '0.00').toString()) ?? 0.0;
    final amountController = TextEditingController(text: balance.toStringAsFixed(2));
    final refController = TextEditingController();
    String method = 'card';

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Payment Amount (\$)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: method,
                decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'card', child: Text('Credit / Debit Card')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'check', child: Text('Check')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer (ACH)')),
                ],
                onChanged: (v) => setDialogState(() => method = v ?? 'card'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refController,
                decoration: const InputDecoration(labelText: 'Reference / Check # (Optional)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
              child: const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      setState(() => actionLoading = true);
      try {
        await ApiClient.instance.dio.post('/payments', data: {
          'invoice_id': widget.invoiceId,
          'amount': double.tryParse(amountController.text.trim()) ?? 0.0,
          'method': method,
          'reference': refController.text.trim().isNotEmpty ? refController.text.trim() : null,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded successfully!')));
          load();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to record payment.')));
      } finally {
        if (mounted) setState(() => actionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error ?? 'Invoice not found', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final invNum = invoice!['invoice_number'] ?? 'INV';
    final customer = invoice!['customer'] ?? {};
    final status = (invoice!['status'] ?? 'draft').toString().toLowerCase();
    final items = invoice!['items'] as List<dynamic>? ?? [];
    final payments = invoice!['payments'] as List<dynamic>? ?? [];
    final subtotal = invoice!['subtotal'] ?? '0.00';
    final tax = invoice!['tax_amount'] ?? '0.00';
    final total = invoice!['total'] ?? '0.00';
    final amountPaid = invoice!['amount_paid'] ?? '0.00';
    final balanceDue = invoice!['balance_due'] ?? '0.00';
    final canPay = status != 'paid' && status != 'void' && (double.tryParse(balanceDue.toString()) ?? 0.0) > 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(invNum, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: canPay
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: AppLoadingButton(
                onPressed: recordPayment,
                loading: actionLoading,
                label: "Record Payment (\$${balanceDue.toString()})",
                icon: Icons.payments_outlined,
                backgroundColor: const Color(0xFF16A34A),
              ),
            )
          : null,
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
                      invNum,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'paid' ? const Color(0xFFDEF7EC) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: status == 'paid' ? const Color(0xFF03543F) : const Color(0xFFDC2626),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text("Billed to: ${customer['name'] ?? 'Unknown'}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 4),
                Text("Due date: ${invoice!['due_date'] ?? 'Upon Receipt'}", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
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
                const Text('INVOICE LINE ITEMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
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
                              Text("${it['quantity']} × \$${it['unit_price']}", style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                            ],
                          ),
                        ),
                        Text("\$${it['line_total'] ?? '0.00'}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _summaryRow('Subtotal', "\$$subtotal"),
                _summaryRow('Tax', "\$$tax"),
                _summaryRow('Invoice Total', "\$$total", isBold: true),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _summaryRow('Amount Paid', "-\$$amountPaid", color: const Color(0xFF16A34A)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Balance Due', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text(
                      "\$$balanceDue",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: (double.tryParse(balanceDue.toString()) ?? 0.0) > 0.0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment History
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
                const Text('PAYMENT RECORDS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                if (payments.isEmpty)
                  const Text('No payments recorded yet.', style: TextStyle(color: Color(0xFF94A3B8)))
                else
                  ...payments.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (p['method'] ?? 'Payment').toString().toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  if (p['reference'] != null)
                                    Text("Ref: ${p['reference']}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            "+\$${p['amount']}",
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: const Color(0xFF64748B), fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, fontSize: 14, color: color)),
        ],
      ),
    );
  }
}

