import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/notification_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'features/auth/screens/student_login_screen.dart';
import 'features/auth/screens/student_register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/admin_login_screen.dart';
import 'features/student/screens/student_dashboard_screen.dart';
import 'features/student/screens/raise_complaint_screen.dart';
import 'features/student/screens/complaint_detail_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/profile/screens/student_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Student Complaint Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
          AppRoutes.studentLogin: (_) => const StudentLoginScreen(),
          AppRoutes.studentRegister: (_) => const StudentRegisterScreen(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
          AppRoutes.adminLogin: (_) => const AdminLoginScreen(),
          AppRoutes.studentDashboard: (_) => const StudentDashboardScreen(),
          AppRoutes.raiseComplaint: (_) => const RaiseComplaintScreen(),
          AppRoutes.complaintDetail: (_) => const ComplaintDetailScreen(),
          AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
          AppRoutes.studentProfile: (_) => const StudentProfileScreen(),
        },
      ),
    );
  }
}
