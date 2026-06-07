import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String type;
  final String? complaintId;
  final String userId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.type,
    this.complaintId,
    required this.userId,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: d['title'] ?? '',
      message: d['message'] ?? '',
      isRead: d['isRead'] ?? false,
      type: d['type'] ?? 'general',
      complaintId: d['complaintId'],
      userId: d['userId'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'message': message,
        'isRead': isRead,
        'type': type,
        'complaintId': complaintId,
        'userId': userId,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
