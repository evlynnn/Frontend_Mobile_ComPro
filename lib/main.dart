import 'package:face_locker_mobile/constants/colors.dart';
import 'package:face_locker_mobile/screens/about_screen.dart';
import 'package:face_locker_mobile/screens/app_settings_screen.dart';
import 'package:face_locker_mobile/screens/contact_support_screen.dart';
import 'package:face_locker_mobile/screens/faq_screen.dart';
import 'package:face_locker_mobile/screens/forgot_screen.dart';
import 'package:face_locker_mobile/screens/log_detail_screen.dart';
import 'package:face_locker_mobile/screens/login_screen.dart';
import 'package:face_locker_mobile/screens/main_navigation_screen.dart';
import 'package:face_locker_mobile/screens/notifications_screen.dart';
import 'package:face_locker_mobile/screens/otp_verification.dart';
import 'package:face_locker_mobile/screens/register_screen.dart';
import 'package:face_locker_mobile/screens/reset_screen.dart';
import 'package:face_locker_mobile/screens/splash_screen.dart';
import 'package:face_locker_mobile/services/service_locator.dart';
import 'package:face_locker_mobile/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  // Initialize services
  ServiceLocator.setup();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Face Locker',
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,

          // Light Theme (Yellow/Gold)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColorsLight.background,
            fontFamily: 'Inter',
            primaryColor: AppColorsLight.primary,
            colorScheme: const ColorScheme.light(
              primary: AppColorsLight.primary,
              secondary: AppColorsLight.primaryHighlight,
              surface: AppColorsLight.surface,
              error: AppColorsLight.error,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColorsLight.background,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              centerTitle: true,
              iconTheme: IconThemeData(color: AppColorsLight.textPrimary),
              titleTextStyle: TextStyle(
                color: AppColorsLight.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: AppColorsLight.surface,
              selectedItemColor: AppColorsLight.primaryDarker,
              unselectedItemColor: AppColorsLight.textDisabled,
              type: BottomNavigationBarType.fixed,
            ),
            useMaterial3: true,
          ),

          // Dark Theme (Blue)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColorsDark.background,
            fontFamily: 'Inter',
            primaryColor: AppColorsDark.primary,
            colorScheme: const ColorScheme.dark(
              primary: AppColorsDark.primary,
              secondary: AppColorsDark.primaryHighlight,
              surface: AppColorsDark.surface,
              error: AppColorsDark.error,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColorsDark.background,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              centerTitle: true,
              iconTheme: IconThemeData(color: AppColorsDark.textPrimary),
              titleTextStyle: TextStyle(
                color: AppColorsDark.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: AppColorsDark.surface,
              selectedItemColor: AppColorsDark.primary,
              unselectedItemColor: AppColorsDark.textSecondary,
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
            '/home': (context) => const MainNavigationScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/log-detail': (context) => const LogDetailScreen(),
            '/settings': (context) => const AppSettingsScreen(),
            '/about': (context) => const AboutScreen(),
            '/faq': (context) => const FaqScreen(),
            '/contact-support': (context) => const ContactSupportScreen(),
          },
        );
      },
    );
  }
}
