import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';
import '../models/log.dart';
import '../widgets/access_logs/log_item_widget.dart';
import '../widgets/access_logs/log_filter_widgets.dart';
import '../widgets/access_logs/log_export_sheet.dart';
import '../widgets/access_logs/log_stats_card.dart';
import '../widgets/access_logs/log_empty_state.dart';

class AccessLogsScreen extends StatefulWidget {
  const AccessLogsScreen({super.key});

  @override
  State<AccessLogsScreen> createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends State<AccessLogsScreen> {
  List<Log> _logs = [];
  List<Log> _filteredLogs = [];
  int _totalCount = 0;
  int _unknownVisitors = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // Filter states
  LogFilterPeriod _selectedPeriod = LogFilterPeriod.today;
  LogStatusFilter _selectedStatus = LogStatusFilter.all;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  // Pagination
  static const int _logsPerPage = 20;
  int _currentPage = 0;
  bool _hasMoreLogs = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreLogs();
    }
  }

  void _onSearchChanged() {
    _applyLocalFilters();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _hasMoreLogs = true;
    });

    try {
      final params = LogFilterParams(
        period: _selectedPeriod,
        date: _selectedPeriod == LogFilterPeriod.date && _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
        start: _selectedPeriod == LogFilterPeriod.range && _startDate != null
            ? DateFormat('yyyy-MM-dd').format(_startDate!)
            : null,
        end: _selectedPeriod == LogFilterPeriod.range && _endDate != null
            ? DateFormat('yyyy-MM-dd').format(_endDate!)
            : null,
      );

      final response = await ServiceLocator.logService.getFilteredLogs(params);
      setState(() {
        _logs = response.data;
        _totalCount = response.count;
        _unknownVisitors = response.unknownVisitors;
        _isLoading = false;
        _applyLocalFilters();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyLocalFilters() {
    List<Log> filtered = List.from(_logs);

    // Sort by timestamp descending (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered
          .where((log) => log.name.toLowerCase().contains(searchLower))
          .toList();
    }

    // Filter by status
    if (_selectedStatus == LogStatusFilter.authorized) {
      filtered = filtered.where((log) => log.authorized).toList();
    } else if (_selectedStatus == LogStatusFilter.unauthorized) {
      filtered = filtered.where((log) => !log.authorized).toList();
    }

    setState(() {
      _filteredLogs = filtered.take((_currentPage + 1) * _logsPerPage).toList();
      _hasMoreLogs = filtered.length > _filteredLogs.length;
    });
  }

  void _loadMoreLogs() {
    if (!_hasMoreLogs || _isLoading) return;

    setState(() {
      _currentPage++;
      _applyLocalFilters();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary(context),
              onPrimary: Colors.white,
              surface: AppColors.surface(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedPeriod = LogFilterPeriod.date;
      });
      _loadLogs();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary(context),
              onPrimary: Colors.white,
              surface: AppColors.surface(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = LogFilterPeriod.range;
      });
      _loadLogs();
    }
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case LogFilterPeriod.today:
        return 'Today';
      case LogFilterPeriod.date:
        return _selectedDate != null
            ? DateFormat('MMM d').format(_selectedDate!)
            : 'Pick Date';
      case LogFilterPeriod.range:
        if (_startDate != null && _endDate != null) {
          return '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}';
        }
        return 'Date Range';
    }
  }

  String _getStatusLabel() {
    switch (_selectedStatus) {
      case LogStatusFilter.all:
        return 'All Status';
      case LogStatusFilter.authorized:
        return 'Authorized';
      case LogStatusFilter.unauthorized:
        return 'Unauthorized';
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LogExportBottomSheet(
        onExportCSV: () {
          Navigator.pop(context);
          _exportToCSV();
        },
        onExportText: () {
          Navigator.pop(context);
          _exportToText();
        },
      ),
    );
  }

  Future<void> _exportToCSV() async {
    try {
      final StringBuffer csv = StringBuffer();
      csv.writeln('Name,Status,Date,Time,Timestamp');

      for (final log in _filteredLogs) {
        final status = log.authorized ? 'Authorized' : 'Unauthorized';
        final date =
            log.timestamp.length >= 10 ? log.timestamp.substring(0, 10) : '';
        final time =
            log.timestamp.length >= 16 ? log.timestamp.substring(11, 16) : '';
        csv.writeln(
            '"${log.name}","$status","$date","$time","${log.timestamp}"');
      }

      await _shareFile(csv.toString(), 'access_logs.csv', 'text/csv');
    } catch (e) {
      _showExportError(e.toString());
    }
  }

  Future<void> _exportToText() async {
    try {
      final StringBuffer text = StringBuffer();
      text.writeln('Face Locker - Access Logs Report');
      text.writeln(
          'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
      text.writeln('Total Logs: ${_filteredLogs.length}');
      text.writeln('=' * 50);
      text.writeln('');

      for (final log in _filteredLogs) {
        final status = log.authorized ? '✓ Authorized' : '✗ Unauthorized';
        final date =
            log.timestamp.length >= 10 ? log.timestamp.substring(0, 10) : '';
        final time =
            log.timestamp.length >= 16 ? log.timestamp.substring(11, 16) : '';
        text.writeln('$date $time - ${log.name}');
        text.writeln('Status: $status');
        text.writeln('-' * 30);
      }

      await _shareFile(text.toString(), 'access_logs.txt', 'text/plain');
    } catch (e) {
      _showExportError(e.toString());
    }
  }

  Future<void> _shareFile(
      String content, String filename, String mimeType) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: 'Face Locker Access Logs',
    );
  }

  void _showExportError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Export failed: $error')),
            ],
          ),
          backgroundColor: AppColors.error(context),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Access Logs',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.file_download_outlined,
              color: AppColors.textPrimary(context),
            ),
            onPressed: _filteredLogs.isEmpty ? null : _showExportOptions,
            tooltip: 'Export Logs',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Stats Section
          if (!_isLoading && _errorMessage == null)
            LogStatsCard(
              totalCount: _totalCount,
              unknownVisitors: _unknownVisitors,
            ),

          // Search Bar - Improved styling
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary(context),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary(context),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Filter Chips Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Period Filter
                LogFilterChip(
                  label: _getPeriodLabel(),
                  icon: Icons.calendar_today_rounded,
                  isActive: _selectedPeriod != LogFilterPeriod.today,
                  onTap: () => _showPeriodMenu(),
                ),
                const SizedBox(width: 8),

                // Status Filter
                LogFilterChip(
                  label: _getStatusLabel(),
                  icon: Icons.filter_list_rounded,
                  isActive: _selectedStatus != LogStatusFilter.all,
                  onTap: () => _showStatusMenu(),
                ),

                // Clear filters button
                if (_selectedPeriod != LogFilterPeriod.today ||
                    _selectedStatus != LogStatusFilter.all)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: LogClearFilterButton(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = LogFilterPeriod.today;
                          _selectedStatus = LogStatusFilter.all;
                          _selectedDate = null;
                          _startDate = null;
                          _endDate = null;
                        });
                        _loadLogs();
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_filteredLogs.length} of $_totalCount logs',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Log List Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadLogs,
              color: AppColors.primary(context),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? LogErrorState(
                          errorMessage: _errorMessage!,
                          onRetry: _loadLogs,
                        )
                      : _filteredLogs.isEmpty
                          ? const LogEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount:
                                  _filteredLogs.length + (_hasMoreLogs ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filteredLogs.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final log = _filteredLogs[index];
                                return LogItemWidget(
                                  log: log,
                                  showDate:
                                      _selectedPeriod != LogFilterPeriod.today,
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPeriodMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LogPeriodBottomSheet(
        selectedPeriod: _selectedPeriod,
        onSelectToday: () {
          Navigator.pop(context);
          setState(() {
            _selectedPeriod = LogFilterPeriod.today;
            _selectedDate = null;
            _startDate = null;
            _endDate = null;
          });
          _loadLogs();
        },
        onSelectDate: () {
          Navigator.pop(context);
          _selectDate();
        },
        onSelectRange: () {
          Navigator.pop(context);
          _selectDateRange();
        },
      ),
    );
  }

  void _showStatusMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LogStatusBottomSheet(
        selectedStatus: _selectedStatus,
        onStatusSelected: (status) {
          Navigator.pop(context);
          setState(() => _selectedStatus = status);
          _applyLocalFilters();
        },
      ),
    );
  }
}
