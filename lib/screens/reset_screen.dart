import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Header
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      color: AppColors.primary(context),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title & Description
                  Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure your account by creating a new strong password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.disabled(context),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // New Password Input
                  _buildLabel('New Password'),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    hintText: 'Enter new password',
                    obscureText: _obscureNewPass,
                    onToggle: () =>
                        setState(() => _obscureNewPass = !_obscureNewPass),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Input
                  _buildLabel('Confirm New Password'),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    hintText: 'Confirm new password',
                    obscureText: _obscureConfirmPass,
                    icon: Icons.lock_clock_outlined, // To match HTML lock_clock
                    onToggle: () => setState(
                        () => _obscureConfirmPass = !_obscureConfirmPass),
                  ),

                  const SizedBox(height: 12),
                  // Help Text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password must be at least 8 characters long and include numbers and special characters.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.disabled(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        foregroundColor:
                            isDark ? Colors.white : AppColorsLight.stroke,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Back to Login
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back,
                            size: 18, color: AppColors.disabled(context)),
                        const SizedBox(width: 8),
                        Text(
                          'Back to Login',
                          style: TextStyle(
                            color: AppColors.disabled(context),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    IconData icon = Icons.lock_outline,
  }) {
    return TextField(
      obscureText: obscureText,
      style: TextStyle(color: AppColors.textPrimary(context)),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface(context),
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.disabled(context)),
        prefixIcon: Icon(icon, color: AppColors.disabled(context)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.disabled(context),
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.stroke(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.stroke(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary(context), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
