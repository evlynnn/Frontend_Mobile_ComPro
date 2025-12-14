import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';
import '../models/log.dart';

class AccessLogsScreen extends StatefulWidget {
  const AccessLogsScreen({super.key});

  @override
  State<AccessLogsScreen> createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends State<AccessLogsScreen> {
  final int _selectedIndex = 1; // "Logs" is selected (index 1)
  List<Log> _logs = [];
  int _totalCount = 0;
  int _unknownVisitors = 0;
  bool _isLoading = true;
  String? _errorMessage;
  LogFilterPeriod _selectedPeriod = LogFilterPeriod.today;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final params = LogFilterParams(
        period: _selectedPeriod,
        name: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      final response = await ServiceLocator.logService.getFilteredLogs(params);
      setState(() {
        _logs = response.data;
        _totalCount = response.count;
        _unknownVisitors = response.unknownVisitors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LogFilterPeriod.values.map((period) {
            return RadioListTile<LogFilterPeriod>(
              title: Text(_getPeriodLabel(period)),
              value: period,
              groupValue: _selectedPeriod,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() {
                  _selectedPeriod = value!;
                });
                _loadLogs();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getPeriodLabel(LogFilterPeriod period) {
    switch (period) {
      case LogFilterPeriod.today:
        return 'Today';
      case LogFilterPeriod.date:
        return 'Specific Date';
      case LogFilterPeriod.range:
        return 'Custom Range';
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      // Already on logs
      return;
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Logs'),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Section
          if (!_isLoading && _errorMessage == null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$_totalCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Total Logs',
                        style: TextStyle(
                          color: AppColors.disabled(context),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$_unknownVisitors',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error(context),
                        ),
                      ),
                      Text(
                        'Unknown',
                        style: TextStyle(
                          color: AppColors.disabled(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadLogs();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => _loadLogs(),
            ),
          ),

          // Filter Chips Section
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                InkWell(
                  onTap: _showFilterDialog,
                  child: Container(
                    height: 32,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getPeriodLabel(_selectedPeriod),
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.expand_more,
                          color: AppColors.disabled(context),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Log List Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: AppColors.error(context)),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadLogs,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _logs.isEmpty
                        ? Center(
                            child: Text(
                              'No logs found',
                              style:
                                  TextStyle(color: AppColors.disabled(context)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              return _buildLogItem(log);
                            },
                          ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.stroke(context), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              activeIcon: Icon(Icons.list_alt_rounded),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // Widget Helper for Log Items
  Widget _buildLogItem(Log log) {
    final bool isAuthorized = log.authorized;
    final IconData icon = isAuthorized ? Icons.check_circle : Icons.cancel;
    final Color iconColor = isAuthorized
        ? const Color(0xFF10B981) // green-500
        : const Color(0xFFEF4444); // red-500
    final Color iconBgColor = isAuthorized
        ? const Color(0xFFD1FAE5) // green-100
        : const Color(0xFFFEE2E2); // red-100
    final String timeString = log.timestamp.length >= 16
        ? log.timestamp.substring(11, 16)
        : log.timestamp;
    final String action = isAuthorized ? 'Access Granted' : 'Access Denied';

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/log-detail',
          arguments: log,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // To mimic min-h-[72px] and flex layout
        constraints: const BoxConstraints(minHeight: 72),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side: Icon + Text
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          log.name,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          action,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8), // slate-400
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Right side: Time
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                timeString,
                style: const TextStyle(
                  color: Color(0xFF94A3B8), // slate-400
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
