import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});
  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _card1Ctrl;
  late AnimationController _card2Ctrl;

  Timer? _card1Timer;
  Timer? _card2Timer;

  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;
  late Animation<Offset> _card1Slide;
  late Animation<double> _card1Fade;
  late Animation<Offset> _card2Slide;
  late Animation<double> _card2Fade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _card1Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _card2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(_headerCtrl);

    _card1Slide =
        Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: _card1Ctrl, curve: Curves.easeOutCubic));
    _card1Fade = Tween<double>(begin: 0, end: 1).animate(_card1Ctrl);

    _card2Slide =
        Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: _card2Ctrl, curve: Curves.easeOutCubic));
    _card2Fade = Tween<double>(begin: 0, end: 1).animate(_card2Ctrl);

    _headerCtrl.forward();
    _card1Timer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _card1Ctrl.forward();
    });
    _card2Timer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _card2Ctrl.forward();
    });
  }

  @override
  void dispose() {
    _card1Timer?.cancel();
    _card2Timer?.cancel();
    _headerCtrl.dispose();
    _card1Ctrl.dispose();
    _card2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // Header
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Column(children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Icon(Icons.school_rounded,
                              size: 44, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Student Complaint\nPortal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your role to get started',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 14,
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 56),
                // Student card
                SlideTransition(
                  position: _card1Slide,
                  child: FadeTransition(
                    opacity: _card1Fade,
                    child: _RoleCard(
                      gradient: AppTheme.studentCardGradient,
                      icon: Icons.person_rounded,
                      iconBg: Colors.white.withOpacity(0.2),
                      title: 'Student',
                      subtitle: 'Register & raise complaints',
                      tag: 'LOGIN / REGISTER',
                      tagColor: Colors.white.withOpacity(0.3),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.studentLogin),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Admin card
                SlideTransition(
                  position: _card2Slide,
                  child: FadeTransition(
                    opacity: _card2Fade,
                    child: _RoleCard(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D0D2B), Color(0xFF2E1065)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      icon: Icons.admin_panel_settings_rounded,
                      iconBg: AppTheme.primaryLight.withOpacity(0.25),
                      title: 'Admin',
                      subtitle: 'Manage & resolve complaints',
                      tag: 'AUTHORIZED ONLY',
                      tagColor: AppTheme.primaryLight.withOpacity(0.4),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.adminLogin),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '© 2025 College Portal',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.gradient,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _pressScale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(widget.icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(widget.subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.tagColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(widget.tag,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ),
          ]),
        ),
      ),
    );
  }
}

