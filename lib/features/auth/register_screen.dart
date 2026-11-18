import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_loading_button.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String _businessType = 'hvac';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    ref.read(authProvider.notifier).clearError();
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).register(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            company: _companyController.text,
            type: _businessType,
            password: _passwordController.text,
            confirmation: _confirmController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      if (next.loggedIn) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () {
            ref.read(authProvider.notifier).clearError();
            context.go('/login');
          },
        ),
        title: const Text(
          'Create Workspace',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Container(
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
                              color: const Color(0xFF2457D6).withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.business_center_rounded,
                              color: Color(0xFF2457D6),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Setup your service business',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Dispatch, track jobs, invoice and accept payments',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Alert Card
                    if (auth.error != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: const TextStyle(
                                  color: Color(0xFF991B1B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => ref.read(authProvider.notifier).clearError(),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Section: Owner Info
                    _sectionTitle('ACCOUNT DETAILS'),
                    const SizedBox(height: 10),

                    // Name
                    _inputField(
                      controller: _nameController,
                      label: 'Full name',
                      hint: 'e.g. John Doe',
                      icon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Full name is required.';
                        if (v.trim().length < 3) return 'Name must be at least 3 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Email
                    _inputField(
                      controller: _emailController,
                      label: 'Email address',
                      hint: 'name@company.com',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      serverError: auth.fieldErrors['email'],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email address is required.';
                        if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Phone (Optional)
                    _inputField(
                      controller: _phoneController,
                      label: 'Phone number (Optional)',
                      hint: '+1 (555) 000-0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 22),

                    // Section: Company Info
                    _sectionTitle('COMPANY PROFILE'),
                    const SizedBox(height: 10),

                    // Business Name
                    _inputField(
                      controller: _companyController,
                      label: 'Business / Company name',
                      hint: 'e.g. Apex Heating & Air LLC',
                      icon: Icons.business_outlined,
                      serverError: auth.fieldErrors['company_name'],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Company name is required.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Trade / Business Type Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: _businessType,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Trade & Industry',
                            labelStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            prefixIcon: Icon(Icons.category_outlined, size: 20, color: Color(0xFF2457D6)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'hvac', child: Text('HVAC & Air Conditioning')),
                            DropdownMenuItem(value: 'plumbing', child: Text('Plumbing Services')),
                            DropdownMenuItem(value: 'electrical', child: Text('Electrical & Power')),
                            DropdownMenuItem(value: 'appliance_repair', child: Text('Appliance Repair')),
                            DropdownMenuItem(value: 'general', child: Text('General Home Services')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _businessType = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Section: Security
                    _sectionTitle('SECURITY & PASSWORD'),
                    const SizedBox(height: 10),

                    // Password
                    _inputField(
                      controller: _passwordController,
                      label: 'Password (min. 10 characters)',
                      hint: '••••••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      serverError: auth.fieldErrors['password'],
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required.';
                        if (v.length < 10) return 'Password must be at least 10 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Confirm Password
                    _inputField(
                      controller: _confirmController,
                      label: 'Confirm password',
                      hint: '••••••••••••',
                      icon: Icons.lock_reset_rounded,
                      obscureText: _obscureConfirm,
                      serverError: auth.fieldErrors['password_confirmation'],
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please confirm your password.';
                        if (v != _passwordController.text) return 'Passwords do not match.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Submit Button with Wave Dots Loader
                    AppLoadingButton(
                      onPressed: _submit,
                      loading: auth.loading,
                      label: 'Create Company Workspace',
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: const Color(0xFF2457D6),
                    ),
                    const SizedBox(height: 20),

                    // Already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already registered? ',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref.read(authProvider.notifier).clearError();
                            context.go('/login');
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF2457D6),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF64748B),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? serverError,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        suffixIcon: suffixIcon,
        errorText: serverError,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2457D6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
      validator: validator,
    );
  }
}
