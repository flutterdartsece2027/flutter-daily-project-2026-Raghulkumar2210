import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import '../data/repositories/complaint_repository.dart';
import '../data/models/complaint_model.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintRepository _repo = ComplaintRepository();

  List<ComplaintModel> _complaints = [];
  ComplaintModel? _selected;
  Map<String, int> _stats = {};
  bool _loading = false;
  String? _error;
  XFile? _pickedImage;
  
  // Stream subscriptions
  StreamSubscription<List<ComplaintModel>>? _complaintsSubscription;
  StreamSubscription<ComplaintModel?>? _selectedSubscription;
  String? _currentStudentId;

  List<ComplaintModel> get complaints => _complaints;
  ComplaintModel? get selected => _selected;
  Map<String, int> get stats => _stats;
  bool get loading => _loading;
  String? get error => _error;
  XFile? get pickedImage => _pickedImage;

  int get total => _complaints.length;
  int get pending => _complaints.where((c) => c.status == 'Pending').length;
  int get inProgress => _complaints.where((c) => c.status == 'In Progress').length;
  int get resolved => _complaints.where((c) => c.status == 'Resolved').length;

  void _setLoading(bool v) { 
    _loading = v; 
    notifyListeners(); 
  }
  
  void _setError(String? e) { 
    _error = e; 
    notifyListeners(); 
  }

  // ── REAL-TIME LISTENERS ──
  void listenToMyComplaints(String studentId) {
    // Only listen if studentId is not empty and is different from current
    if (studentId.isEmpty) {
      _complaints = [];
      _setLoading(false);
      return;
    }
    
    if (_currentStudentId == studentId) return; // Already listening
    
    _currentStudentId = studentId;
    _setLoading(true);
    _complaintsSubscription?.cancel();
    
    _complaintsSubscription = _repo.getMyComplaintsStream(studentId).listen(
      (complaints) {
        _complaints = complaints;
        _setError(null);
        _setLoading(false);
      },
      onError: (e) {
        print('ComplaintProvider Error: $e');
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  void listenToAllComplaints({String? status, String? category}) {
    _setLoading(true);
    _complaintsSubscription?.cancel();
    
    _complaintsSubscription = _repo.getAllComplaintsStream(status: status, category: category).listen(
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

  void listenToComplaintById(String id) {
    if (id.isEmpty) {
      _selected = null;
      _setLoading(false);
      return;
    }
    
    _setLoading(true);
    _selectedSubscription?.cancel();
    
    _selectedSubscription = _repo.getComplaintByIdStream(id).listen(
      (complaint) {
        _selected = complaint;
        _setError(null);
        _setLoading(false);
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  // ── FALLBACK ONE-TIME FETCH (for backward compatibility) ──
  Future<void> fetchMyComplaints(String studentId) async {
    listenToMyComplaints(studentId);
  }

  Future<void> fetchAllComplaints({String? status, String? category, String? search}) async {
    listenToAllComplaints(status: status, category: category);
  }

  Future<void> fetchComplaintById(String id) async {
    listenToComplaintById(id);
  }

  Future<bool> raiseComplaint({
    required String title,
    required String description,
    required String category,
    required String studentId,
    required String studentName,
    required String department,
  }) async {
    _setLoading(true); _setError(null);
    try {
      final c = await _repo.raiseComplaint(
        title: title,
        description: description,
        category: category,
        studentId: studentId,
        studentName: studentName,
        department: department,
        imagePath: _pickedImage?.path,
      );
      _complaints.insert(0, c);
      _pickedImage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally { _setLoading(false); }
  }

  Future<bool> updateStatus(String id, String status, {String? remarks}) async {
    _setLoading(true);
    try {
      final updated = await _repo.updateComplaintStatus(id, status, remarks: remarks);
      final idx = _complaints.indexWhere((c) => c.id == id);
      if (idx != -1) _complaints[idx] = updated;
      if (_selected?.id == id) _selected = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally { _setLoading(false); }
  }

  Future<bool> addComment(
      String complaintId, String comment, String userId, String userName,
      {bool isAdmin = false}) async {
    try {
      _selected = await _repo.addComment(
          complaintId, comment, userId, userName, isAdmin: isAdmin);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> fetchStats(String? studentId) async {
    try {
      _stats = await _repo.getStats(studentId);
      notifyListeners();
    } catch (_) {}
  }

  void pickImage(XFile? file) { _pickedImage = file; notifyListeners(); }
  void clearError() => _setError(null);

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    _selectedSubscription?.cancel();
    super.dispose();
  }
}
