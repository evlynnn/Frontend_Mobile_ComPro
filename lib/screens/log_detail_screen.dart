import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/log.dart';

class LogDetailScreen extends StatefulWidget {
  const LogDetailScreen({super.key});

  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  Log? _log;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_log == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Log) {
        setState(() {
          _log = args;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Log Detail'),
        backgroundColor: AppColors.background(context).withOpacity(0.8),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.stroke(context).withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: _log == null
          ? Center(
              child: Text(
                'No log data available',
                style: TextStyle(color: AppColors.disabled(context)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _log!.authorized
                                ? AppColors.success(context).withOpacity(0.2)
                                : AppColors.error(context).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _log!.authorized ? 'Authorized' : 'Unauthorized',
                            style: TextStyle(
                              color: _log!.authorized
                                  ? AppColors.success(context)
                                  : AppColors.error(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _log!.name,
                          style: TextStyle(
                            color: AppColors.darker(context),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _log!.authorized ? 'Access Granted' : 'Access Denied',
                          style: TextStyle(
                            color: AppColors.disabled(context),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                            context, 'Time', _formatTimestamp(_log!.timestamp),
                            showBorder: true),
                        _buildDetailRow(context, 'Role', _log!.role,
                            showBorder: true),
                        _buildDetailRow(context, 'AI Confidence',
                            '${(_log!.confidence).toStringAsFixed(2)}%',
                            showBorder: true),
                        _buildDetailRow(context, 'Method', 'Facial Recognition',
                            showBorder: true),
                        _buildDetailRow(context, 'Log ID', _log!.id.toString(),
                            showBorder: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('EEEE, d MMMM yyyy • HH:mm').format(date);
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool showBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: showBorder
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.stroke(context),
                  width: 1,
                ),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.disabled(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.darker(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
