import 'package:flutter/material.dart';
import 'dart:async';
import '../data/repositories/notification_repository.dart';
import '../data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _loading = false;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;
  String? _currentUserId;

  List<NotificationModel> get notifications => _notifications;
  bool get loading => _loading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      _notifications = await _repo.getNotifications(userId);
      notifyListeners();
    } catch (_) {
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final n = _notifications[idx];
      _notifications[idx] = NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        isRead: true,
        type: n.type,
        complaintId: n.complaintId,
        userId: n.userId,
        createdAt: n.createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await _repo.markAllAsRead(userId);
    _notifications = _notifications
        .map((n) => NotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              isRead: true,
              type: n.type,
              complaintId: n.complaintId,
              userId: n.userId,
              createdAt: n.createdAt,
            ))
        .toList();
    notifyListeners();
  }

  void listenToNotifications(String userId) {
    if (userId.isEmpty) {
      _notifications = [];
      _loading = false;
      notifyListeners();
      return;
    }
    if (_currentUserId == userId) return; // Already listening

    _currentUserId = userId;
    _loading = true;
    notifyListeners();

    _notificationsSubscription?.cancel();
    _notificationsSubscription = _repo.getNotificationsStream(userId).listen(
      (notifications) {
        _notifications = notifications;
        _loading = false;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        notifyListeners();
      },
    );
  }

  void reset() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
    _notifications = [];
    _currentUserId = null;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
