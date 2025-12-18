import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class LogExportBottomSheet extends StatelessWidget {
  final VoidCallback onExportCSV;
  final VoidCallback onExportText;

  const LogExportBottomSheet({
    super.key,
    required this.onExportCSV,
    required this.onExportText,
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
              'Export Logs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.table_chart_rounded, color: Colors.green),
            ),
            title: Text(
              'Export as CSV',
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            subtitle: Text(
              'Spreadsheet format',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            onTap: onExportCSV,
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_rounded, color: Colors.blue),
            ),
            title: Text(
              'Export as Text',
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            subtitle: Text(
              'Plain text format',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            onTap: onExportText,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
