import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../services/theme_service.dart';
import '../services/service_locator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricTypeName = 'Biometric';

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final biometricService = ServiceLocator.biometricService;
    final available = await biometricService.isBiometricAvailable();
    final enabled = await biometricService.isBiometricEnabled();
    final typeName = await biometricService.getBiometricTypeName();

    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _biometricTypeName = typeName;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final biometricService = ServiceLocator.biometricService;

    if (value) {
      // Enable biometric - requires authentication
      final success = await biometricService.enableBiometric();
      if (success && mounted) {
        setState(() => _biometricEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('$_biometricTypeName login enabled'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      // Disable biometric
      await biometricService.disableBiometric();
      if (mounted) {
        setState(() => _biometricEnabled = false);
      }
    }
  }

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
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'More',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences Section
            _buildSectionHeader(context, 'Preferences'),
            const SizedBox(height: 12),

            // Theme Mode Toggle
            _buildToggleItem(
              context,
              icon:
                  themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              title: 'Dark Mode',
              subtitle: themeService.isDarkMode ? 'Enabled' : 'Disabled',
              value: themeService.isDarkMode,
              onChanged: (value) => themeService.toggleTheme(),
            ),

            const SizedBox(height: 10),

            // Push Notifications Toggle
            _buildToggleItem(
              context,
              icon: themeService.pushNotificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              title: 'Push Notifications',
              subtitle: themeService.pushNotificationsEnabled
                  ? 'Enabled'
                  : 'Disabled',
              value: themeService.pushNotificationsEnabled,
              onChanged: (value) => themeService.setPushNotifications(value),
            ),

            // Biometric Login Toggle (only show if available)
            if (_biometricAvailable) ...[
              const SizedBox(height: 10),
              _buildToggleItem(
                context,
                icon: Icons.fingerprint_rounded,
                title: '$_biometricTypeName Login',
                subtitle: _biometricEnabled
                    ? 'Quick unlock enabled'
                    : 'Use $_biometricTypeName to unlock app',
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
              ),
            ],

            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader(context, 'Support'),
            const SizedBox(height: 12),

            _buildMenuItem(
              context,
              icon: Icons.help_outline_rounded,
              title: 'FAQ',
              subtitle: 'Frequently asked questions',
              onTap: () => Navigator.pushNamed(context, '/faq'),
            ),

            const SizedBox(height: 10),

            _buildMenuItem(
              context,
              icon: Icons.headset_mic_rounded,
              title: 'Contact Support',
              subtitle: 'Get help from our team',
              onTap: () => Navigator.pushNamed(context, '/contact-support'),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, 'About'),
            const SizedBox(height: 12),

            _buildMenuItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About Face Locker',
              subtitle: 'Version 2.4.0',
              onTap: () => Navigator.pushNamed(context, '/about'),
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
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.error(context), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.error(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textSecondary(context),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary(context),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary(context),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
