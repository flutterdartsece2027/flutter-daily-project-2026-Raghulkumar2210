class AppConstants {
  static const String appName = 'Student Complaint Portal';
  static const String baseUrl = 'https://api.yourcollegeportal.com/api/v1';

  // Shared Prefs Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // Roles
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // Complaint Status
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusResolved = 'Resolved';
  static const String statusRejected = 'Rejected';

  static const List<String> complaintCategories = [
    'Academic',
    'Infrastructure',
    'Hostel',
    'Library',
    'Transport',
    'Ragging',
    'Faculty',
    'Canteen',
    'Other',
  ];
}
