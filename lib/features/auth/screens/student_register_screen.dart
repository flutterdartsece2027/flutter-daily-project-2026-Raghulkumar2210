import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common_widgets.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _department = 'Computer Science';

  static const List<String> _departments = [
    'Computer Science', 'Electronics', 'Mechanical', 'Civil', 'Electrical', 'IT'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _rollCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.studentRegister({
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'rollNumber': _rollCtrl.text.trim(),
      'department': _department,
      'password': _passCtrl.text,
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(auth.error ?? 'Registration failed'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Icon(Icons.person_add_rounded, size: 52, color: Colors.white),
                    const SizedBox(height: 10),
                    const Text('Create Account',
                        style: TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Register as a student',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          AppTextField(
                            label: 'Full Name',
                            controller: _nameCtrl,
                            prefixIcon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'Enter name' : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Email',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (v) => v!.isEmpty ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Phone',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: (v) => v!.isEmpty ? 'Enter phone' : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Roll Number',
                            controller: _rollCtrl,
                            prefixIcon: Icons.badge_outlined,
                            validator: (v) => v!.isEmpty ? 'Enter roll number' : null,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _department,
                            decoration: const InputDecoration(
                              labelText: 'Department',
                              prefixIcon: Icon(Icons.account_balance_outlined,
                                  color: AppTheme.primary),
                            ),
                            items: _departments
                                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                .toList(),
                            onChanged: (v) => setState(() => _department = v!),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Password',
                            controller: _passCtrl,
                            isPassword: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            text: 'Register',
                            loading: auth.loading,
                            onTap: _register,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? '),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text('Login',
                                    style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

