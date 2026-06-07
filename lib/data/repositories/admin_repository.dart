import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/complaint_model.dart';
import 'complaint_repository.dart';

class AdminRepository {
  final _usersCol = FirebaseFirestore.instance.collection('users');
  final _complaintRepo = ComplaintRepository();

  Future<List<UserModel>> getAllStudents() async {
    final snap = await _usersCol.orderBy('createdAt', descending: true).get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }

  Future<void> deleteStudent(String id) async {
    await _usersCol.doc(id).delete();
  }

  Future<void> blockStudent(String id, bool block) async {
    await _usersCol.doc(id).update({'isBlocked': block});
  }

  Future<ComplaintModel> assignComplaint(
      String complaintId, String assignTo) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({'assignedTo': assignTo});
    return _complaintRepo.updateComplaintStatus(
        complaintId, 'In Progress',
        remarks: 'Assigned to $assignTo');
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final stats = await _complaintRepo.getStats(null);
    final studentsSnap = await _usersCol.count().get();
    return {
      'total': stats['total'],
      'pending': stats['pending'],
      'resolved': stats['resolved'],
      'rejected': stats['rejected'],
      'inProgress': stats['inProgress'],
      'totalStudents': studentsSnap.count,
    };
  }

  Future<Map<String, dynamic>> getMonthlyReport() async {
    final snap = await FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('createdAt')
        .get();
    final Map<String, int> report = {};
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    for (final doc in snap.docs) {
      final d = ComplaintModel.fromFirestore(doc);
      final key = months[d.createdAt.month - 1];
      report[key] = (report[key] ?? 0) + 1;
    }
    return report;
  }

  Future<Map<String, dynamic>> getDepartmentReport() async {
    final snap = await FirebaseFirestore.instance
        .collection('complaints')
        .get();
    final Map<String, int> report = {};
    for (final doc in snap.docs) {
      final d = ComplaintModel.fromFirestore(doc);
      report[d.department] = (report[d.department] ?? 0) + 1;
    }
    return report;
  }
}
