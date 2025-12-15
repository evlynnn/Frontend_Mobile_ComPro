import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in (has valid token)
    final authService = ServiceLocator.authService;
    final isLoggedIn = await authService.isLoggedIn();

    if (!isLoggedIn) {
      // Not logged in, go to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    // User is logged in, check if biometric is enabled
    final biometricService = ServiceLocator.biometricService;
    final biometricEnabled = await biometricService.isBiometricEnabled();
    final biometricAvailable = await biometricService.isBiometricAvailable();

    if (biometricEnabled && biometricAvailable) {
      // Biometric is enabled, authenticate
      final authenticated = await biometricService.authenticate(
        reason: 'Authenticate to access Face Locker',
      );

      if (authenticated && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        // Authentication failed, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Biometric not enabled, go directly to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColorsDark.background,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColorsLight.background,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Stack(
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow(context),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lock,
                  size: 48,
                  color: isDark ? Colors.white : AppColorsLight.stroke,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 144,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : AppColorsLight.stroke,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
