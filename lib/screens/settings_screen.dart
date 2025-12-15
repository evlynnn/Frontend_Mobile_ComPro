import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../services/theme_service.dart';
import '../services/service_locator.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
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

    if (confirmed == true && context.mounted) {
      try {
        await ServiceLocator.authService.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Header
            Text(
              'Preferences',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Theme Mode Toggle
            Container(
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColorsDark.stroke.withOpacity(0.3)
                          : AppColorsLight.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      themeService.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppColors.textPrimary(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          themeService.isDarkMode ? 'Enabled' : 'Disabled',
                          style: TextStyle(
                            color: AppColors.disabled(context),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeService.isDarkMode,
                    onChanged: (value) {
                      themeService.toggleTheme();
                    },
                    activeColor: AppColors.primary(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Push Notifications Toggle
            Container(
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColorsDark.stroke.withOpacity(0.3)
                          : AppColorsLight.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      themeService.pushNotificationsEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: AppColors.textPrimary(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Push Notifications',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          themeService.pushNotificationsEnabled
                              ? 'Enabled'
                              : 'Disabled',
                          style: TextStyle(
                            color: AppColors.disabled(context),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeService.pushNotificationsEnabled,
                    onChanged: (value) {
                      themeService.setPushNotifications(value);
                    },
                    activeColor: AppColors.primary(context),
                  ),
                ],
              ),
            ),

            // Logout Section
            const SizedBox(height: 32),
            InkWell(
              onTap: () => _handleLogout(context),
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
            Center(
              child: Text(
                'App Version 2.4.0',
                style: TextStyle(
                  color: AppColors.disabled(context),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
