import 'package:flutter/material.dart';
import '../constants/colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<FaqItem> _faqItems = [
    FaqItem(
      question: 'How does Face Locker work?',
      answer:
          'Face Locker uses advanced facial recognition technology to identify authorized users. When someone approaches the door, the camera captures their face and compares it with registered faces in the database. If a match is found, access is granted automatically.',
    ),
    FaqItem(
      question: 'How do I register a new face?',
      answer:
          'To register a new face, go to the web dashboard and navigate to "Face Management". Click "Add New Face", enter the person\'s name, and follow the instructions to capture their face from multiple angles for better accuracy.',
    ),
    FaqItem(
      question: 'Why am I getting "Access Denied" notifications?',
      answer:
          'Access Denied notifications occur when an unrecognized face is detected. This could be a visitor, delivery person, or someone whose face hasn\'t been registered yet. Check the access logs to see the captured image.',
    ),
    FaqItem(
      question: 'Can I use the app without internet?',
      answer:
          'The app requires an internet connection to communicate with the Face Locker device and receive real-time notifications. However, the device itself can work offline and will sync logs when connection is restored.',
    ),
    FaqItem(
      question: 'How secure is my facial data?',
      answer:
          'Your facial data is encrypted and stored securely. We use industry-standard encryption protocols and never share your biometric data with third parties. All data transmission is protected with SSL/TLS encryption.',
    ),
    FaqItem(
      question: 'What happens if the camera doesn\'t recognize me?',
      answer:
          'If the camera fails to recognize you, try adjusting your position, ensuring good lighting, or removing any obstructions like sunglasses or hats. You can also use the manual unlock option from the app if needed.',
    ),
    FaqItem(
      question: 'How do I change notification settings?',
      answer:
          'Go to Settings in the app and toggle "Push Notifications" on or off. You can also customize notification preferences in your device\'s system settings for more granular control.',
    ),
    FaqItem(
      question: 'Can multiple users access the same device?',
      answer:
          'Yes! You can register multiple faces for the same device. Each registered user will have their own access privileges and their entries will be logged separately for security tracking.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FAQ',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary(context),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find answers to common questions',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // FAQ Items
          ..._faqItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildFaqTile(context, item, index);
          }),

          const SizedBox(height: 24),

          // Still have questions?
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.textSecondary(context),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Still have questions?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact our support team for help',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/contact-support');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFaqTile(BuildContext context, FaqItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          title: Text(
            item.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          iconColor: AppColors.textSecondary(context),
          collapsedIconColor: AppColors.textSecondary(context),
          children: [
            Text(
              item.answer,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}
