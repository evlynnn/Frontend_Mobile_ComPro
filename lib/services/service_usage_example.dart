/// Example Usage of Services
///
/// This file demonstrates how to use the API services in your Flutter app.
/// DO NOT include this file in production - it's for reference only.

import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../models/user.dart';
import '../models/log.dart';

class ServiceUsageExample {
  /// ============================================
  /// 1. SETUP - Call this in main.dart
  /// ============================================
  static void setupServices() {
    ServiceLocator.setup();
  }

  /// ============================================
  /// 2. AUTHENTICATION EXAMPLES
  /// ============================================

  // Register new user
  static Future<void> exampleRegister() async {
    try {
      final request = UserRegisterRequest(
        username: 'johndoe',
        password: 'password123',
        confirmPassword: 'password123',
      );

      final response = await ServiceLocator.authService.register(request);
      print('User registered: ${response.data.username}');
      print('Message: ${response.message}');
    } catch (e) {
      print('Registration error: $e');
    }
  }

  // Login user
  static Future<void> exampleLogin() async {
    try {
      final request = UserLoginRequest(
        username: 'johndoe',
        password: 'password123',
      );

      final response = await ServiceLocator.authService.login(request);
      print('Login successful!');
      print('Token: ${response.token}');
      print('User: ${response.data.username}');
      print('Role: ${response.data.role}');

      // Token is automatically saved in ApiService
    } catch (e) {
      print('Login error: $e');
    }
  }

  // Logout user
  static Future<void> exampleLogout() async {
    try {
      await ServiceLocator.authService.logout();
      print('Logged out successfully');

      // Token is automatically cleared from ApiService
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Check if logged in
  static void exampleCheckAuth() {
    final isLoggedIn = ServiceLocator.authService.isLoggedIn();
    print('Is logged in: $isLoggedIn');

    final token = ServiceLocator.authService.getToken();
    print('Current token: $token');
  }

  /// ============================================
  /// 3. LOG EXAMPLES
  /// ============================================

  // Get all logs
  static Future<void> exampleGetAllLogs() async {
    try {
      final response = await ServiceLocator.logService.getAllLogs();
      print('Total logs: ${response.data.length}');

      for (var log in response.data) {
        print('Log #${log.id}: ${log.name} - ${log.role}');
      }
    } catch (e) {
      print('Get logs error: $e');
    }
  }

  // Get today's logs with stats
  static Future<void> exampleGetTodayLogs() async {
    try {
      final response = await ServiceLocator.logService.getTodayLogs();
      print('Today\'s logs: ${response.count}');
      print('Unknown visitors: ${response.unknownVisitors}');

      for (var log in response.data) {
        print(
            '${log.timestamp}: ${log.name} (${log.authorized ? "Authorized" : "Unauthorized"})');
      }
    } catch (e) {
      print('Get today logs error: $e');
    }
  }

  // Get logs by specific date
  static Future<void> exampleGetLogsByDate() async {
    try {
      final response =
          await ServiceLocator.logService.getLogsByDate('2025-12-12');
      print('Logs on 2025-12-12: ${response.count}');
      print('Unknown visitors: ${response.unknownVisitors}');
    } catch (e) {
      print('Get logs by date error: $e');
    }
  }

  // Get logs by date range
  static Future<void> exampleGetLogsByRange() async {
    try {
      final response = await ServiceLocator.logService.getLogsByRange(
        '2025-12-01',
        '2025-12-10',
      );
      print('Logs in range: ${response.count}');
      print('Unknown visitors: ${response.unknownVisitors}');
    } catch (e) {
      print('Get logs by range error: $e');
    }
  }

  // Get logs by name
  static Future<void> exampleGetLogsByName() async {
    try {
      final response = await ServiceLocator.logService.getLogsByName('John');
      print('Logs for John: ${response.count}');
    } catch (e) {
      print('Get logs by name error: $e');
    }
  }

  // Create new log
  static Future<void> exampleCreateLog() async {
    try {
      final logCreate = LogCreate(
        authorized: false,
        confidence: 0.91,
        name: 'Unknown',
        role: 'Guest',
        timestamp: DateTime.now().toIso8601String(),
      );

      final log = await ServiceLocator.logService.createLog(logCreate);
      print('Log created with ID: ${log.id}');
    } catch (e) {
      print('Create log error: $e');
    }
  }

  // Delete log
  static Future<void> exampleDeleteLog(int logId) async {
    try {
      await ServiceLocator.logService.deleteLog(logId);
      print('Log $logId deleted successfully');
    } catch (e) {
      print('Delete log error: $e');
    }
  }

  /// ============================================
  /// 4. FLUTTER WIDGET EXAMPLE
  /// ============================================

  static Widget buildLoginExample() {
    return LoginExampleWidget();
  }
}

/// Example Login Widget
class LoginExampleWidget extends StatefulWidget {
  const LoginExampleWidget({super.key});

  @override
  State<LoginExampleWidget> createState() => _LoginExampleWidgetState();
}

class _LoginExampleWidgetState extends State<LoginExampleWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
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

      final response = await ServiceLocator.authService.login(request);

      // Login successful - navigate to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// Example Logs List Widget
class LogsListExampleWidget extends StatefulWidget {
  const LogsListExampleWidget({super.key});

  @override
  State<LogsListExampleWidget> createState() => _LogsListExampleWidgetState();
}

class _LogsListExampleWidgetState extends State<LogsListExampleWidget> {
  List<Log>? _logs;
  int _count = 0;
  int _unknownVisitors = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ServiceLocator.logService.getTodayLogs();
      setState(() {
        _logs = response.data;
        _count = response.count;
        _unknownVisitors = response.unknownVisitors;
      });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Logs Example')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Total: $_count'),
                          Text('Unknown: $_unknownVisitors'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _logs?.length ?? 0,
                        itemBuilder: (context, index) {
                          final log = _logs![index];
                          return ListTile(
                            leading: Icon(
                              log.authorized
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: log.authorized ? Colors.green : Colors.red,
                            ),
                            title: Text(log.name),
                            subtitle: Text('${log.role} - ${log.timestamp}'),
                            trailing: Text(
                                '${(log.confidence * 100).toStringAsFixed(0)}%'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
