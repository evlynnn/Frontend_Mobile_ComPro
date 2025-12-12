# API Services Documentation

Complete implementation of API services based on the backend OpenAPI specification.

## 📁 Structure

```
lib/
├── models/
│   ├── user.dart          # User models & DTOs
│   └── log.dart           # Log models & DTOs
├── services/
│   ├── api_service.dart   # Base HTTP client
│   ├── auth_service.dart  # Authentication operations
│   ├── log_service.dart   # Log operations
│   ├── service_locator.dart     # Service dependency injection
│   └── service_usage_example.dart # Usage examples (reference only)
```

## 🚀 Quick Start

### 1. Setup in main.dart

```dart
import 'package:face_locker_mobile/services/service_locator.dart';

void main() {
  // Initialize services before running app
  ServiceLocator.setup();
  
  runApp(const MyApp());
}
```

### 2. Access Services Anywhere

```dart
// Get service instances
final authService = ServiceLocator.authService;
final logService = ServiceLocator.logService;
```

## 🔐 Authentication Examples

### Register

```dart
try {
  final request = UserRegisterRequest(
    username: 'johndoe',
    password: 'password123',
    confirmPassword: 'password123',
  );

  final response = await ServiceLocator.authService.register(request);
  print('User registered: ${response.data.username}');
} catch (e) {
  print('Error: $e');
}
```

### Login

```dart
try {
  final request = UserLoginRequest(
    username: 'johndoe',
    password: 'password123',
  );

  final response = await ServiceLocator.authService.login(request);
  // Token is automatically saved
  print('Token: ${response.token}');
  print('User: ${response.data.username}');
} catch (e) {
  print('Error: $e');
}
```

### Logout

```dart
await ServiceLocator.authService.logout();
// Token is automatically cleared
```

### Check Auth Status

```dart
bool isLoggedIn = ServiceLocator.authService.isLoggedIn();
String? token = ServiceLocator.authService.getToken();
```

## 📋 Log Examples

### Get All Logs

```dart
final response = await ServiceLocator.logService.getAllLogs();
print('Total logs: ${response.data.length}');
```

### Get Today's Logs with Stats

```dart
final response = await ServiceLocator.logService.getTodayLogs();
print('Count: ${response.count}');
print('Unknown visitors: ${response.unknownVisitors}');

for (var log in response.data) {
  print('${log.name}: ${log.authorized ? "✓" : "✗"}');
}
```

### Get Logs by Date

```dart
// Specific date
final response = await ServiceLocator.logService.getLogsByDate('2025-12-12');

// Date range
final response = await ServiceLocator.logService.getLogsByRange(
  '2025-12-01',
  '2025-12-10',
);

// By name
final response = await ServiceLocator.logService.getLogsByName('John');
```

### Create Log

```dart
final logCreate = LogCreate(
  authorized: false,
  confidence: 0.91,
  name: 'Unknown',
  role: 'Guest',
  timestamp: DateTime.now().toIso8601String(),
);

final log = await ServiceLocator.logService.createLog(logCreate);
print('Created log ID: ${log.id}');
```

### Delete Log

```dart
await ServiceLocator.logService.deleteLog(logId);
```

## 🎯 Widget Integration Example

### Login Screen

```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = UserLoginRequest(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      await ServiceLocator.authService.login(request);
      
      // Navigate to home on success
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      child: _isLoading 
        ? CircularProgressIndicator()
        : Text('Login'),
    );
  }
}
```

### Logs List Screen

```dart
class LogsListScreen extends StatefulWidget {
  @override
  State<LogsListScreen> createState() => _LogsListScreenState();
}

class _LogsListScreenState extends State<LogsListScreen> {
  List<Log>? _logs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await ServiceLocator.logService.getTodayLogs();
      setState(() {
        _logs = response.data;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();
    
    return ListView.builder(
      itemCount: _logs?.length ?? 0,
      itemBuilder: (context, index) {
        final log = _logs![index];
        return ListTile(
          title: Text(log.name),
          subtitle: Text(log.timestamp),
          trailing: Icon(
            log.authorized ? Icons.check : Icons.warning,
          ),
        );
      },
    );
  }
}
```

## 🔧 Advanced Usage

### Custom API Configuration

Edit `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://your-api-url:8080';
```

### Error Handling

All services throw `ApiException` on error:

```dart
try {
  await ServiceLocator.authService.login(request);
} on ApiException catch (e) {
  print('Status: ${e.statusCode}');
  print('Message: ${e.message}');
} catch (e) {
  print('Unknown error: $e');
}
```

### Manual Token Management

```dart
// Get token
String? token = ServiceLocator.authService.getToken();

// Manually set token (if needed)
ServiceLocator.apiService.setToken('your-token');

// Clear token
ServiceLocator.apiService.clearToken();
```

## 📝 Models Reference

### User Models

- `User` - User entity
- `UserRegisterRequest` - Registration data
- `UserLoginRequest` - Login credentials
- `LoginResponse` - Login result with token
- `UserResponse` - User operation result

### Log Models

- `Log` - Log entry entity
- `LogCreate` - Create log data
- `LogsResponse` - List of logs
- `LogStatsResponse` - Logs with statistics
- `LogFilterParams` - Filter parameters
- `LogFilterPeriod` - Filter period enum (today, date, range)

## 🛠️ Backend API Endpoints

### Auth
- `POST /api/users/register` - Register
- `POST /api/users/login` - Login
- `POST /api/users/logout` - Logout

### Logs (JWT Required)
- `GET /api/logs` - Get all logs
- `GET /api/logs/filter` - Get filtered logs
- `POST /api/logs` - Create log
- `DELETE /api/logs/{id}` - Delete log

## 📦 Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0
```

## ⚠️ Important Notes

1. **ServiceLocator.setup()** must be called before using any service
2. Token is automatically managed by AuthService
3. All log operations require authentication
4. Date format: `YYYY-MM-DD` (e.g., `2025-12-12`)
5. Timestamp format: ISO 8601 (e.g., `2025-12-12T06:22:27`)

## 🔍 Testing

Use the example file for testing:

```dart
import 'package:face_locker_mobile/services/service_usage_example.dart';

// In your test widget
ServiceUsageExample.exampleLogin();
ServiceUsageExample.exampleGetTodayLogs();
```

## 📚 Full Examples

See `lib/services/service_usage_example.dart` for:
- Complete auth flow
- All log operations
- Widget integration examples
- Error handling patterns

---

Made with ❤️ for Face Locker Mobile
