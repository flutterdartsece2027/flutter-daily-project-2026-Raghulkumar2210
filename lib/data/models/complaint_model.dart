import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String studentId;
  final String studentName;
  final String department;
  final String? imageUrl;
  final String? assignedTo;
  final String? remarks;
  final List<CommentModel> comments;
  final List<TimelineEvent> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.studentId,
    required this.studentName,
    required this.department,
    this.imageUrl,
    this.assignedTo,
    this.remarks,
    this.comments = const [],
    this.timeline = const [],
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
  });

  factory ComplaintModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ComplaintModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: d['category'] ?? '',
      status: d['status'] ?? 'Pending',
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      department: d['department'] ?? '',
      imageUrl: d['imageUrl'],
      assignedTo: d['assignedTo'],
      remarks: d['remarks'],
      comments: (d['comments'] as List<dynamic>? ?? [])
          .map((e) => CommentModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      timeline: (d['timeline'] as List<dynamic>? ?? [])
          .map((e) => TimelineEvent.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: d['latitude'] != null ? (d['latitude'] as num).toDouble() : null,
      longitude: d['longitude'] != null ? (d['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'category': category,
        'status': status,
        'studentId': studentId,
        'studentName': studentName,
        'department': department,
        'imageUrl': imageUrl,
        'assignedTo': assignedTo,
        'remarks': remarks,
        'comments': comments.map((e) => e.toMap()).toList(),
        'timeline': timeline.map((e) => e.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'latitude': latitude,
        'longitude': longitude,
      };
}

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final bool isAdmin;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.isAdmin,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> m) => CommentModel(
        id: m['id'] ?? '',
        userId: m['userId'] ?? '',
        userName: m['userName'] ?? '',
        comment: m['comment'] ?? '',
        isAdmin: m['isAdmin'] ?? false,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'comment': comment,
        'isAdmin': isAdmin,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

class TimelineEvent {
  final String status;
  final String message;
  final DateTime timestamp;

  TimelineEvent({
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> m) => TimelineEvent(
        status: m['status'] ?? '',
        message: m['message'] ?? '',
        timestamp: (m['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
