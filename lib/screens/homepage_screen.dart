import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';
import '../models/log.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllLogs;

  const HomeScreen({super.key, this.onViewAllLogs});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Log> _recentLogs = [];
  int _totalCount = 0;
  int _unknownVisitors = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // Weekly data
  int _weeklyTotalCount = 0;
  int _weeklyUnknownVisitors = 0;
  bool _isLoadingWeekly = true;

  // Camera status
  bool _isCameraOnline = false;
  String _cameraSource = '';
  bool _isLoadingCamera = true;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    _loadWeeklyData();
    _loadCameraStatus();
  }

  Future<void> _loadTodayData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ServiceLocator.logService.getTodayLogs();
      // Sort logs by timestamp descending (newest first)
      final sortedLogs = List<Log>.from(response.data)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {
        _recentLogs = sortedLogs.take(2).toList();
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

  Future<void> _loadWeeklyData() async {
    setState(() {
      _isLoadingWeekly = true;
    });

    try {
      // Calculate date range for this week (Monday to today)
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final startDate =
          '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      final endDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final response =
          await ServiceLocator.logService.getLogsByRange(startDate, endDate);
      setState(() {
        _weeklyTotalCount = response.count;
        _weeklyUnknownVisitors = response.unknownVisitors;
        _isLoadingWeekly = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWeekly = false;
      });
    }
  }

  Future<void> _loadCameraStatus() async {
    setState(() {
      _isLoadingCamera = true;
    });

    try {
      final response = await ServiceLocator.apiService.get(
        '/api/camera/status',
        requiresAuth: true,
      );
      if (mounted) {
        final status = response['status'] ?? {};
        final config = response['config'] ?? {};
        setState(() {
          _isCameraOnline = status['is_running'] ?? false;
          _cameraSource = config['source_type'] ?? '';
          _isLoadingCamera = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraOnline = false;
          _isLoadingCamera = false;
        });
      }
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadTodayData(),
      _loadWeeklyData(),
      _loadCameraStatus(),
    ]);
  }

  // Widget Helper untuk Progress Bar Custom
  Widget _buildProgressBar(
      BuildContext context, double percentage, Color color) {
    return Container(
      height: 6,
      width: 100, // Lebar fixed agar rapi seperti desain
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.background(
            context), // Menggunakan warna background tema untuk track
        borderRadius: BorderRadius.circular(100),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Kartu Statistik
  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String leftValue,
    required String leftLabel,
    required double leftProgress,
    required String rightValue,
    required String rightLabel,
    required double rightProgress,
    required Widget footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary(context), // Agak abu-abu
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Kiri (Total)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leftValue,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    _buildProgressBar(
                        context, leftProgress, AppColors.primary(context)),
                    Text(
                      leftLabel,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Kolom Kanan (Alerts)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rightValue,
                      style: TextStyle(
                        color: AppColors.error(context), // Merah dari tema
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildProgressBar(
                          context, rightProgress, AppColors.error(context)),
                    ),
                    Text(
                      rightLabel,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: AppColors.divider(context), height: 1),
          const SizedBox(height: 16),
          footer,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(
          context), // Pastikan background abu muda/sesuai tema
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Home',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary(context)),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Daily Summary Card
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSummaryCard(
                      context: context,
                      title: 'Daily Summary',
                      leftValue: '$_totalCount',
                      leftLabel: 'Total Detections',
                      leftProgress: 0.7, // Logika dummy untuk progress bar
                      rightValue: '$_unknownVisitors',
                      rightLabel: 'Unknown Alerts',
                      rightProgress:
                          _totalCount > 0 ? _unknownVisitors / _totalCount : 0,
                      footer: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isLoadingCamera
                                ? 'Checking...'
                                : _isCameraOnline
                                    ? 'Camera Online${_cameraSource.isNotEmpty ? ' ($_cameraSource)' : ''}'
                                    : 'Camera Offline',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              color: _isLoadingCamera
                                  ? Colors.grey
                                  : _isCameraOnline
                                      ? Colors.green
                                      : Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _isLoadingCamera
                                      ? Colors.grey.withOpacity(0.5)
                                      : _isCameraOnline
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

              const SizedBox(height: 16),

              // 2. Summary This Week Card
              _isLoadingWeekly
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : _buildSummaryCard(
                      context: context,
                      title: 'Summary this Week',
                      leftValue: '$_weeklyTotalCount',
                      leftLabel: 'Total Detections',
                      leftProgress: _weeklyTotalCount > 0
                          ? (_weeklyTotalCount / 500).clamp(0.0, 1.0)
                          : 0,
                      rightValue: '$_weeklyUnknownVisitors',
                      rightLabel: 'Unknown Alerts',
                      rightProgress: _weeklyTotalCount > 0
                          ? _weeklyUnknownVisitors / _weeklyTotalCount
                          : 0,
                      footer: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Avg. ${_weeklyTotalCount > 0 ? (_weeklyTotalCount / DateTime.now().weekday).round() : 0} Events/Day',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            _weeklyTotalCount > _totalCount
                                ? Icons.trending_up
                                : Icons.trending_flat,
                            color: AppColors.textSecondary(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ),

              const SizedBox(height: 32),

              // 3. Latest Activity Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Activity',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onViewAllLogs?.call();
                    },
                    child: Text(
                      'VIEW ALL',
                      style: TextStyle(
                        color: AppColors.primary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 8),

              // 4. Latest Activity List Items
              if (_isLoading)
                const SizedBox() // Loading sudah ditangani di atas
              else if (_errorMessage != null)
                Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: AppColors.error(context)),
                  ),
                )
              else if (_recentLogs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No activity today',
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                  ),
                )
              else
                ..._recentLogs.map((log) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors
                              .transparent, // Bisa diganti highlight kalau di-tap
                        ),
                      ),
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
                            // Icon Container (Keeping Logic: Check/Cancel)
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: log.authorized
                                    ? Colors.green
                                        .withOpacity(0.1) // Green-100-ish
                                    : Colors.red
                                        .withOpacity(0.1), // Red-100-ish
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                log.authorized
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: log.authorized
                                    ? Colors.green // Green-500
                                    : AppColors.error(context), // Red-500/Error
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row Header: Name + Time
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          log.name,
                                          style: TextStyle(
                                            color:
                                                AppColors.textPrimary(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        log.timestamp.length >= 16
                                            ? log.timestamp.substring(11, 16)
                                            : log.timestamp,
                                        style: TextStyle(
                                          color:
                                              AppColors.textSecondary(context),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Status Text
                                  Text(
                                    log.authorized
                                        ? 'Access Granted'
                                        : 'Access Denied',
                                    style: TextStyle(
                                      color: AppColors.textSecondary(context),
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Chevron Right
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary(context),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
