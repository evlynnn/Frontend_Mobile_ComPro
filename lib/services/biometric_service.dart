import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Check if biometrics are available (enrolled)
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Check if biometric is available on this device
  Future<bool> isBiometricAvailable() async {
    final isSupported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    final biometrics = await getAvailableBiometrics();
    return isSupported && canCheck && biometrics.isNotEmpty;
  }

  /// Get friendly name for available biometric type
  Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.strong)) {
      return 'Biometric';
    }
    return 'Biometric';
  }

  /// Authenticate user with biometric
  Future<bool> authenticate({String? reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to access Face Locker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Check if user has enabled biometric login
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable or disable biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  /// Enable biometric with authentication verification
  Future<bool> enableBiometric() async {
    // First verify user can authenticate
    final authenticated = await authenticate(
      reason: 'Verify your identity to enable biometric login',
    );

    if (authenticated) {
      await setBiometricEnabled(true);
      return true;
    }
    return false;
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    await setBiometricEnabled(false);
  }
}
