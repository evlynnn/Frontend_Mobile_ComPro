import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';
import '../widgets/face_enroll/enroll_capture_view.dart';
import '../widgets/face_enroll/enroll_preview_view.dart';
import '../widgets/face_enroll/enroll_upload_view.dart';
import '../widgets/face_enroll/enroll_result_view.dart';

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

  Widget _buildBody() {
    switch (_state) {
      case EnrollmentState.capturing:
        return EnrollCaptureView(
          cameraController: _cameraController,
          isCameraInitialized: _isCameraInitialized,
          errorMessage: _errorMessage,
          currentCapture: _currentCapture,
          totalCaptures: _totalCaptures,
          onCapture: _captureImage,
          captureInstruction: _getCaptureInstruction(),
        );
      case EnrollmentState.preview:
        return EnrollPreviewView(
          capturedImages: _capturedImages,
          nameController: _nameController,
          selectedRole: _selectedRole,
          roles: _roles,
          isAddSampleMode: _isAddSampleMode,
          existingUserName: _existingUserName,
          onRetake: _retakeCaptures,
          onSubmit: _submitEnrollment,
          onRoleChanged: (value) => setState(() => _selectedRole = value),
        );
      case EnrollmentState.uploading:
        return EnrollUploadView(
          uploadProgress: _uploadProgress,
          uploadStatus: _uploadStatus,
        );
      case EnrollmentState.success:
        return EnrollSuccessView(
          isAddSampleMode: _isAddSampleMode,
          onDone: () => Navigator.pop(context, true),
        );
      case EnrollmentState.failed:
        return EnrollFailedView(
          errorMessage: _errorMessage,
          onClose: () => Navigator.pop(context),
          onRetry: () {
            setState(() {
              _state = EnrollmentState.capturing;
              _capturedImages.clear();
              _currentCapture = 0;
              _errorMessage = null;
            });
          },
        );
    }
  }
}

enum EnrollmentState {
  capturing,
  preview,
  uploading,
  success,
  failed,
}
