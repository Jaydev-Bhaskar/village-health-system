import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(VillageHealthApp(isLoggedIn: isLoggedIn));
}

class VillageHealthApp extends StatelessWidget {
  final bool isLoggedIn;

  const VillageHealthApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Village Health Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MapScreen() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
