import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _col = FirebaseFirestore.instance.collection('notifications');

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .get();
    final list = snap.docs.map(NotificationModel.fromFirestore).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> markAsRead(String id) async {
    await _col.doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> createNotification(NotificationModel n) async {
    await _col.add(n.toFirestore());
  }
}
