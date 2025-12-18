# Face Locker Mobile

Aplikasi mobile Flutter untuk sistem Face Locker - sistem keamanan berbasis pengenalan wajah.

## Fitur

- **Autentikasi** - Login, Register, Forgot Password, OTP Verification
- **Dashboard** - Homepage dengan status sistem
- **Access Logs** - Riwayat akses dengan detail
- **Notifikasi** - Push notification via Firebase Cloud Messaging
- **Pengaturan** - App settings, Profile, Theme
- **Keamanan** - Biometric authentication support

## Tech Stack

- **Framework**: Flutter 3.5+
- **State Management**: Provider
- **Backend**: REST API
- **Push Notification**: Firebase Cloud Messaging
- **Local Storage**: SharedPreferences, Flutter Secure Storage
- **Biometric**: local_auth

## Setup

### 1. Clone repository

```bash
git clone <repository-url>
cd face_locker_mobile
```

### 2. Setup Environment

Copy `.env.example` ke `.env` dan isi dengan konfigurasi yang sesuai:

```bash
cp .env.example .env
```

### 3. Setup Firebase

1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Download `google-services.json` dan letakkan di `android/app/`
3. Download `GoogleService-Info.plist` dan letakkan di `ios/Runner/`
4. Update nilai Firebase di file `.env`

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run App

```bash
flutter run
```

## Struktur Project

```
lib/
├── constants/      # Warna, konstanta
├── models/         # Data models
├── painters/       # Custom painters (FaceGuidePainter, dll)
├── screens/        # UI screens
├── services/       # API, Auth, Notification services
├── widgets/        # Reusable UI components
│   ├── access_logs/    # Widgets untuk Access Logs screen
│   │   ├── log_item_widget.dart
│   │   ├── log_filter_widgets.dart
│   │   ├── log_export_sheet.dart
│   │   ├── log_stats_card.dart
│   │   └── log_empty_state.dart
│   └── face_enroll/    # Widgets untuk Face Enroll screen
│       ├── enroll_capture_view.dart
│       ├── enroll_preview_view.dart
│       ├── enroll_upload_view.dart
│       └── enroll_result_view.dart
├── firebase_options.dart
└── main.dart
```

## Environment Variables

Lihat `.env.example` untuk daftar environment variables yang diperlukan.
