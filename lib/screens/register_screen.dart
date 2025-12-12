import 'package:flutter/material.dart';
import '../constants/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar (Back Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 24,
                        color: AppColors.darker(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Header
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darker(context),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect your smart lock system and secure your home.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.disabled(context),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. Email Address
                    _buildLabel('Email Address'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'name@example.com',
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // 4. Password
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Min. 8 characters',
                      obscureText: _obscurePassword,
                      isPassword: true,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    // Password Strength Indicator
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                      child: Row(
                        children: [
                          _buildStrengthBar(),
                          const SizedBox(width: 6),
                          _buildStrengthBar(),
                          const SizedBox(width: 6),
                          _buildStrengthBar(),
                          const SizedBox(width: 6),
                          _buildStrengthBar(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5. Confirm Password
                    _buildLabel('Confirm Password'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Re-enter password',
                      obscureText: _obscureConfirmPassword,
                      isPassword: true,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // 6. Terms Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            activeColor: AppColors.primary(context),
                            side: BorderSide(
                                color: AppColors.stroke(context), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() {
                                _agreeToTerms = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.disabled(context),
                                height: 1.4,
                                fontFamily: 'Inter',
                              ),
                              children: [
                                const TextSpan(
                                    text:
                                        'By creating an account, you agree to our '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.primary(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primary(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 7. Sign Up Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow(context),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          foregroundColor:
                              isDark ? Colors.white : AppColorsLight.stroke,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 8. Divider "Or continue with"
                    Row(
                      children: [
                        Expanded(
                            child: Divider(color: AppColors.divider(context))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: AppColors.disabled(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(color: AppColors.divider(context))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 9. Google Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.surface(context),
                          side: BorderSide(color: AppColors.stroke(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: AppColors.darker(context),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBRhyjEYPjj-6QPYzdhyBpNA0YjcurZDXUJAUvBi6lzySnO4HmDgJQg7DXM_ylQ3veGv6YgJlhHBc32yEbyJoACDSlky3Nlro8HK8eQ2LGKIUjc_w3iBaY2eEaYf94KZ-ZO4WxzWrxE-OFseRGOCxbaWOjuQv_HVUAf9dqKqAYATCvWXuC4rMPO4mAeIY--e-KzbR5uHac-G4G22AgVirPA2kShTzm4zur12hsr5TrFxlCpjQX67MQ0QVvTVkTZUr4we91U5GLHS7k',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 10. Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.disabled(context),
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.darker(context),
      ),
    );
  }

  // Helper Widget for Text Fields
  Widget _buildTextField({
    required String hintText,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke(context)),
      ),
      child: TextField(
        obscureText: obscureText,
        keyboardType: inputType,
        style: TextStyle(color: AppColors.darker(context), fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.disabled(context)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.disabled(context),
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  // Helper Widget for Password Strength Bars
  Widget _buildStrengthBar() {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.stroke(context),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
