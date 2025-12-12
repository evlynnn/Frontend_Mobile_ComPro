import 'package:face_locker_mobile/constants/colors.dart';
import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _isDarkMode = false;
  bool _pushNotificationsEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // TODO: Implement actual theme switching logic
    // You might want to use a state management solution like Provider or Riverpod
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Dark mode ${value ? 'enabled' : 'disabled'}. Restart app to apply changes.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('App Settings'),
        backgroundColor:
            isDark ? AppColorsDark.background : AppColorsLight.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'APPEARANCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textDisabled(context),
                ),
              ),
            ),
            Container(
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
                border: Border.all(
                  color: isDark ? AppColorsDark.stroke : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColorsDark.stroke.withOpacity(0.3)
                            : AppColorsLight.divider,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.dark_mode,
                        color: AppColors.textPrimary(context),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    Switch(
                      value: _isDarkMode,
                      onChanged: _toggleDarkMode,
                      activeColor: AppColors.textPrimary(context),
                      activeTrackColor:
                          AppColors.textPrimary(context).withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Notifications Section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'NOTIFICATIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textDisabled(context),
                ),
              ),
            ),
            Container(
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
                border: Border.all(
                  color: isDark ? AppColorsDark.stroke : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColorsDark.stroke.withOpacity(0.3)
                            : AppColorsLight.divider,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get real-time updates when your smart lock is accessed or motion is detected.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Switch(
                        value: _pushNotificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _pushNotificationsEnabled = value;
                          });
                        },
                        activeColor: AppColors.textPrimary(context),
                        activeTrackColor:
                            AppColors.textPrimary(context).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Version Info
            Center(
              child: Text(
                'Version 2.4.1 (Build 204)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textDisabled(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
