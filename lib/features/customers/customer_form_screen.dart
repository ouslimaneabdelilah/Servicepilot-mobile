import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_loading_button.dart';
import '../../core/widgets/app_text_field.dart';

class CustomerFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialCustomer;

  const CustomerFormScreen({super.key, this.initialCustomer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final companyName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final street = TextEditingController();
  final apt = TextEditingController();
  final city = TextEditingController();
  final zip = TextEditingController();
  final notes = TextEditingController();

  String customerType = 'residential';
  String stateCode = 'NY';
  bool saving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomer != null) {
      final c = widget.initialCustomer!;
      firstName.text = c['first_name'] ?? '';
      lastName.text = c['last_name'] ?? '';
      companyName.text = c['company_name'] ?? '';
      email.text = c['email'] ?? '';
      phone.text = c['phone'] ?? '';
      customerType = c['customer_type'] ?? 'residential';
      notes.text = c['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    companyName.dispose();
    email.dispose();
    phone.dispose();
    street.dispose();
    apt.dispose();
    city.dispose();
    zip.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() {
      saving = true;
      errorMessage = null;
    });

    try {
      final payload = {
        'first_name': firstName.text.trim(),
        'last_name': lastName.text.trim(),
        'company_name': companyName.text.trim().isNotEmpty ? companyName.text.trim() : null,
        'email': email.text.trim().isNotEmpty ? email.text.trim() : null,
        'phone': phone.text.trim().isNotEmpty ? phone.text.trim() : null,
        'customer_type': customerType,
        'street_address': street.text.trim().isNotEmpty ? street.text.trim() : null,
        'apartment': apt.text.trim().isNotEmpty ? apt.text.trim() : null,
        'city': city.text.trim().isNotEmpty ? city.text.trim() : null,
        'state': stateCode,
        'postal_code': zip.text.trim().isNotEmpty ? zip.text.trim() : null,
        'notes': notes.text.trim().isNotEmpty ? notes.text.trim() : null,
      };

      if (widget.initialCustomer == null) {
        await ApiClient.instance.dio.post('/customers', data: payload);
      } else {
        await ApiClient.instance.dio.put('/customers/${widget.initialCustomer!['id']}', data: payload);
      }

      if (mounted) {
        context.pop(true);
      }
    } on DioException catch (e) {
      setState(() {
        errorMessage = e.response?.data?['message']?.toString() ?? 'Failed to save customer.';
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
        title: Text(widget.initialCustomer == null ? 'New Customer' : 'Edit Customer',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: AppLoadingButton(
          onPressed: save,
          loading: saving,
          label: widget.initialCustomer == null ? 'Create Customer' : 'Save Changes',
          icon: Icons.check,
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Text(errorMessage!, style: const TextStyle(color: Color(0xFF991B1B))),
              ),

            // Section 1: Customer Info
            const Text('PRIMARY CONTACT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: firstName,
                    label: 'First Name',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: lastName,
                    label: 'Last Name',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            AppTextField(
              controller: companyName,
              label: 'Company Name (Optional)',
              prefixIcon: Icons.business_outlined,
            ),
            AppDropdown<String>(
              label: 'Customer Type',
              value: customerType,
              items: const [
                DropdownMenuItem(value: 'residential', child: Text('Residential')),
                DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
              ],
              onChanged: (v) => setState(() => customerType = v ?? 'residential'),
            ),
            AppTextField(
              controller: email,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            AppTextField(
              controller: phone,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),

            const SizedBox(height: 14),
            // Section 2: Address
            const Text('SERVICE LOCATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            AppTextField(
              controller: street,
              label: 'Street Address',
              prefixIcon: Icons.location_on_outlined,
            ),
            AppTextField(
              controller: apt,
              label: 'Suite / Apt / Unit',
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    controller: city,
                    label: 'City',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: AppDropdown<String>(
                    label: 'State',
                    value: stateCode,
                    items: const [
                      DropdownMenuItem(value: 'NY', child: Text('NY')),
                      DropdownMenuItem(value: 'TX', child: Text('TX')),
                      DropdownMenuItem(value: 'CA', child: Text('CA')),
                      DropdownMenuItem(value: 'FL', child: Text('FL')),
                      DropdownMenuItem(value: 'IL', child: Text('IL')),
                      DropdownMenuItem(value: 'PA', child: Text('PA')),
                      DropdownMenuItem(value: 'OH', child: Text('OH')),
                      DropdownMenuItem(value: 'GA', child: Text('GA')),
                      DropdownMenuItem(value: 'NC', child: Text('NC')),
                      DropdownMenuItem(value: 'MI', child: Text('MI')),
                      DropdownMenuItem(value: 'NJ', child: Text('NJ')),
                    ],
                    onChanged: (v) => setState(() => stateCode = v ?? 'NY'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    controller: zip,
                    label: 'ZIP',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            // Section 3: Notes
            const Text('INTERNAL NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            AppTextField(
              controller: notes,
              label: 'Access codes, gate notes, equipment notes...',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

