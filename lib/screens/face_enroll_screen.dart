import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';

class FaceEnrollScreen extends StatefulWidget {
  const FaceEnrollScreen({super.key});

  @override
  State<FaceEnrollScreen> createState() => _FaceEnrollScreenState();
}

class _FaceEnrollScreenState extends State<FaceEnrollScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = true;

  // Enrollment state
  EnrollmentState _state = EnrollmentState.capturing;
  List<String> _capturedImages = [];
  int _currentCapture = 0;
  static const int _totalCaptures = 3;

  // Form data
  final _nameController = TextEditingController();
  String _selectedRole = 'Guest';
  final List<String> _roles = ['Aslab', 'Dosen'];

  // For add sample mode
  bool _isAddSampleMode = false;
  String? _existingUserName;

  // Upload progress
  double _uploadProgress = 0;
  String _uploadStatus = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we're in add sample mode
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      if (args['mode'] == 'add_sample' && args['name'] != null) {
        _isAddSampleMode = true;
        _existingUserName = args['name'];
        _nameController.text = args['name'];
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Find front camera
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );
        await _setupCamera(frontCamera);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _cameraController?.dispose();
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to setup camera: $e';
        });
      }
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false;
    });

    final newCamera = _cameras!.firstWhere(
      (camera) =>
          camera.lensDirection ==
          (_isFrontCamera
              ? CameraLensDirection.front
              : CameraLensDirection.back),
      orElse: () => _cameras!.first,
    );

    await _setupCamera(newCamera);
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _capturedImages.add(base64Image);
        _currentCapture++;

        if (_currentCapture >= _totalCaptures) {
          _state = EnrollmentState.preview;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture: $e'),
            backgroundColor: AppColors.error(context),
          ),
        );
      }
    }
  }

  void _retakeCaptures() {
    setState(() {
      _capturedImages.clear();
      _currentCapture = 0;
      _state = EnrollmentState.capturing;
    });
  }

  Future<void> _submitEnrollment() async {
    if (!_isAddSampleMode && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a name'),
          backgroundColor: AppColors.error(context),
        ),
      );
      return;
    }

    setState(() {
      _state = EnrollmentState.uploading;
      _uploadProgress = 0;
      _uploadStatus = 'Processing facial features...';
    });

    try {
      // Simulate progress steps
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _uploadProgress = 0.3;
        _uploadStatus = 'Encrypting biometric data...';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _uploadProgress = 0.6;
        _uploadStatus = 'Syncing with smart lock...';
      });

      // Actual API call
      if (_isAddSampleMode && _existingUserName != null) {
        // Add sample to existing user (only first image for add sample)
        await ServiceLocator.faceUserService.addSample(
          name: _existingUserName!,
          image: _capturedImages.first,
        );
      } else {
        // Enroll new user with all images
        await ServiceLocator.faceUserService.enrollUser(
          name: _nameController.text.trim(),
          images: _capturedImages,
          role: _selectedRole,
        );
      }

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = 'Complete!';
        _state = EnrollmentState.success;
      });
    } catch (e) {
      setState(() {
        _state = EnrollmentState.failed;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _state == EnrollmentState.uploading
          ? null
          : AppBar(
              backgroundColor: AppColors.background(context),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary(context),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: Text(
                _isAddSampleMode ? 'Add Face Sample' : 'Add Face Data',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                if (_state == EnrollmentState.capturing &&
                    _cameras != null &&
                    _cameras!.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.flip_camera_ios,
                      color: AppColors.textPrimary(context),
                    ),
                    onPressed: _switchCamera,
                  ),
              ],
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case EnrollmentState.capturing:
        return _buildCapturingView();
      case EnrollmentState.preview:
        return _buildPreviewView();
      case EnrollmentState.uploading:
        return _buildUploadingView();
      case EnrollmentState.success:
        return _buildSuccessView();
      case EnrollmentState.failed:
        return _buildFailedView();
    }
  }

  Widget _buildCapturingView() {
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
                  if (_isCameraInitialized && _cameraController != null)
                    CameraPreview(_cameraController!)
                  else
                    Container(
                      color: AppColors.surface(context),
                      child: Center(
                        child: _errorMessage != null
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
                                    _errorMessage!,
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
                          'Capture ${_currentCapture + 1} of $_totalCaptures',
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
                      children: List.generate(_totalCaptures, (index) {
                        return Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _currentCapture
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
                _getCaptureInstruction(),
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
              _buildTip(Icons.visibility, 'Look Straight'),
              const SizedBox(width: 12),
              _buildTip(Icons.light_mode, 'Good Light'),
              const SizedBox(width: 12),
              _buildTip(Icons.face, 'No Glasses'),
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
              onPressed: _isCameraInitialized ? _captureImage : null,
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

  String _getCaptureInstruction() {
    switch (_currentCapture) {
      case 0:
        return 'Look straight at the camera';
      case 1:
        return 'Turn your head slightly left';
      case 2:
        return 'Turn your head slightly right';
      default:
        return 'Position your face';
    }
  }

  Widget _buildTip(IconData icon, String label) {
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

  Widget _buildPreviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Captured images preview
          Text(
            'Captured Photos',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _capturedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final base64Image = entry.value;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary(context),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(base64Image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _retakeCaptures,
            icon: Icon(Icons.refresh, color: AppColors.primary(context)),
            label: Text(
              'Retake Photos',
              style: TextStyle(color: AppColors.primary(context)),
            ),
          ),

          const SizedBox(height: 24),

          // User info form (only for new enrollment)
          if (!_isAddSampleMode) ...[
            Text(
              'User Information',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Name field
            TextField(
              controller: _nameController,
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: AppColors.textSecondary(context)),
                hintText: 'Enter user name',
                hintStyle: TextStyle(color: AppColors.disabled(context)),
                filled: true,
                fillColor: AppColors.surface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary(context),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Role dropdown
            DropdownButtonFormField<String>(
              value: _selectedRole,
              dropdownColor: AppColors.surface(context),
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: 'Role',
                labelStyle: TextStyle(color: AppColors.textSecondary(context)),
                filled: true,
                fillColor: AppColors.surface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Adding sample for: $_existingUserName',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitEnrollment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColorsLight.stroke,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isAddSampleMode ? 'Add Sample' : 'Enroll User',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingView() {
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
                    value: _uploadProgress,
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
                          '${(_uploadProgress * 100).toInt()}%',
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
              _uploadStatus,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
            ),

            const Spacer(),

            // Progress steps
            _buildProgressStep(
                'Processing facial features', _uploadProgress >= 0.3),
            const SizedBox(height: 12),
            _buildProgressStep(
                'Encrypting biometric data', _uploadProgress >= 0.6),
            const SizedBox(height: 12),
            _buildProgressStep(
                'Syncing with smart lock', _uploadProgress >= 1.0),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(String label, bool completed) {
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

  Widget _buildSuccessView() {
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
              _isAddSampleMode
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
                onPressed: () {
                  Navigator.pop(context, true);
                },
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

  Widget _buildFailedView() {
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
                onPressed: () => Navigator.pop(context),
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
                _errorMessage ?? 'An error occurred. Please try again.',
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
                onPressed: () {
                  setState(() {
                    _state = EnrollmentState.capturing;
                    _capturedImages.clear();
                    _currentCapture = 0;
                    _errorMessage = null;
                  });
                },
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

enum EnrollmentState {
  capturing,
  preview,
  uploading,
  success,
  failed,
}

class FaceGuidePainter extends CustomPainter {
  final Color color;

  FaceGuidePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final ovalWidth = size.width * 0.7;
    final ovalHeight = size.height * 0.5;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Draw dashed oval
    final path = Path()..addOval(rect);

    // Draw corner guides
    final guideLength = 30.0;
    final guideOffset = 20.0;

    // Top-left
    canvas.drawLine(
      Offset(centerX - ovalWidth / 2 + guideOffset, centerY - ovalHeight / 2),
      Offset(centerX - ovalWidth / 2 + guideOffset + guideLength,
          centerY - ovalHeight / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - ovalWidth / 2, centerY - ovalHeight / 2 + guideOffset),
      Offset(centerX - ovalWidth / 2,
          centerY - ovalHeight / 2 + guideOffset + guideLength),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(centerX + ovalWidth / 2 - guideOffset, centerY - ovalHeight / 2),
      Offset(centerX + ovalWidth / 2 - guideOffset - guideLength,
          centerY - ovalHeight / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + ovalWidth / 2, centerY - ovalHeight / 2 + guideOffset),
      Offset(centerX + ovalWidth / 2,
          centerY - ovalHeight / 2 + guideOffset + guideLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(centerX - ovalWidth / 2 + guideOffset, centerY + ovalHeight / 2),
      Offset(centerX - ovalWidth / 2 + guideOffset + guideLength,
          centerY + ovalHeight / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - ovalWidth / 2, centerY + ovalHeight / 2 - guideOffset),
      Offset(centerX - ovalWidth / 2,
          centerY + ovalHeight / 2 - guideOffset - guideLength),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(centerX + ovalWidth / 2 - guideOffset, centerY + ovalHeight / 2),
      Offset(centerX + ovalWidth / 2 - guideOffset - guideLength,
          centerY + ovalHeight / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + ovalWidth / 2, centerY + ovalHeight / 2 - guideOffset),
      Offset(centerX + ovalWidth / 2,
          centerY + ovalHeight / 2 - guideOffset - guideLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
