import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user info from token or storage if available
      // For now, we'll use a placeholder since API doesn't have /me endpoint
      // You can add user info when login and store in SharedPreferences
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ServiceLocator.authService.logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            16, 16, 16, 96), // Bottom padding for nav bar
        child: Column(
          children: [
            // --- Profile Header ---
            const SizedBox(height: 16),
            Stack(
              children: [
                // Profile Image
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface(context),
                    border: Border.all(
                      color: AppColors.background(context),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuDoqUYKFRMSgvSOwZu0Gf4lN_W6KWM3ivc7_fBNgkDfLGboe7OVGrn59ot1WDsy30lVhL4BZuBGjsomOifzXGv0ETEaj0rByAyA0vDcz1TSlUkypUi9rdQMm5r78ozXxJ7JGgfASwP7Xlo5CXKfiyMp_DHrRd1Wd0Mu_Pm5M-iACiPDv60ARtKkEtmOYLlqT749yHYcAeb-nhTWMiYKRXhjGzdKtaCwndD-sMRIpdFoHRwZXqmbuZZkl8Xb-3hrUSeYzYJL3J344bg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Edit Button Overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background(context),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow(context),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColorsLight.stroke,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Alex Morgan',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'alex.morgan@example.com',
              style: TextStyle(
                color: AppColors.disabled(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // --- Menu Options ---
            _buildMenuItem(
              icon: Icons.settings,
              iconColor: AppColors.textPrimary(context),
              iconBgColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.stroke.withOpacity(0.3)
                  : AppColorsLight.divider,
              title: 'App Settings',
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),

            // --- Logout Section ---
            const SizedBox(height: 32),
            InkWell(
              onTap: _handleLogout,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.error(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.cardSurface(context),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout,
                        color: AppColors.error(context), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.error(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'App Version 2.4.0',
              style: TextStyle(
                color: AppColors.disabled(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.disabled(context),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
