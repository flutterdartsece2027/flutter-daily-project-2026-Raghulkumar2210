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
    final d = doc.data() as Map<String, dynamic>? ?? {};
    
    DateTime parsedDate;
    final rawCreated = d['createdAt'];
    if (rawCreated is Timestamp) {
      parsedDate = rawCreated.toDate();
    } else if (rawCreated is String) {
      parsedDate = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else if (rawCreated is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawCreated);
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: doc.id,
      title: d['title'] ?? '',
      message: d['message'] ?? '',
      isRead: d['isRead'] == true,
      type: d['type'] ?? 'general',
      complaintId: d['complaintId']?.toString(),
      userId: d['userId'] ?? '',
      createdAt: parsedDate,
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
