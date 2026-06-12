import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'connectivity_helper.dart' as helper;

class ConnectivityProvider extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  bool _isOnline = true;
  bool _checking = false;
  Timer? _timer;

  bool get isOnline => _isOnline;
  bool get checking => _checking;

  ConnectivityProvider() {
    _startMonitoring();
  }

  void _startMonitoring() {
    checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      checkConnectivity();
    });
  }

  Future<bool> checkConnectivity() async {
    _checking = true;
    
    if (kIsWeb) {
      final online = helper.getOnlineStatus();
      if (_isOnline != online) {
        _isOnline = online;
        notifyListeners();
      }
      _checking = false;
      return online;
    }

    try {
      // Query clients3.google.com/generate_204 which is extremely lightweight and standard for Android/Chrome connection check
      final response = await _dio.get('https://clients3.google.com/generate_204');
      final online = response.statusCode == 204 || response.statusCode == 200;
      if (_isOnline != online) {
        _isOnline = online;
        notifyListeners();
      }
      return online;
    } catch (_) {
      if (_isOnline != false) {
        _isOnline = false;
        notifyListeners();
      }
      return false;
    } finally {
      _checking = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
