import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/common_widgets.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});
  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final studentId = auth.student?.id ?? '';
      context.read<ComplaintProvider>().fetchMyComplaints(studentId);
      context.read<NotificationProvider>().fetchNotifications(studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _ComplaintsTab(),
          _NotificationsTab(),
          _ProfileTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? _AnimatedFAB(onTap: () =>
              Navigator.pushNamed(context, AppRoutes.raiseComplaint))
          : null,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Animated FAB ──────────────────────────────────────────────
class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedFAB({required this.onTap});
  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1, end: 0.92).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text('New Complaint',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home'),
        const NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Complaints'),
        NavigationDestination(
          icon: Consumer<NotificationProvider>(
            builder: (context, np, child) => Badge(
              isLabelVisible: np.unreadCount > 0,
              label: Text('${np.unreadCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          selectedIcon: const Icon(Icons.notifications_rounded),
          label: 'Alerts',
        ),
        const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile'),
      ],
    );
  }
}

// ── HOME TAB ─────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cp = context.watch<ComplaintProvider>();
    final student = auth.student;

    return CustomScrollView(
      slivers: [
        // ── Header ──
        SliverToBoxAdapter(
          child: _DashboardHeader(
            name: student?.name ?? 'Student',
            department: student?.department ?? '',
            rollNo: student?.rollNumber ?? '',
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Stats Banner ──
              _StatsBanner(cp: cp),
              const SizedBox(height: 28),

              // ── Progress Ring Section ──
              _ProgressSection(cp: cp),
              const SizedBox(height: 28),

              // ── Recent Complaints ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Complaints',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface)),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('See All',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (cp.loading)
                const Center(child: CircularProgressIndicator())
              else if (cp.complaints.isEmpty)
                const _EmptyComplaints()
              else
                ...cp.complaints
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map((e) => _AnimatedComplaintCard(
                          index: e.key,
                          complaint: e.value,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.complaintDetail,
                              arguments: e.value.id),
                        )),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Dashboard Header ──────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final String name;
  final String department;
  final String rollNo;
  const _DashboardHeader(
      {required this.name, required this.department, required this.rollNo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good ${_greeting()} 👋',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(department,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
                        if (rollNo.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(rollNo,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11)),
                        ],
                      ]),
                    ],
                  ),
                ),
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ── Stats Banner (horizontal scroll cards) ────────────────────
class _StatsBanner extends StatelessWidget {
  final ComplaintProvider cp;
  const _StatsBanner({required this.cp});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem('Total', cp.total, Icons.layers_rounded,
          const LinearGradient(colors: [Color(0xFF6C3CE1), Color(0xFF3A7EFF)]),
          const Color(0xFFEDE9FE)),
      _StatItem('Pending', cp.pending, Icons.hourglass_top_rounded,
          const LinearGradient(colors: [Color(0xFFFFAA00), Color(0xFFFF6B00)]),
          const Color(0xFFFFF7E6)),
      _StatItem('In Progress', cp.inProgress, Icons.autorenew_rounded,
          const LinearGradient(colors: [Color(0xFF00C6AE), Color(0xFF0093AB)]),
          const Color(0xFFE0FAF7)),
      _StatItem('Resolved', cp.resolved, Icons.check_circle_rounded,
          const LinearGradient(colors: [Color(0xFF00C48C), Color(0xFF00968A)]),
          const Color(0xFFE0FAF0)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 14),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stats.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _StatBannerCard(item: stats[i], index: i),
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final LinearGradient gradient;
  final Color bgColor;
  const _StatItem(
      this.label, this.value, this.icon, this.gradient, this.bgColor);
}

class _StatBannerCard extends StatefulWidget {
  final _StatItem item;
  final int index;
  const _StatBannerCard({required this.item, required this.index});
  @override
  State<_StatBannerCard> createState() => _StatBannerCardState();
}

class _StatBannerCardState extends State<_StatBannerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + widget.index * 100));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _timer = Timer(Duration(milliseconds: widget.index * 80),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          width: 130,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.item.gradient.colors.first.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: widget.item.gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.item.icon, color: Colors.white, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CountUpText(
                    end: widget.item.value,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: widget.item.gradient.colors.first,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(widget.item.label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A94A6),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Count Up Animation ────────────────────────────────────────
class _CountUpText extends StatefulWidget {
  final int end;
  final TextStyle style;
  const _CountUpText({required this.end, required this.style});
  @override
  State<_CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<_CountUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = IntTween(begin: 0, end: widget.end)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) =>
          Text('${_anim.value}', style: widget.style),
    );
  }
}

// ── Progress Ring Section ─────────────────────────────────────
class _ProgressSection extends StatelessWidget {
  final ComplaintProvider cp;
  const _ProgressSection({required this.cp});

  @override
  Widget build(BuildContext context) {
    final total = cp.total == 0 ? 1 : cp.total;
    final resolvedPct = cp.resolved / total;
    final pendingPct = cp.pending / total;
    final inProgressPct = cp.inProgress / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0533), Color(0xFF2E1065)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Complaint Status',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${cp.total} Total',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Ring
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _RingPainter(
                    resolvedPct: resolvedPct,
                    pendingPct: pendingPct,
                    inProgressPct: inProgressPct,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(resolvedPct * 100).toInt()}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900),
                        ),
                        Text('Done',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  children: [
                    _RingLegend(
                        color: const Color(0xFF00C48C),
                        label: 'Resolved',
                        value: cp.resolved,
                        pct: resolvedPct),
                    const SizedBox(height: 12),
                    _RingLegend(
                        color: const Color(0xFFFFAA00),
                        label: 'Pending',
                        value: cp.pending,
                        pct: pendingPct),
                    const SizedBox(height: 12),
                    _RingLegend(
                        color: const Color(0xFF3A7EFF),
                        label: 'In Progress',
                        value: cp.inProgress,
                        pct: inProgressPct),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingLegend extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final double pct;
  const _RingLegend(
      {required this.color,
      required this.label,
      required this.value,
      required this.pct});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12)),
          ),
          Text('$value',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

// ── Ring Painter ──────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double resolvedPct;
  final double pendingPct;
  final double inProgressPct;
  const _RingPainter(
      {required this.resolvedPct,
      required this.pendingPct,
      required this.inProgressPct});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;
    const gap = 0.04;

    final rect =
        Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Background ring
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final segments = [
      (resolvedPct, const Color(0xFF00C48C)),
      (pendingPct, const Color(0xFFFFAA00)),
      (inProgressPct, const Color(0xFF3A7EFF)),
    ];

    double startAngle = -pi / 2;
    for (final seg in segments) {
      final sweep = seg.$1 * 2 * pi - gap;
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          startAngle,
          sweep,
          false,
          Paint()
            ..color = seg.$2
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
        );
      }
      startAngle += seg.$1 * 2 * pi;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Animated Complaint Card ───────────────────────────────────
class _AnimatedComplaintCard extends StatefulWidget {
  final int index;
  final dynamic complaint;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  const _AnimatedComplaintCard({
    required this.index,
    required this.complaint,
    required this.onTap,
    this.onDelete,
  });
  @override
  State<_AnimatedComplaintCard> createState() =>
      _AnimatedComplaintCardState();
}

class _AnimatedComplaintCardState extends State<_AnimatedComplaintCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _timer = Timer(Duration(milliseconds: widget.index * 80),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: ComplaintCard(
          title: widget.complaint.title,
          category: widget.complaint.category,
          status: widget.complaint.status,
          date: widget.complaint.createdAt,
          onTap: widget.onTap,
          onDelete: widget.onDelete,
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────
class _EmptyComplaints extends StatelessWidget {
  const _EmptyComplaints();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.inbox_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        const Text('No Complaints Yet',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF1A1A2E))),
        const SizedBox(height: 6),
        Text('Tap the button below to raise\nyour first complaint',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5)),
      ]),
    );
  }
}

// ── COMPLAINTS TAB ────────────────────────────────────────────
class _ComplaintsTab extends StatefulWidget {
  const _ComplaintsTab();
  @override
  State<_ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<_ComplaintsTab> {
  String _filter = 'All';
  final _filters = ['All', 'Pending', 'In Progress', 'Resolved', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ComplaintProvider>();
    final filtered = _filter == 'All'
        ? cp.complaints
        : cp.complaints.where((c) => c.status == _filter).toList();

    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            const Text('My Complaints',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${filtered.length}',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final sel = _filter == _filters[i];
              return GestureDetector(
                onTap: () => setState(() => _filter = _filters[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: sel ? AppTheme.primaryGradient : null,
                    color: sel ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                    border: Border.all(
                        color: sel ? Colors.transparent : Colors.grey[300]!),
                  ),
                  child: Text(_filters[i],
                      style: TextStyle(
                          color: sel ? Colors.white : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.normal)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: cp.loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(child: _EmptyComplaints())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final complaint = filtered[i];
                        return _AnimatedComplaintCard(
                          index: i,
                          complaint: complaint,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.complaintDetail,
                              arguments: complaint.id),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: AppTheme.error),
                                    SizedBox(width: 8),
                                    Text('Delete Complaint'),
                                  ],
                                ),
                                content: Text('Are you sure you want to delete the complaint "${complaint.title}"? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.error,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              final success = await context
                                  .read<ComplaintProvider>()
                                  .deleteComplaint(complaint.id);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Complaint deleted successfully'),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}

// ── NOTIFICATIONS TAB ─────────────────────────────────────────
class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();
  @override
  Widget build(BuildContext context) {
    final np = context.watch<NotificationProvider>();
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            const Text('Notifications',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (np.unreadCount > 0)
              GestureDetector(
                onTap: () {
                  final auth = context.read<AuthProvider>();
                  np.markAllAsRead(auth.student?.id ?? '');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Mark all read',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
        ),
        Expanded(
          child: np.loading
              ? const Center(child: CircularProgressIndicator())
              : np.notifications.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.notifications_none_rounded,
                                size: 36, color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 16),
                          Text('No Notifications',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600)),
                        ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: np.notifications.length,
                      itemBuilder: (_, i) {
                        final n = np.notifications[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface)
                                : AppTheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: n.isRead
                                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!)
                                    : AppTheme.primary
                                        .withOpacity(0.25)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: n.isRead
                                      ? null
                                      : AppTheme.primaryGradient,
                                  color: n.isRead
                                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.08) : Colors.grey[100])
                                      : null,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.notifications_rounded,
                                    color: n.isRead
                                        ? Colors.grey[400]
                                        : Colors.white,
                                    size: 20),
                              ),
                              title: Text(n.title,
                                  style: TextStyle(
                                      fontWeight: n.isRead
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                      fontSize: 13)),
                              subtitle: Text(n.message,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              onTap: () => np.markAsRead(n.id),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}

// ── PROFILE TAB ───────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final s = auth.student;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(children: [
          // Profile header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Column(children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        s?.name.isNotEmpty == true
                            ? s!.name[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                            fontSize: 38,
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: AppTheme.primary, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(s?.name ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(s?.email ?? '',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _PillBadge(s?.department ?? ''),
                const SizedBox(width: 8),
                _PillBadge(s?.rollNumber ?? ''),
              ]),
            ]),
          ),
          // Menu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _ProfileTile(Icons.person_outline_rounded, 'Edit Profile',
                  'Update your details', AppTheme.primary,
                  () => Navigator.pushNamed(context, AppRoutes.studentProfile)),
              _ProfileTile(Icons.lock_outline_rounded, 'Change Password',
                  'Update your password', AppTheme.secondary, () {}),
              rp.Consumer(
                builder: (context, ref, child) {
                  final themeMode = ref.watch(themeProvider);
                  return _ProfileThemeTile(
                    themeMode: themeMode,
                    onChanged: (mode) {
                      ref.read(themeProvider.notifier).setThemeMode(mode);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(Icons.logout_rounded, 'Logout',
                  'Sign out of your account', AppTheme.error, () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.roleSelection, (r) => false);
                }
              }),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String text;
  const _PillBadge(this.text);
  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ProfileTile(
      this.icon, this.title, this.subtitle, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          trailing: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 18),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ProfileThemeTile extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ProfileThemeTile({
    required this.themeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          title: const Text('Dark Mode',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(
            themeMode == ThemeMode.system
                ? 'System Default'
                : (isDark ? 'Enabled' : 'Disabled'),
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (val) {
              onChanged(val ? ThemeMode.dark : ThemeMode.light);
            },
            activeColor: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

