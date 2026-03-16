import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/map_screen.dart';
import 'screens/student/visit_verification_screen.dart';
import 'screens/student/patient_form_screen.dart';
import 'screens/student/visit_history_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/upload_students_screen.dart';
import 'screens/admin/upload_houses_screen.dart';
import 'screens/admin/clustering_screen.dart';
import 'screens/admin/analytics_screen.dart';
import 'screens/admin/student_details_screen.dart';
import 'screens/notifications/notification_settings_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initialize();

  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  runApp(VillageHealthApp(authProvider: authProvider));
}

class VillageHealthApp extends StatelessWidget {
  final AuthProvider authProvider;
  
  const VillageHealthApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp(
        title: 'MedNova',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: authProvider.isAuthenticated 
            ? (authProvider.isAdmin ? '/admin/dashboard' : '/student/dashboard') 
            : '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/change-password': (_) => const ChangePasswordScreen(),
          '/student/dashboard': (_) => const StudentDashboard(),
          '/student/map': (_) => const MapScreen(),
          '/student/verify': (_) => const VisitVerificationScreen(),
          '/student/patient-form': (_) => const PatientFormScreen(),
          '/student/history': (_) => const VisitHistoryScreen(),
          '/admin/dashboard': (_) => const AdminDashboard(),
          '/admin/upload-students': (_) => const UploadStudentsScreen(),
          '/admin/upload-houses': (_) => const UploadHousesScreen(),
          '/admin/clustering': (_) => const ClusteringScreen(),
          '/admin/analytics': (_) => const AnalyticsScreen(),
          '/admin/students': (_) => const StudentDetailsScreen(),
          '/notifications/settings': (_) => const NotificationSettingsScreen(),
        },
      ),
    );
  }
}
