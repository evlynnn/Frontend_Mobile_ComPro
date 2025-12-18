import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../constants/colors.dart';
import '../../painters/face_guide_painter.dart';

class EnrollCaptureView extends StatelessWidget {
  final CameraController? cameraController;
  final bool isCameraInitialized;
  final String? errorMessage;
  final int currentCapture;
  final int totalCaptures;
  final VoidCallback onCapture;
  final String captureInstruction;

  const EnrollCaptureView({
    super.key,
    required this.cameraController,
    required this.isCameraInitialized,
    required this.errorMessage,
    required this.currentCapture,
    required this.totalCaptures,
    required this.onCapture,
    required this.captureInstruction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera Preview
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera or placeholder
                  if (isCameraInitialized && cameraController != null)
                    CameraPreview(cameraController!)
                  else
                    Container(
                      color: AppColors.surface(context),
                      child: Center(
                        child: errorMessage != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.error(context),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: AppColors.textSecondary(context),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : const CircularProgressIndicator(),
                      ),
                    ),

                  // Face guide overlay
                  CustomPaint(
                    painter: FaceGuidePainter(
                      color: AppColors.primary(context).withOpacity(0.5),
                    ),
                  ),

                  // Capture counter
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Capture ${currentCapture + 1} of $totalCaptures',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Captured indicators
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(totalCaptures, (index) {
                        return Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < currentCapture
                                ? AppColors.success(context)
                                : Colors.white.withOpacity(0.5),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                captureInstruction,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Make sure your face is clearly visible',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Tips
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              _buildTip(context, Icons.visibility, 'Look Straight'),
              const SizedBox(width: 12),
              _buildTip(context, Icons.light_mode, 'Good Light'),
              const SizedBox(width: 12),
              _buildTip(context, Icons.face, 'No Glasses'),
            ],
          ),
        ),

        // Capture Button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isCameraInitialized ? onCapture : null,
              icon: const Icon(Icons.camera),
              label: const Text(
                'Capture',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColorsLight.stroke,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary(context),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
