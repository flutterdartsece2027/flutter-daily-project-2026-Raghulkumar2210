import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common_widgets.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});
  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen>
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
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
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
        await auth.studentLogin(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Login failed'),
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
                  decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
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
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ),
                        // Top header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.waving_hand_rounded,
                                  color: Colors.amber, size: 32),
                              const SizedBox(height: 8),
                              const Text('Welcome Back!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text('Sign in to your student account',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 14)),
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
                                        AppTextField(
                                          label: 'Email Address',
                                          controller: _emailCtrl,
                                          keyboardType: TextInputType.emailAddress,
                                          prefixIcon: Icons.email_outlined,
                                          validator: (v) =>
                                              v!.isEmpty ? 'Enter your email' : null,
                                        ),
                                        const SizedBox(height: 16),
                                        AppTextField(
                                          label: 'Password',
                                          controller: _passCtrl,
                                          isPassword: true,
                                          prefixIcon: Icons.lock_outline_rounded,
                                          validator: (v) =>
                                              v!.isEmpty ? 'Enter your password' : null,
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () => Navigator.pushNamed(
                                                context, AppRoutes.forgotPassword),
                                            child: const Text('Forgot Password?',
                                                style: TextStyle(
                                                    color: AppTheme.primary,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GradientButton(
                                          text: 'Sign In',
                                          loading: auth.loading,
                                          onTap: _login,
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Divider(color: Colors.grey[300])),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: Text('or',
                                                  style:
                                                      TextStyle(color: Colors.grey[400])),
                                            ),
                                            Expanded(
                                                child: Divider(color: Colors.grey[300])),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Don't have an account? ",
                                                style:
                                                    TextStyle(color: Colors.grey[600])),
                                            GestureDetector(
                                              onTap: () => Navigator.pushNamed(
                                                  context, AppRoutes.studentRegister),
                                              child: const Text('Register Now',
                                                  style: TextStyle(
                                                      color: AppTheme.primary,
                                                      fontWeight: FontWeight.w700)),
                                            ),
                                          ],
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

