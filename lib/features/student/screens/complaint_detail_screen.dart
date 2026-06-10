import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/complaint_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common_widgets.dart';

class ComplaintDetailScreen extends StatefulWidget {
  const ComplaintDetailScreen({super.key});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      context.read<ComplaintProvider>().fetchComplaintById(id);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final cp = context.read<ComplaintProvider>();
    final auth = context.read<AuthProvider>();
    final student = auth.student;
    final ok = await cp.addComment(
      cp.selected!.id,
      _commentCtrl.text.trim(),
      student?.id ?? '',
      student?.name ?? '',
    );
    if (ok) _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ComplaintProvider>();
    final c = cp.selected;

    if (cp.loading || c == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const GradientAppBar(title: 'Complaint Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(c.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    StatusBadge(status: c.status),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(c.category,
                          style: const TextStyle(
                              color: AppTheme.primary, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        '${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ]),
                  const SizedBox(height: 12),
                  Text(c.description,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85), height: 1.5)),
                  if (c.imageUrl != null && c.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.9),
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                InteractiveViewer(
                                  maxScale: 4.0,
                                  child: c.imageUrl!.startsWith('data:image/')
                                      ? Image.memory(
                                          base64Decode(c.imageUrl!.split(',').last),
                                          fit: BoxFit.contain,
                                        )
                                      : Image.network(
                                          c.imageUrl!,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: c.imageUrl!.startsWith('data:image/')
                            ? Image.memory(
                                base64Decode(c.imageUrl!.split(',').last),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                c.imageUrl!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ],
                  if (c.remarks != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.warning.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.info_outline,
                            color: AppTheme.warning, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Remarks: ${c.remarks}',
                              style: const TextStyle(
                                  color: AppTheme.warning, fontSize: 13)),
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (c.timeline.isNotEmpty) ...[
              const Text('Status Timeline',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _TimelineWidget(events: c.timeline),
              const SizedBox(height: 20),
            ],
            const Text('Comments',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (c.comments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text('No comments yet',
                    style: TextStyle(color: Colors.grey[400])),
              )
            else
              ...c.comments.map((cm) => _CommentBubble(comment: cm)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _commentCtrl,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _addComment,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;
  const _TimelineWidget({required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        children: events.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final isLast = i == events.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isLast ? AppTheme.success : AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.grey[200],
                  ),
              ]),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.status,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(e.message,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12)),
                      Text(
                          '${e.timestamp.day}/${e.timestamp.month}/${e.timestamp.year}',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final CommentModel comment;
  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: comment.isAdmin
            ? AppTheme.primary.withOpacity(0.06)
            : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: comment.isAdmin
                ? AppTheme.primary.withOpacity(0.2)
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.12) : Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: comment.isAdmin
                  ? AppTheme.primary.withOpacity(0.2)
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.08) : Colors.grey[200]),
              child: Icon(
                comment.isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : Icons.person_rounded,
                size: 16,
                color: comment.isAdmin ? AppTheme.primary : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text(comment.userName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            if (comment.isAdmin)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Admin',
                    style: TextStyle(
                        color: AppTheme.primary, fontSize: 10)),
              ),
            const Spacer(),
            Text('${comment.createdAt.day}/${comment.createdAt.month}',
                style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ]),
          const SizedBox(height: 8),
          Text(comment.comment,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85), fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

