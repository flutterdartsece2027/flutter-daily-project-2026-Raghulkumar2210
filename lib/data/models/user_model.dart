import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String rollNumber;
  final String? profileImage;
  final bool isBlocked;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.rollNumber,
    this.profileImage,
    this.isBlocked = false,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      department: d['department'] ?? '',
      rollNumber: d['rollNumber'] ?? '',
      profileImage: d['profileImage'],
      isBlocked: d['isBlocked'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'phone': phone,
        'department': department,
        'rollNumber': rollNumber,
        'profileImage': profileImage,
        'isBlocked': isBlocked,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? phone,
    String? department,
    String? profileImage,
    bool? isBlocked,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        department: department ?? this.department,
        rollNumber: rollNumber,
        profileImage: profileImage ?? this.profileImage,
        isBlocked: isBlocked ?? this.isBlocked,
        createdAt: createdAt,
      );
}
