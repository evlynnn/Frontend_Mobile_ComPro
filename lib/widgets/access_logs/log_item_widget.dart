import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/log.dart';

class LogItemWidget extends StatelessWidget {
  final Log log;
  final bool showDate;

  const LogItemWidget({
    super.key,
    required this.log,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
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
                          if (showDate)
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
