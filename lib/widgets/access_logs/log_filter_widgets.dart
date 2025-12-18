import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/log.dart';

class LogFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const LogFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

class LogClearFilterButton extends StatelessWidget {
  final VoidCallback onTap;

  const LogClearFilterButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
    );
  }
}

class LogPeriodBottomSheet extends StatelessWidget {
  final LogFilterPeriod selectedPeriod;
  final VoidCallback onSelectToday;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectRange;

  const LogPeriodBottomSheet({
    super.key,
    required this.selectedPeriod,
    required this.onSelectToday,
    required this.onSelectDate,
    required this.onSelectRange,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            context,
            'Today',
            Icons.today_rounded,
            selectedPeriod == LogFilterPeriod.today,
            onSelectToday,
          ),
          _buildPeriodOption(
            context,
            'Pick a Date',
            Icons.calendar_month_rounded,
            selectedPeriod == LogFilterPeriod.date,
            onSelectDate,
          ),
          _buildPeriodOption(
            context,
            'Date Range',
            Icons.date_range_rounded,
            selectedPeriod == LogFilterPeriod.range,
            onSelectRange,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPeriodOption(
    BuildContext context,
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
}

class LogStatusBottomSheet extends StatelessWidget {
  final LogStatusFilter selectedStatus;
  final ValueChanged<LogStatusFilter> onStatusSelected;

  const LogStatusBottomSheet({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            context,
            'All Status',
            Icons.list_rounded,
            selectedStatus == LogStatusFilter.all,
            () => onStatusSelected(LogStatusFilter.all),
          ),
          _buildStatusOption(
            context,
            'Authorized Only',
            Icons.check_circle_rounded,
            selectedStatus == LogStatusFilter.authorized,
            () => onStatusSelected(LogStatusFilter.authorized),
            iconColor: Colors.green,
          ),
          _buildStatusOption(
            context,
            'Unauthorized Only',
            Icons.cancel_rounded,
            selectedStatus == LogStatusFilter.unauthorized,
            () => onStatusSelected(LogStatusFilter.unauthorized),
            iconColor: AppColors.error(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
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
}
