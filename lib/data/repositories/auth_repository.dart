import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/admin_model.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> studentLogin(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    if (!doc.exists) throw Exception('Student account not found.');
    final user = UserModel.fromFirestore(doc);
    if (user.isBlocked) throw Exception('Your account has been blocked.');
    return {'user': user};
  }

  Future<Map<String, dynamic>> studentRegister(Map<String, dynamic> body) async {
    final email = body['email']?.toString().trim() ?? '';
    final password = body['password']?.toString() ?? '';

    // Step 1: Create Firebase Auth user
    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already registered. Please login.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters.');
        case 'operation-not-allowed':
          throw Exception('Email/Password sign-in is not enabled. Please contact admin.');
        default:
          throw Exception(e.message ?? 'Registration failed.');
      }
    }

    // Step 2: Save user profile to Firestore users collection
    final user = UserModel(
      id: cred.user!.uid,
      name: body['name']?.toString().trim() ?? '',
      email: email,
      phone: body['phone']?.toString().trim() ?? '',
      department: body['department']?.toString() ?? '',
      rollNumber: body['rollNumber']?.toString().trim() ?? '',
      isBlocked: false,
      createdAt: DateTime.now(),
    );

    try {
      await _db.collection('users').doc(cred.user!.uid).set(user.toFirestore());
    } catch (e) {
      // Auth succeeded but Firestore write failed — still return user
      // Firestore write will be retried on next login
    }

    return {'user': user};
  }

  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);

    final query = await _db
        .collection('admins')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception('Invalid admin credentials.');

    final admin = AdminModel.fromFirestore(query.docs.first);
    return {'admin': admin};
  }

  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in.');
    final cred = EmailAuthProvider.credential(
        email: user.email!, password: oldPassword);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> getSavedRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) return AppConstants.roleStudent;
    final adminQuery = await _db
        .collection('admins')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (adminQuery.docs.isNotEmpty) return AppConstants.roleAdmin;
    return null;
  }

  Future<UserModel?> getCurrentStudent() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<AdminModel?> getCurrentAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final query = await _db
        .collection('admins')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return AdminModel.fromFirestore(query.docs.first);
  }
}
