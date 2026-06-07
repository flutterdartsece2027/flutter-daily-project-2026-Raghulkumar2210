import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/common_widgets.dart';
import 'admin_complaints_screen.dart';
import 'admin_students_screen.dart';
import 'admin_reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ap = context.read<AdminProvider>();
      ap.fetchDashboardStats();
      ap.fetchAllComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const _AdminHomeTab(),
          const AdminComplaintsScreen(),
          const AdminStudentsScreen(),
          const AdminReportsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt_rounded), label: 'Complaints'),
          NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people_rounded), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
        ],
      ),
    );
  }
}

class _AdminHomeTab extends StatelessWidget {
  const _AdminHomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ap = context.watch<AdminProvider>();
    final stats = ap.dashStats;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 170,
          pinned: true,
          floating: false,
          backgroundColor: const Color(0xFF1E293B),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.roleSelection, (r) => false);
                }
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppTheme.adminGradient),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Welcome, ${auth.admin?.name ?? 'Admin'}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Admin Portal', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                        ]),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    label: 'Total',
                    value: '${stats['total'] ?? 0}',
                    icon: Icons.folder_rounded,
                    color: AppTheme.primary,
                  ),
                  StatCard(
                    label: 'Pending',
                    value: '${stats['pending'] ?? 0}',
                    icon: Icons.hourglass_empty_rounded,
                    color: AppTheme.warning,
                  ),
                  StatCard(
                    label: 'Resolved',
                    value: '${stats['resolved'] ?? 0}',
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.success,
                  ),
                  StatCard(
                    label: 'Rejected',
                    value: '${stats['rejected'] ?? 0}',
                    icon: Icons.cancel_rounded,
                    color: AppTheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent Complaints'),
              const SizedBox(height: 14),
              if (ap.loading)
                const Center(child: CircularProgressIndicator())
              else
                ...ap.complaints.take(5).map((c) => ComplaintCard(
                      title: c.title,
                      category: c.category,
                      status: c.status,
                      date: c.createdAt,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.complaintDetail, arguments: c.id),
                    )),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }
}
