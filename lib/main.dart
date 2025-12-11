import 'package:face_locker_mobile/screens/access_logs_screen.dart';
import 'package:face_locker_mobile/screens/forgot_screen.dart';
import 'package:face_locker_mobile/screens/homepage_screen.dart';
import 'package:face_locker_mobile/screens/log_detail_screen.dart';
import 'package:face_locker_mobile/screens/login_screen.dart';
import 'package:face_locker_mobile/screens/notifications_screen.dart';
import 'package:face_locker_mobile/screens/otp_verification.dart';
import 'package:face_locker_mobile/screens/profile_screen.dart';
import 'package:face_locker_mobile/screens/register_screen.dart';
import 'package:face_locker_mobile/screens/reset_screen.dart';
import 'package:face_locker_mobile/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Locker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101922),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101922),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1C242D),
          selectedItemColor: Color(0xFF137FEC),
          unselectedItemColor: Color(0xFF9DABB9),
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpVerificationScreen(),
        '/reset': (context) => const ResetPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/logs': (context) => const AccessLogsScreen(),
        '/log-detail': (context) => const LogDetailScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
