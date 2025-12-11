import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedIndex = 1; // "Logs" active index based on HTML

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      // Already on notifications
      return;
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top App Bar
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // color: Colors.transparent, // Default
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              color: const Color(0xFF9CA3AF), // gray-400
              onPressed: () {
                // Handle delete action
              },
            ),
          ),
        ],
      ),

      // Main Content
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // New Today Section
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Today',
              style: TextStyle(
                color: Color(0xFF9CA3AF), // gray-400
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Known Person Detected
          _buildNotificationItem(
            icon: Icons.how_to_reg, // Closest to person_check
            iconColor: const Color(0xFF137FEC), // primary
            iconBgColor: const Color(0xFF137FEC).withOpacity(0.2),
            title: 'Known Person Detected',
            subtitle: 'John Doe at Front Door',
            time: '5:28 PM',
            timeColor: const Color(0xFF137FEC), // primary
            imageUrl:
                "https://lh3.googleusercontent.com/aida-public/AB6AXuCoWdHGlH0yTf8sbpwYg2FP0rPc81LPQygUxm93kYaYNmKgPmuejMq1kSL8VlFfHaGO2B4C7mk7SGjKwbdbbLvrGuj9dbxD8s7VX5QkHDGP2fJ0vJQHjpIYINCkB4JsQJ3SMnmBN3-viVUykmRmzncovJy9z_0pHeHAX_kezJ0liF6H_yfzDD1UOL0U-pRGRbq7cY7i_nUnkZ_tawEgBjz_Ydr2THGClx-Eb1dYZogVmwXNGECBY30txzFabpNnYOYTRieaFDu3s3w",
          ),

          const SizedBox(height: 12),

          // Unknown Person Detected
          _buildNotificationItem(
            icon: Icons.person_search,
            iconColor: const Color(0xFFFB923C), // orange-400
            iconBgColor:
                const Color(0xFFF97316).withOpacity(0.2), // orange-500/20
            title: 'Unknown Person Detected',
            subtitle: 'Front Door',
            time: '5:30 PM',
            timeColor: const Color(0xFF9CA3AF), // gray-400
            imageUrl:
                "https://lh3.googleusercontent.com/aida-public/AB6AXuBvZF0VIQ7ClC90t_3i3REENz4awrTgeUc2ph-FUPhhx8g7qb4dZu4p6EIcSghKURPa_1eh4iAxuofhW4yZaeFzpYMYiYan-v4mdgyGVS3CgPhAaYtPK99TKk6P_cdSZhY_2h565pppMNNCLgUtlSHx0___IfwsLNH4FWkymCFece3EWjhketPchZuUVIgizIH7cV2DjmmgFA4cmtZNcqi3WSXiMuofpN6hjlBCi6R5W1S3LeuD_C17Z8g3kEUYpQbSJ9_GCc0-D8s",
          ),

          // Yesterday Section
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 12),
            child: Text(
              'Yesterday',
              style: TextStyle(
                color: Color(0xFF9CA3AF), // gray-400
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Forced Entry Alert (Red)
          _buildNotificationItem(
            icon: Icons.meeting_room_outlined, // door_open equivalent
            iconColor: const Color(0xFFF87171), // red-400
            iconBgColor: const Color(0xFFEF4444).withOpacity(0.2), // red-500/20
            bgColor: const Color(0xFFEF4444)
                .withOpacity(0.1), // red-500/10 background
            title: 'Forced Entry Alert',
            titleColor: const Color(0xFFEF4444), // red-500 text
            subtitle: 'Back Door',
            time: '2:15 AM',
            timeColor: const Color(0xFF9CA3AF), // gray-400
          ),

          const SizedBox(height: 12),

          // Another Known Person (Jane Smith)
          _buildNotificationItem(
            icon: Icons.how_to_reg,
            iconColor: const Color(0xFF137FEC),
            iconBgColor: const Color(0xFF137FEC).withOpacity(0.2),
            title: 'Known Person Detected',
            subtitle: 'Jane Smith at Garage',
            time: 'Yesterday, 9:12 AM',
            timeColor: const Color(0xFF137FEC),
            imageUrl:
                "https://lh3.googleusercontent.com/aida-public/AB6AXuAntv2AbE-lTbTDRZ7lWHcw4X0Hm6y6j8LgDGYcMDbfsoldjlfjFTjqqtbZaW7GSTOec_DTSa33gCLj-V2g7qDEPJnekbTYnUU7sP16pnh9yFrPFQOHHRMTGBf_bq34ikFGo1zlBzLlxoK39Wq6xvRjPBr-TXNhfgW4MMfEoMGVEarQz53h2XIfTzlhjGzjfeinQ-8j2bqOubUgovqI6Dy6W15FGU3EJ5CX3AmsFHtzU-Cw3WLuxuXYLfrzS732j_AKvHOkSnss1F4",
          ),

          const SizedBox(height: 24), // Bottom padding
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
                color: Color(0xFF283039),
                width: 1), // dark:border-white/10 equivalent
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
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications_active),
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

  // Widget Helper for Notification Items
  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    Color? bgColor, // Optional background color (for alerts)
    required String title,
    Color? titleColor, // Optional title color
    required String subtitle,
    required String time,
    required Color timeColor,
    String? imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white.withOpacity(0.05), // Default bg-white/5
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF), // gray-400
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: timeColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Optional Image
          if (imageUrl != null) ...[
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
