import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';
import '../models/log.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Log> _recentLogs = [];
  int _totalCount = 0;
  int _unknownVisitors = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ServiceLocator.logService.getTodayLogs();
      setState(() {
        _recentLogs = response.data.take(5).toList();
        _totalCount = response.data.length;
        _unknownVisitors = response.data.where((log) => !log.authorized).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        // Menambahkan tombol notifikasi di sebelah kanan sesuai HTML baru
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          const SizedBox(width: 8), // Sedikit jarak dari tepi kanan
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Summary Card (Updated Content)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Summary',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Total Detections Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_totalCount',
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Detections',
                                  style: TextStyle(
                                    color: AppColors.disabled(context),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            // Unknown Alerts Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$_unknownVisitors',
                                  style: TextStyle(
                                    color: AppColors.primaryDarker(context),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unknown Alerts',
                                  style: TextStyle(
                                    color: AppColors.disabled(context),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),
                  Divider(color: AppColors.divider(context), height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Device Online',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Latest Activity Header
            Text(
              'Latest Activity',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Activity Items from API
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error(context)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadTodayData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_recentLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No activity today',
                    style: TextStyle(color: AppColors.disabled(context)),
                  ),
                ),
              )
            else
              ..._recentLogs.map((log) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/log-detail',
                          arguments: log,
                        );
                      },
                      child: Row(
                        children: [
                          // Icon Container
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: log.authorized
                                  ? const Color(0xFFD1FAE5) // green-100
                                  : const Color(0xFFFEE2E2), // red-100
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              log.authorized
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: log.authorized
                                  ? const Color(0xFF10B981) // green-500
                                  : const Color(0xFFEF4444), // red-500
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.name,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  log.authorized
                                      ? 'Access Granted'
                                      : 'Access Denied',
                                  style: TextStyle(
                                    color: AppColors.disabled(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Time
                          Text(
                            log.timestamp.length >= 16
                                ? log.timestamp.substring(11, 16)
                                : log.timestamp,
                            style: TextStyle(
                              color: AppColors.disabled(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
