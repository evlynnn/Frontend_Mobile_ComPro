import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto navigate to login after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor:
            Colors.transparent, // Transparan agar bg aplikasi terlihat
        systemNavigationBarColor:
            const Color(0xFF101922), // Warna navigasi bawah
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF101922),
        body: Stack(
          children: [
            // 1. Center Content (Logo)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96, // w-24 (24 * 4 = 96px)
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFF137FEC), // primary color
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 48, // text-6xl equivalent visually
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Home Indicator (Bottom)
            // Catatan: Pada aplikasi iOS asli, OS yang menggambar ini.
            // Di sini kita menggambarnya secara manual agar sesuai dengan desain HTML.
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 144, // w-36 (36 * 4 = 144px)
                  height: 6, // h-1.5 (1.5 * 4 = 6px)
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100), // rounded-full
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
