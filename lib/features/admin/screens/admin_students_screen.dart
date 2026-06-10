import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/admin_provider.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(children: [
              const Text('Students',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${ap.students.length} total',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ]),
          ),
          Expanded(
            child: ap.loading
                ? const Center(child: CircularProgressIndicator())
                : ap.students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('No students found',
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: ap.students.length,
                        itemBuilder: (_, i) {
                          final s = ap.students[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: s.isBlocked ? Colors.red.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: s.isBlocked
                                    ? AppTheme.error.withOpacity(0.3)
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6)
                              ],
                            ),
                            child: Row(children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: s.isBlocked
                                    ? AppTheme.error.withOpacity(0.15)
                                    : AppTheme.primary.withOpacity(0.15),
                                child: Text(
                                  s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: s.isBlocked
                                        ? AppTheme.error
                                        : AppTheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Expanded(
                                          child: Text(s.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14)),
                                        ),
                                        if (s.isBlocked)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.error
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text('Blocked',
                                                style: TextStyle(
                                                    color: AppTheme.error,
                                                    fontSize: 11)),
                                          ),
                                      ]),
                                      Text(s.email,
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12)),
                                      Text(
                                          '${s.department} • ${s.rollNumber}',
                                          style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 11)),
                                    ]),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert_rounded,
                                    color: Colors.grey[400]),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                onSelected: (val) async {
                                  if (val == 'block') {
                                    await ap.blockStudent(s.id, !s.isBlocked);
                                  } else if (val == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title:
                                            const Text('Delete Student'),
                                        content: Text(
                                            'Delete ${s.name}? This cannot be undone.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel')),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: AppTheme.error)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ap.deleteStudent(s.id);
                                    }
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'block',
                                    child: Row(children: [
                                      Icon(
                                          s.isBlocked
                                              ? Icons.lock_open_rounded
                                              : Icons.block_rounded,
                                          size: 18,
                                          color: AppTheme.warning),
                                      const SizedBox(width: 8),
                                      Text(s.isBlocked ? 'Unblock' : 'Block'),
                                    ]),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete_outline_rounded,
                                          size: 18, color: AppTheme.error),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ]),
                                  ),
                                ],
                              ),
                            ]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

