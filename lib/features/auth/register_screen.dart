import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_loading_button.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final company = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  String type = 'hvac';

  @override
  void dispose() {
    for (final c in [name, email, company, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(authProvider);

    ref.listen(authProvider, (p, n) {
      if (n.loggedIn) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Form(
          key: form,
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'Create your workspace',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _input(name, 'Full name'),
              _input(company, 'Business name'),
              _input(email, 'Email'),
              AppDropdown<String>(
                label: 'Business Trade Type',
                value: type,
                prefixIcon: Icons.handyman_outlined,
                options: const [
                  AppDropdownOption(value: 'hvac', label: 'HVAC', subtitle: 'Heating, Ventilation & Air Conditioning'),
                  AppDropdownOption(value: 'plumbing', label: 'Plumbing', subtitle: 'Pipes, Drains & Water Systems'),
                  AppDropdownOption(value: 'appliance_repair', label: 'Appliance Repair', subtitle: 'Refrigerators, Washers & Dryers'),
                  AppDropdownOption(value: 'general', label: 'General Services', subtitle: 'Multi-trade Field Service'),
                ],
                onChanged: (v) => setState(() => type = v ?? 'hvac'),
              ),
              const SizedBox(height: 12),
              _input(password, 'Password (10+ characters)', secret: true),
              _input(confirm, 'Confirm password', secret: true),
              if (a.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    a.error!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(height: 18),
              AppLoadingButton(
                onPressed: () {
                  if (form.currentState?.validate() ?? false) {
                    ref.read(authProvider.notifier).register(
                          name: name.text,
                          email: email.text,
                          password: password.text,
                          confirmation: confirm.text,
                          company: company.text,
                          type: type,
                        );
                  }
                },
                loading: a.loading,
                label: 'Create Account',
                icon: Icons.arrow_forward_rounded,
                height: 44.0,
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Already have an account? Sign in'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    bool secret = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        obscureText: secret,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (c == email && !v.contains('@')) return 'Invalid email';
          if (c == password && v.length < 10) return 'Minimum 10 characters';
          if (c == confirm && v != password.text) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }
}
