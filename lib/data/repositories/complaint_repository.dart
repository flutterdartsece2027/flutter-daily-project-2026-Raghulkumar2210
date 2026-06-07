import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';

class ComplaintRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _col;

  ComplaintRepository() {
    _col = _firestore.collection('complaints');
  }

  // ── REAL-TIME STREAMS ──
  Stream<List<ComplaintModel>> getMyComplaintsStream(String studentId) {
    if (studentId.isEmpty) {
      return Stream.value([]);
    }
    return _col
        .where('studentId', isEqualTo: studentId)
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
          final list = snap.docs.map(ComplaintModel.fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        })
        .handleError((e) {
          print('Error in getMyComplaintsStream: $e');
          return <ComplaintModel>[];
        });
  }

  Stream<List<ComplaintModel>> getAllComplaintsStream({
    String? status,
    String? category,
  }) {
    Query q = _col;
    if (status != null) q = q.where('status', isEqualTo: status);
    if (category != null) q = q.where('category', isEqualTo: category);
    
    return q
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
          final list = snap.docs.map(ComplaintModel.fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        })
        .handleError((e) {
          print('Error in getAllComplaintsStream: $e');
          return <ComplaintModel>[];
        });
  }

  Stream<ComplaintModel?> getComplaintByIdStream(String id) {
    if (id.isEmpty) {
      return Stream.value(null);
    }
    return _col.doc(id)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
          if (!doc.exists) return null;
          return ComplaintModel.fromFirestore(doc);
        })
        .handleError((e) {
          return null;
        });
  }

  // ── ONE-TIME FETCHES (for initial load) ──
  Future<List<ComplaintModel>> getMyComplaints(String studentId) async {
    final snap = await _col
        .where('studentId', isEqualTo: studentId)
        .get();
    final list = snap.docs.map(ComplaintModel.fromFirestore).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<ComplaintModel>> getAllComplaints({
    String? status,
    String? category,
    String? search,
  }) async {
    Query q = _col;
    if (status != null) q = q.where('status', isEqualTo: status);
    if (category != null) q = q.where('category', isEqualTo: category);
    final snap = await q.get();
    var list = snap.docs.map(ComplaintModel.fromFirestore).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list
          .where((c) =>
              c.title.toLowerCase().contains(s) ||
              c.studentName.toLowerCase().contains(s))
          .toList();
    }
    return list;
  }

  Future<ComplaintModel> getComplaintById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) throw Exception('Complaint not found');
    return ComplaintModel.fromFirestore(doc);
  }

  Future<ComplaintModel> raiseComplaint({
    required String title,
    required String description,
    required String category,
    required String studentId,
    required String studentName,
    required String department,
    String? imagePath,
  }) async {
    final now = DateTime.now();
    final data = ComplaintModel(
      id: '',
      title: title,
      description: description,
      category: category,
      status: 'Pending',
      studentId: studentId,
      studentName: studentName,
      department: department,
      comments: [],
      timeline: [
        TimelineEvent(
          status: 'Pending',
          message: 'Complaint submitted successfully',
          timestamp: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    final ref = await _col.add(data.toFirestore());
    return ComplaintModel.fromFirestore(await ref.get());
  }

  Future<ComplaintModel> updateComplaintStatus(
    String id,
    String status, {
    String? remarks,
  }) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) throw Exception('Complaint not found');
    final old = ComplaintModel.fromFirestore(doc);
    final now = DateTime.now();
    final updated = {
      'status': status,
      'remarks': remarks ?? old.remarks,
      'updatedAt': Timestamp.fromDate(now),
      'timeline': FieldValue.arrayUnion([
        TimelineEvent(
          status: status,
          message: remarks ?? 'Status updated to $status',
          timestamp: now,
        ).toMap(),
      ]),
    };
    await _col.doc(id).update(updated);
    return ComplaintModel.fromFirestore(await _col.doc(id).get());
  }

  Future<ComplaintModel> addComment(
      String complaintId, String comment, String userId, String userName,
      {bool isAdmin = false}) async {
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      comment: comment,
      isAdmin: isAdmin,
      createdAt: DateTime.now(),
    );
    await _col.doc(complaintId).update({
      'comments': FieldValue.arrayUnion([newComment.toMap()]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    return ComplaintModel.fromFirestore(await _col.doc(complaintId).get());
  }

  Future<Map<String, int>> getStats(String? studentId) async {
    Query q = _col;
    if (studentId != null) q = q.where('studentId', isEqualTo: studentId);
    final snap = await q.get();
    final list = snap.docs.map(ComplaintModel.fromFirestore).toList();
    return {
      'total': list.length,
      'pending': list.where((c) => c.status == 'Pending').length,
      'inProgress': list.where((c) => c.status == 'In Progress').length,
      'resolved': list.where((c) => c.status == 'Resolved').length,
      'rejected': list.where((c) => c.status == 'Rejected').length,
    };
  }
}
