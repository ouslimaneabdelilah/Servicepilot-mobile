import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/constants/us_states.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_form_section.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_loading_button.dart';

class CustomerFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialCustomer;

  const CustomerFormScreen({super.key, this.initialCustomer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _aptCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _customerType = 'residential';
  String _stateCode = 'FL';
  String _preferredContact = 'phone';
  bool _saving = false;
  String? _errorMessage;

  bool get isEdit => widget.initialCustomer != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomer != null) {
      final c = widget.initialCustomer!;
      _firstNameCtrl.text = c['first_name']?.toString() ?? '';
      _lastNameCtrl.text = c['last_name']?.toString() ?? '';
      _companyNameCtrl.text = c['company_name']?.toString() ?? '';
      _emailCtrl.text = c['email']?.toString() ?? '';
      _phoneCtrl.text = c['phone']?.toString() ?? '';
      _customerType = c['customer_type']?.toString() ?? 'residential';
      _notesCtrl.text = c['notes']?.toString() ?? '';
      _preferredContact = c['preferred_contact_method']?.toString() ?? 'phone';

      if (c['billing_address'] != null) {
        _streetCtrl.text = c['billing_address'].toString();
      }
      if (c['city'] != null) _cityCtrl.text = c['city'].toString();
      if (c['state'] != null) _stateCode = c['state'].toString();
      if (c['postal_code'] != null) _zipCtrl.text = c['postal_code'].toString();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _companyNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _aptCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final payload = {
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'name': '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim(),
      'company_name': _companyNameCtrl.text.trim().isNotEmpty ? _companyNameCtrl.text.trim() : null,
      'email': _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim().toLowerCase() : null,
      'phone': _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      'customer_type': _customerType,
      'preferred_contact_method': _preferredContact,
      'billing_address': _streetCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCode,
      'postal_code': _zipCtrl.text.trim(),
      'notes': _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    };

    try {
      if (isEdit) {
        final id = widget.initialCustomer!['id'];
        await ApiClient.instance.dio.put('/customers/$id', data: payload);
      } else {
        await ApiClient.instance.dio.post('/customers', data: payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Customer updated successfully.' : 'Customer created successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(true);
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['message']?.toString() ?? 'Failed to save customer.';
      });
    } catch (_) {
      setState(() => _errorMessage = 'Unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppHeader(
        title: isEdit ? 'Edit Customer' : 'Add New Customer',
        subtitle: isEdit ? 'Update account details' : 'Commercial & Residential',
        showBack: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.errorBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.errorText, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Contact Information
              AppFormSection(
                title: 'Contact Information',
                icon: Icons.person_outline_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameCtrl,
                          decoration: const InputDecoration(labelText: 'First Name *', hintText: 'John'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameCtrl,
                          decoration: const InputDecoration(labelText: 'Last Name *', hintText: 'Doe'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _companyNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Business / Organization (Optional)',
                      hintText: 'e.g. Sunny Day Cafe',
                      prefixIcon: Icon(Icons.business_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'customer@domain.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      hintText: '+1 (555) 000-0000',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Phone is required for dispatch' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Account Preferences
              AppFormSection(
                title: 'Account Settings',
                icon: Icons.tune_rounded,
                children: [
                  DropdownButtonFormField<String>(
                    value: _customerType,
                    decoration: const InputDecoration(labelText: 'Customer Type'),
                    items: const [
                      DropdownMenuItem(value: 'residential', child: Text('Residential Homeowner')),
                      DropdownMenuItem(value: 'commercial', child: Text('Commercial Facility')),
                    ],
                    onChanged: (v) => setState(() => _customerType = v ?? 'residential'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _preferredContact,
                    decoration: const InputDecoration(labelText: 'Preferred Contact Method'),
                    items: const [
                      DropdownMenuItem(value: 'phone', child: Text('Phone Call')),
                      DropdownMenuItem(value: 'sms', child: Text('Text Message (SMS)')),
                      DropdownMenuItem(value: 'email', child: Text('Email')),
                    ],
                    onChanged: (v) => setState(() => _preferredContact = v ?? 'phone'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Service Location / Address
              AppFormSection(
                title: 'Service & Billing Address',
                icon: Icons.location_on_outlined,
                children: [
                  TextFormField(
                    controller: _streetCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Street Address *',
                      hintText: '123 Main Street',
                      prefixIcon: Icon(Icons.home_outlined, size: 20),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Address is required for jobs' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _aptCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Apt / Suite / Unit (Optional)',
                      hintText: 'Suite 4B',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _cityCtrl,
                          decoration: const InputDecoration(labelText: 'City *', hintText: 'Miami'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _stateCode,
                          decoration: const InputDecoration(labelText: 'State *'),
                          items: UsState.all.map((s) {
                            return DropdownMenuItem(value: s.code, child: Text(s.code));
                          }).toList(),
                          onChanged: (v) => setState(() => _stateCode = v ?? 'FL'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _zipCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'ZIP *', hintText: '33101'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (v.trim().length < 5) return '5 Digits';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Notes
              AppFormSection(
                title: 'Internal Notes',
                icon: Icons.notes_rounded,
                children: [
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Gate codes, pet warnings, preferred technicians, HVAC unit details...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              AppLoadingButton(
                onPressed: _save,
                loading: _saving,
                label: isEdit ? 'Save Changes' : 'Create Customer Record',
                icon: Icons.check_circle_outline_rounded,
                backgroundColor: AppColors.primary,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
