import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/service_locator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications =
        await ServiceLocator.notificationService.getSavedNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text(
          'Clear All Notifications',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        content: Text(
          'Are you sure you want to delete all notifications?',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear All',
                style: TextStyle(color: AppColors.error(context))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ServiceLocator.notificationService.clearAllNotifications();
      await _loadNotifications();
    }
  }

  Future<void> _deleteNotification(String id) async {
    await ServiceLocator.notificationService.deleteNotification(id);
    await _loadNotifications();
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final notificationDate = DateTime(date.year, date.month, date.day);

      if (notificationDate == today) {
        return DateFormat('h:mm a').format(date);
      } else if (notificationDate == yesterday) {
        return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
      } else {
        return DateFormat('MMM d, h:mm a').format(date);
      }
    } catch (e) {
      return timestamp;
    }
  }

  List<MapEntry<String, List<Map<String, dynamic>>>>
      _groupNotificationsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final Map<String, DateTime> dateKeys = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final notification in _notifications) {
      try {
        final timestamp = notification['timestamp'] ?? '';
        final date = DateTime.parse(timestamp);
        final notificationDate = DateTime(date.year, date.month, date.day);

        String key;
        if (notificationDate == today) {
          key = 'Today';
        } else if (notificationDate == yesterday) {
          key = 'Yesterday';
        } else {
          key = DateFormat('MMMM d, yyyy').format(date);
        }

        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(notification);
        dateKeys[key] = notificationDate;
      } catch (e) {
        grouped.putIfAbsent('Other', () => []);
        grouped['Other']!.add(notification);
        dateKeys['Other'] = DateTime(1970);
      }
    }

    // Sort keys: Today first, Yesterday second, then by date descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Today') return -1;
        if (b == 'Today') return 1;
        if (a == 'Yesterday') return -1;
        if (b == 'Yesterday') return 1;
        final dateA = dateKeys[a] ?? DateTime(1970);
        final dateB = dateKeys[b] ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

    return sortedKeys.map((key) => MapEntry(key, grouped[key]!)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotificationsByDate();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.textSecondary(context),
              ),
              onPressed: _clearAllNotifications,
              tooltip: 'Clear all',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: groupedNotifications.length,
                    itemBuilder: (context, index) {
                      final entry = groupedNotifications[index];
                      final dateKey = entry.key;
                      final notifications = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index > 0) const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              dateKey,
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...notifications.map((notification) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildNotificationItem(notification),
                              )),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: AppColors.primary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final title = notification['title'] ?? 'Notification';
    final body = notification['body'] ?? '';
    final timestamp = notification['timestamp'] ?? '';
    final isRead = notification['read'] ?? false;
    final id = notification['id'] ?? '';

    // Determine notification type based on title
    final isUnknown = title.toLowerCase().contains('unknown') ||
        title.toLowerCase().contains('denied') ||
        title.toLowerCase().contains('alert');
    final isGranted = title.toLowerCase().contains('granted') ||
        title.toLowerCase().contains('authorized') ||
        title.toLowerCase().contains('welcome');

    // Set colors based on type
    Color accentColor;
    IconData iconData;
    if (isUnknown) {
      accentColor = AppColors.error(context);
      iconData = Icons.warning_rounded;
    } else if (isGranted) {
      accentColor = Colors.green;
      iconData = Icons.check_circle_rounded;
    } else {
      accentColor = AppColors.primary(context);
      iconData = Icons.notifications_rounded;
    }

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.surface(context)
              : accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              isRead ? null : Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 15,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
