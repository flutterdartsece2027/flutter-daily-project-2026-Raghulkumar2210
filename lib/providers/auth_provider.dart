import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/admin_model.dart';
import '../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  UserModel? _student;
  AdminModel? _admin;
  bool _loading = false;
  String? _error;
  String? _role;

  UserModel? get student => _student;
  AdminModel? get admin => _admin;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _student != null || _admin != null;
  bool get isStudent => _role == AppConstants.roleStudent;
  bool get isAdmin => _role == AppConstants.roleAdmin;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  String _parseError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use': return 'This email is already registered.';
        case 'invalid-email': return 'Invalid email address.';
        case 'weak-password': return 'Password must be at least 6 characters.';
        case 'user-not-found': return 'No account found with this email.';
        case 'wrong-password': return 'Incorrect password.';
        case 'operation-not-allowed': return 'Email/Password login not enabled in Firebase Console.';
        case 'network-request-failed': return 'Network error. Check your connection.';
        case 'too-many-requests': return 'Too many attempts. Try again later.';
        default: return e.message ?? 'Authentication failed.';
      }
    }
    return e.toString().replaceAll('Exception: ', '');
  }

  Future<bool> studentLogin(String email, String password) async {
    _setLoading(true); _setError(null);
    try {
      final result = await _repo.studentLogin(email, password);
      _student = result['user'];
      _role = AppConstants.roleStudent;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    } finally { _setLoading(false); }
  }

  Future<bool> studentRegister(Map<String, dynamic> data) async {
    _setLoading(true); _setError(null);
    try {
      final result = await _repo.studentRegister(data);
      _student = result['user'];
      _role = AppConstants.roleStudent;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    } finally { _setLoading(false); }
  }

  Future<bool> adminLogin(String email, String password) async {
    _setLoading(true); _setError(null);
    try {
      final result = await _repo.adminLogin(email, password);
      _admin = result['admin'];
      _role = AppConstants.roleAdmin;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    } finally { _setLoading(false); }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true); _setError(null);
    try {
      await _repo.forgotPassword(email);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    } finally { _setLoading(false); }
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    _setLoading(true); _setError(null);
    try {
      await _repo.changePassword(oldPass, newPass);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      return false;
    } finally { _setLoading(false); }
  }

  Future<void> checkLoginStatus() async {
    try {
      _role = await _repo.getSavedRole();
      if (_role == AppConstants.roleStudent) {
        _student = await _repo.getCurrentStudent();
      } else if (_role == AppConstants.roleAdmin) {
        _admin = await _repo.getCurrentAdmin();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    _student = null;
    _admin = null;
    _role = null;
    notifyListeners();
  }
}
