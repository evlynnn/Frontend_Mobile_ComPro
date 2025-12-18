import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class EnrollSuccessView extends StatelessWidget {
  final bool isAddSampleMode;
  final VoidCallback onDone;

  const EnrollSuccessView({
    super.key,
    required this.isAddSampleMode,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Success icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success(context).withOpacity(0.1),
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.success(context),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Upload Complete',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isAddSampleMode
                  ? 'Face sample has been added successfully.'
                  : 'User has been enrolled successfully.',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Security badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 18,
                    color: AppColors.success(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'End-to-end Encrypted',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColorsLight.stroke,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class EnrollFailedView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const EnrollFailedView({
    super.key,
    required this.errorMessage,
    required this.onClose,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.textPrimary(context),
                ),
                onPressed: onClose,
              ),
            ),

            const Spacer(),

            // Error icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error(context).withOpacity(0.1),
              ),
              child: Icon(
                Icons.error,
                size: 80,
                color: AppColors.error(context),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Upload Failed',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage ?? 'An error occurred. Please try again.',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lighting Check',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Avoid backlighting or shadows',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColorsLight.stroke,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
