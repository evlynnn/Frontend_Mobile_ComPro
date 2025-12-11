import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors
                          .transparent, // hover:bg-white/10 handled by InkWell usually
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 24,
                        color: Colors.white,
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
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connect your smart lock system and secure your home.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9CA3AF), // gray-400
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
                            activeColor: const Color(0xFF137FEC),
                            side: const BorderSide(
                                color: Color(0xFF4B5563),
                                width: 1.5), // gray-600
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
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF), // gray-400
                                height: 1.4,
                                fontFamily: 'Inter',
                              ),
                              children: [
                                TextSpan(
                                    text:
                                        'By creating an account, you agree to our '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Color(0xFF137FEC), // Primary
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF137FEC), // Primary
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(text: '.'),
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
                            color: const Color(0xFF3B82F6)
                                .withOpacity(0.2), // blue-500/20
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
                          backgroundColor: const Color(0xFF137FEC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(9999), // rounded-full
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
                      children: const [
                        Expanded(
                            child:
                                Divider(color: Color(0xFF374151))), // gray-700
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: Color(0xFF6B7280), // gray-500
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFF374151))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 9. Google Button
                    SizedBox(
                      width: double.infinity,
                      height: 54, // py-3.5 roughly
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1F2937), // bg-gray-800
                          side: const BorderSide(
                              color: Color(0xFF374151)), // border-gray-700
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // rounded-xl
                          ),
                          foregroundColor: Colors.white,
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
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF), // gray-400
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Color(0xFF137FEC), // Primary
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
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
        color: const Color(0xFF1F2937), // bg-gray-800
        borderRadius: BorderRadius.circular(12), // rounded-xl
        border: Border.all(color: const Color(0xFF374151)), // border-gray-700
      ),
      child: TextField(
        obscureText: obscureText,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF6B7280)), // gray-500
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16), // h-14 approx
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF9CA3AF), // gray-400
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
          color: const Color(0xFF374151), // gray-700
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
