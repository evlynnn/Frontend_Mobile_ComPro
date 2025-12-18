import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class EnrollUploadView extends StatelessWidget {
  final double uploadProgress;
  final String uploadStatus;

  const EnrollUploadView({
    super.key,
    required this.uploadProgress,
    required this.uploadStatus,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Progress circle
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: uploadProgress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.divider(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary(context),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 48,
                          color: AppColors.primary(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(uploadProgress * 100).toInt()}%',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Uploading Face Data...',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              uploadStatus,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
            ),

            const Spacer(),

            // Progress steps
            _buildProgressStep(
                context, 'Processing facial features', uploadProgress >= 0.3),
            const SizedBox(height: 12),
            _buildProgressStep(
                context, 'Encrypting biometric data', uploadProgress >= 0.6),
            const SizedBox(height: 12),
            _buildProgressStep(
                context, 'Syncing with smart lock', uploadProgress >= 1.0),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(
      BuildContext context, String label, bool completed) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed
                ? AppColors.primary(context)
                : AppColors.surface(context),
            border: Border.all(
              color: completed
                  ? AppColors.primary(context)
                  : AppColors.divider(context),
              width: 2,
            ),
          ),
          child: completed
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: completed
                ? AppColors.textPrimary(context)
                : AppColors.textSecondary(context),
            fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
