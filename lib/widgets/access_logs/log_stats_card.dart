import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class LogStatsCard extends StatelessWidget {
  final int totalCount;
  final int unknownVisitors;

  const LogStatsCard({
    super.key,
    required this.totalCount,
    required this.unknownVisitors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            '$totalCount',
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
            '$unknownVisitors',
            'Unknown',
            AppColors.error(context),
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
}
