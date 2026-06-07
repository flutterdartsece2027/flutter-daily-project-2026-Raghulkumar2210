import 'package:flutter/material.dart';
import 'dart:async';
import '../data/repositories/admin_repository.dart';
import '../data/repositories/complaint_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/complaint_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepo = AdminRepository();
  final ComplaintRepository _complaintRepo = ComplaintRepository();

  List<UserModel> _students = [];
  List<ComplaintModel> _complaints = [];
  Map<String, dynamic> _dashStats = {};
  Map<String, dynamic> _monthlyReport = {};
  Map<String, dynamic> _deptReport = {};
  bool _loading = false;
  String? _error;
  
  // Stream subscription
  StreamSubscription<List<ComplaintModel>>? _complaintsSubscription;

  List<UserModel> get students => _students;
  List<ComplaintModel> get complaints => _complaints;
  Map<String, dynamic> get dashStats => _dashStats;
  Map<String, dynamic> get monthlyReport => _monthlyReport;
  Map<String, dynamic> get deptReport => _deptReport;
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool v) { 
    _loading = v; 
    notifyListeners(); 
  }
  
  void _setError(String? e) { 
    _error = e; 
    notifyListeners(); 
  }

  Future<void> fetchDashboardStats() async {
    _setLoading(true);
    try {
      _dashStats = await _adminRepo.getDashboardStats();
      _setError(null);
      notifyListeners();
    } catch (e) {

      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ── REAL-TIME LISTENER ──
  void listenToAllComplaints({String? status, String? category}) {
    _setLoading(true);
    _complaintsSubscription?.cancel();
    
    _complaintsSubscription = _complaintRepo.getAllComplaintsStream(status: status, category: category).listen(
      (complaints) {
        _complaints = complaints;
        _setError(null);
        _setLoading(false);
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  // ── FALLBACK ONE-TIME FETCH ──
  Future<void> fetchAllComplaints({String? status, String? category, String? search}) async {
    listenToAllComplaints(status: status, category: category);
  }

  Future<bool> updateComplaintStatus(String id, String status, {String? remarks}) async {
    try {
      final updated = await _complaintRepo.updateComplaintStatus(id, status, remarks: remarks);
      final idx = _complaints.indexWhere((c) => c.id == id);
      if (idx != -1) _complaints[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> fetchStudents() async {
    _setLoading(true);
    try {
      _students = await _adminRepo.getAllStudents();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      await _adminRepo.deleteStudent(id);
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> blockStudent(String id, bool block) async {
    try {
      await _adminRepo.blockStudent(id, block);
      final idx = _students.indexWhere((s) => s.id == id);
      if (idx != -1) {
        _students[idx] = UserModel(
          id: _students[idx].id,
          name: _students[idx].name,
          email: _students[idx].email,
          phone: _students[idx].phone,
          department: _students[idx].department,
          rollNumber: _students[idx].rollNumber,
          isBlocked: block,
          createdAt: _students[idx].createdAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> fetchReports() async {
    _setLoading(true);
    try {
      _monthlyReport = await _adminRepo.getMonthlyReport();
      _deptReport = await _adminRepo.getDepartmentReport();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    super.dispose();
  }
}
