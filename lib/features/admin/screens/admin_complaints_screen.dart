import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/common_widgets.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final _searchCtrl = TextEditingController();
  String _filterStatus = 'All';
  String _filterCategory = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<AdminProvider>().fetchAllComplaints(
          status: _filterStatus == 'All' ? null : _filterStatus,
          category: _filterCategory == 'All' ? null : _filterCategory,
          search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        );
  }

  Future<void> _showStatusDialog(BuildContext context, String complaintId) async {
    String selected = AppConstants.statusPending;
    final remarksCtrl = TextEditingController();
    final statuses = [
      AppConstants.statusPending,
      AppConstants.statusInProgress,
      AppConstants.statusResolved,
      AppConstants.statusRejected,
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, ss) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Update Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...statuses.map((s) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<String>(
                        value: s,
                        groupValue: selected, // ignore: deprecated_member_use
                        activeColor: AppTheme.primary,
                        onChanged: (v) => ss(() => selected = v!), // ignore: deprecated_member_use
                      ),
                      title: Text(s),
                      onTap: () => ss(() => selected = s),
                    )),
                const SizedBox(height: 8),
                TextField(
                  controller: remarksCtrl,
                  decoration: InputDecoration(
                    labelText: 'Remarks (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                GradientButton(
                  text: 'Update',
                  onTap: () async {
                    final ap = context.read<AdminProvider>();
                    await ap.updateComplaintStatus(complaintId, selected,
                        remarks: remarksCtrl.text.trim().isEmpty
                            ? null
                            : remarksCtrl.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();
    final statusItems = [
      'All',
      AppConstants.statusPending,
      AppConstants.statusInProgress,
      AppConstants.statusResolved,
      AppConstants.statusRejected,
    ];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(children: [
                  const Text('Complaints',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${ap.complaints.length}',
                      style: TextStyle(color: Colors.grey[500])),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _searchCtrl,
                  onChanged: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Search complaints...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: statusItems
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _filterStatus = v!);
                          _search();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ['All', ...AppConstants.complaintCategories]
                            .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _filterCategory = v!);
                          _search();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ap.loading
                ? const Center(child: CircularProgressIndicator())
                : ap.complaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('No complaints found',
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: ap.complaints.length,
                        itemBuilder: (_, i) {
                          final c = ap.complaints[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6)
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(c.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                  ),
                                  StatusBadge(status: c.status),
                                ]),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Icon(Icons.person_outline,
                                      size: 13, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(c.studentName,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500])),
                                  const SizedBox(width: 12),
                                  Icon(Icons.category_outlined,
                                      size: 13, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(c.category,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500])),
                                ]),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _showStatusDialog(context, c.id),
                                    icon: const Icon(Icons.edit_rounded,
                                        size: 16),
                                    label: const Text('Update Status',
                                        style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primary,
                                      side: const BorderSide(
                                          color: AppTheme.primary),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

