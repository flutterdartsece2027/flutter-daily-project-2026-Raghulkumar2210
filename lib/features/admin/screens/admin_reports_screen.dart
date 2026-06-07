import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/admin_provider.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              const Text('Reports',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('PDF export feature coming soon')),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                label: const Text('Export PDF',
                    style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primary,
            tabs: const [
              Tab(text: 'Monthly'),
              Tab(text: 'Department'),
            ],
          ),
          Expanded(
            child: ap.loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _MonthlyChart(data: ap.monthlyReport),
                      _DepartmentChart(data: ap.deptReport),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final Map<String, dynamic> data;
  const _MonthlyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final values =
        List.generate(12, (i) => (data[months[i]] ?? 0).toDouble());
    final maxY = values.isEmpty
        ? 10.0
        : (values.reduce((a, b) => a > b ? a : b) + 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Complaints',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            height: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8)
              ],
            ),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: List.generate(
                  12,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: AppTheme.primary,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      )
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                          months[v.toInt()],
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(
                    show: true, drawVerticalLine: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentChart extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DepartmentChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.success,
      AppTheme.warning,
      AppTheme.error,
      const Color(0xFF8B5CF6),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Department-wise Complaints',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Text('No data available',
                  style: TextStyle(color: Colors.grey[500])),
            )
          else ...[
            Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8)
                ],
              ),
              child: PieChart(
                PieChartData(
                  sections: entries.asMap().entries.map((e) {
                    final color = colors[e.key % colors.length];
                    final val = (e.value.value ?? 0).toDouble();
                    return PieChartSectionData(
                      color: color,
                      value: val,
                      title: '${val.toInt()}',
                      radius: 80,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...entries.asMap().entries.map((e) {
              final color = colors[e.key % colors.length];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4)
                  ],
                ),
                child: Row(children: [
                  Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(e.value.key,
                          style: const TextStyle(fontSize: 14))),
                  Text('${e.value.value ?? 0}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 15)),
                ]),
              );
            }),
          ],
        ],
      ),
    );
  }
}
