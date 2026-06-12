import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common_widgets.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok =
        await auth.adminLogin(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Invalid credentials'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  decoration: const BoxDecoration(gradient: AppTheme.adminGradient),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2)),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ),
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: const Icon(
                                    Icons.admin_panel_settings_rounded,
                                    color: Colors.white,
                                    size: 32),
                              ),
                              const SizedBox(height: 16),
                              const Text('Admin Portal',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text('Restricted access — authorized only',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Form card
                        Expanded(
                          child: SlideTransition(
                            position: _slide,
                            child: FadeTransition(
                              opacity: _fade,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius:
                                      BorderRadius.vertical(top: Radius.circular(36)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Info banner
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color:
                                                AppTheme.primary.withOpacity(0.07),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                                color: AppTheme.primary
                                                    .withOpacity(0.2)),
                                          ),
                                          child: Row(children: [
                                            const Icon(Icons.shield_outlined,
                                                color: AppTheme.primary, size: 20),
                                            const SizedBox(width: 10),
                                            const Expanded(
                                              child: Text(
                                                'Use the credentials provided by your institution.',
                                                style: TextStyle(
                                                    color: AppTheme.primary,
                                                    fontSize: 12,
                                                    height: 1.4),
                                              ),
                                            ),
                                          ]),
                                        ),
                                        const SizedBox(height: 20),
                                        AppTextField(
                                          label: 'Admin Email',
                                          controller: _emailCtrl,
                                          keyboardType: TextInputType.emailAddress,
                                          prefixIcon: Icons.email_outlined,
                                          validator: (v) =>
                                              v!.isEmpty ? 'Enter admin email' : null,
                                        ),
                                        const SizedBox(height: 16),
                                        AppTextField(
                                          label: 'Password',
                                          controller: _passCtrl,
                                          isPassword: true,
                                          prefixIcon: Icons.lock_outline_rounded,
                                          validator: (v) =>
                                              v!.isEmpty ? 'Enter password' : null,
                                        ),
                                        const SizedBox(height: 28),
                                        GradientButton(
                                          text: 'Login as Admin',
                                          loading: auth.loading,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6C3CE1),
                                              Color(0xFF3A7EFF),
                                            ],
                                          ),
                                          onTap: _login,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

