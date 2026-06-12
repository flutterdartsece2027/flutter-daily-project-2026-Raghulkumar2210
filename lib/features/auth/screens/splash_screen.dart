import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/connectivity_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulse;
  late Animation<double> _particleAnim;

  Timer? _textTimer;
  Timer? _navigationTimer;
  ConnectivityProvider? _connectivityProvider;
  bool _isOffline = false;
  bool _animationFinished = false;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn));
    _textFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _pulse = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_particleCtrl);

    _logoCtrl.forward();
    _textTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _textCtrl.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectivityProvider = context.read<ConnectivityProvider>();
      _connectivityProvider!.addListener(_onConnectivityChanged);
    });

    _navigate();
  }

  void _onConnectivityChanged() {
    if (_connectivityProvider != null && _connectivityProvider!.isOnline) {
      if (_animationFinished && _isOffline) {
        setState(() {
          _isOffline = false;
        });
        _performNavigation();
      }
    }
  }

  void _navigate() {
    _navigationTimer = Timer(const Duration(milliseconds: 3500), () async {
      if (!mounted) return;
      _animationFinished = true;
      final conn = context.read<ConnectivityProvider>();
      if (conn.isOnline) {
        _performNavigation();
      } else {
        setState(() {
          _isOffline = true;
        });
      }
    });
  }

  Future<void> _performNavigation() async {
    final auth = context.read<AuthProvider>();
    await auth.checkLoginStatus();
    if (!mounted) return;
    if (auth.isStudent) {
      Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
    } else if (auth.isAdmin) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _navigationTimer?.cancel();
    if (_connectivityProvider != null) {
      _connectivityProvider!.removeListener(_onConnectivityChanged);
    }
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _particleAnim,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
            child: Stack(
              children: [
                // Floating particles
                ..._buildParticles(),
                // Glowing circle behind logo
                Center(
                  child: ScaleTransition(
                    scale: _pulse,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryLight.withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Main content
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryLight
                                        .withOpacity(0.6),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.school_rounded,
                                    size: 60, color: AppTheme.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Text
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textFade,
                            child: Column(children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppTheme.primaryGradient
                                        .createShader(bounds),
                                child: const Text(
                                  'Student Complaint',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Text(
                                'Portal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Your Voice. Our Priority.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 80),
                        FadeTransition(
                          opacity: _textFade,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: _isOffline
                                ? Container(
                                    key: const ValueKey('offline_ui'),
                                    margin: const EdgeInsets.symmetric(horizontal: 40),
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.wifi_off_rounded,
                                            color: Colors.redAccent,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No Internet Connection',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Please check your connection. The portal will automatically proceed once internet is restored.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    key: const ValueKey('online_ui'),
                                    children: [
                                      _AnimatedDots(),
                                      const SizedBox(height: 14),
                                      Text(
                                        AppConstants.appName,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 11,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildParticles() {
    final rng = Random(42);
    return List.generate(18, (i) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      final size = rng.nextDouble() * 6 + 2;
      final speed = rng.nextDouble() * 0.4 + 0.1;
      final phase = rng.nextDouble();
      final opacity =
          (0.1 + 0.3 * sin((_particleAnim.value + phase) * 2 * pi * speed))
              .clamp(0.05, 0.45);
      final offset = sin((_particleAnim.value + phase) * 2 * pi * speed) * 20;

      return Positioned(
        left: x * MediaQuery.of(context).size.width,
        top: y * MediaQuery.of(context).size.height + offset,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctls;
  late List<Animation<double>> _anims;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _ctls = List.generate(
      3,
      (i) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 600))
        ..repeat(
            reverse: true,
            period: Duration(milliseconds: 600 + i * 150)),
    );
    _anims = _ctls
        .map((c) =>
            Tween<double>(begin: 0.3, end: 1.0).animate(
                CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    for (int i = 0; i < 3; i++) {
      _timers.add(Timer(Duration(milliseconds: i * 200), () {
        if (mounted) _ctls[i].repeat(reverse: true);
      }));
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    for (final c in _ctls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, child) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: _anims[i].value),
            ),
          ),
        );
      }),
    );
  }
}

