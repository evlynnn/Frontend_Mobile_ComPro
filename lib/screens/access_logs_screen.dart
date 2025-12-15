import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';
import '../models/log.dart';

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
      ),
      body: Column(
        children: [
          // Stats Section
          if (!_isLoading && _errorMessage == null)
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    '$_totalCount',
                    'Total Logs',
                    AppColors.primary(context),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.divider(context),
                  ),
                  _buildStatItem(
                    context,
                    '$_unknownVisitors',
                    'Unknown',
                    AppColors.error(context),
                  ),
                ],
              ),
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
                _buildFilterChip(
                  label: _getPeriodLabel(),
                  icon: Icons.calendar_today_rounded,
                  isActive: _selectedPeriod != LogFilterPeriod.today,
                  onTap: () => _showPeriodMenu(),
                ),
                const SizedBox(width: 8),

                // Status Filter
                _buildFilterChip(
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
                    child: InkWell(
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
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.clear_rounded,
                              size: 16,
                              color: AppColors.error(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Clear',
                              style: TextStyle(
                                color: AppColors.error(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      ? _buildErrorState()
                      : _filteredLogs.isEmpty
                          ? _buildEmptyState()
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
                                return _buildLogItem(log);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary(context).withOpacity(0.15)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primary(context).withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? AppColors.primary(context)
                  : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.primary(context)
                    : AppColors.textPrimary(context),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isActive
                  ? AppColors.primary(context)
                  : AppColors.textSecondary(context),
            ),
          ],
        ),
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filter by Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            _buildPeriodOption(
              'Today',
              Icons.today_rounded,
              _selectedPeriod == LogFilterPeriod.today,
              () {
                Navigator.pop(context);
                setState(() {
                  _selectedPeriod = LogFilterPeriod.today;
                  _selectedDate = null;
                  _startDate = null;
                  _endDate = null;
                });
                _loadLogs();
              },
            ),
            _buildPeriodOption(
              'Pick a Date',
              Icons.calendar_month_rounded,
              _selectedPeriod == LogFilterPeriod.date,
              () {
                Navigator.pop(context);
                _selectDate();
              },
            ),
            _buildPeriodOption(
              'Date Range',
              Icons.date_range_rounded,
              _selectedPeriod == LogFilterPeriod.range,
              () {
                Navigator.pop(context);
                _selectDateRange();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppColors.primary(context)
            : AppColors.textSecondary(context),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppColors.primary(context))
          : null,
      onTap: onTap,
    );
  }

  void _showStatusMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filter by Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            _buildStatusOption(
              'All Status',
              Icons.list_rounded,
              _selectedStatus == LogStatusFilter.all,
              () {
                Navigator.pop(context);
                setState(() => _selectedStatus = LogStatusFilter.all);
                _applyLocalFilters();
              },
            ),
            _buildStatusOption(
              'Authorized Only',
              Icons.check_circle_rounded,
              _selectedStatus == LogStatusFilter.authorized,
              () {
                Navigator.pop(context);
                setState(() => _selectedStatus = LogStatusFilter.authorized);
                _applyLocalFilters();
              },
              iconColor: Colors.green,
            ),
            _buildStatusOption(
              'Unauthorized Only',
              Icons.cancel_rounded,
              _selectedStatus == LogStatusFilter.unauthorized,
              () {
                Navigator.pop(context);
                setState(() => _selectedStatus = LogStatusFilter.unauthorized);
                _applyLocalFilters();
              },
              iconColor: AppColors.error(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ??
            (isSelected
                ? AppColors.primary(context)
                : AppColors.textSecondary(context)),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppColors.primary(context))
          : null,
      onTap: onTap,
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadLogs,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 48,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'No logs found',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(Log log) {
    final bool isAuthorized = log.authorized;
    final String timeString = log.timestamp.length >= 16
        ? log.timestamp.substring(11, 16)
        : log.timestamp;
    final String dateString =
        log.timestamp.length >= 10 ? log.timestamp.substring(0, 10) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/log-detail',
              arguments: log,
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Status Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isAuthorized
                        ? Colors.green.withOpacity(0.1)
                        : AppColors.error(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isAuthorized
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color:
                        isAuthorized ? Colors.green : AppColors.error(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              log.name,
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeString,
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAuthorized ? 'Access Granted' : 'Access Denied',
                            style: TextStyle(
                              color: isAuthorized
                                  ? Colors.green
                                  : AppColors.error(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_selectedPeriod != LogFilterPeriod.today)
                            Text(
                              dateString,
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary(context),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
