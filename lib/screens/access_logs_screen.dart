import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AccessLogsScreen extends StatefulWidget {
  const AccessLogsScreen({super.key});

  @override
  State<AccessLogsScreen> createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends State<AccessLogsScreen> {
  final int _selectedIndex = 1; // "Logs" is selected (index 1)

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
      // Top App Bar
      appBar: AppBar(
        title: const Text('Access Logs'),
        surfaceTintColor:
            Colors.transparent, // Prevents slight color change on scroll
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child:
              Container(), // Placeholder if needed, handled by body structure
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip('Date/Time'),
                const SizedBox(width: 12),
                _buildFilterChip('Name'),
              ],
            ),
          ),

          // Log List Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                _buildLogItem(
                  icon: Icons.lock_open,
                  iconColor: AppColors.textPrimary(context),
                  iconBgColor: AppColors.cardSurface(context), // slate-800
                  name: 'Jane Doe',
                  action: 'Unlocked Front Door',
                  time: '10:42 AM',
                ),
                _buildLogItem(
                  icon: Icons.lock,
                  iconColor: const Color(0xFFEF4444), // red-500
                  iconBgColor:
                      AppColors.cardSurface(context), // red-500/20 approx
                  name: 'Unknown',
                  action: 'Access Denied',
                  time: '5m ago',
                ),
                _buildLogItem(
                  icon: Icons.lock,
                  iconColor: AppColors.textPrimary(context),
                  iconBgColor: AppColors.cardSurface(context),
                  name: 'Jane Doe',
                  action: 'Locked Front Door',
                  time: '1h ago',
                ),
                _buildLogItem(
                  icon: Icons.lock_open,
                  iconColor: AppColors.textPrimary(context),
                  iconBgColor: AppColors.cardSurface(context),
                  name: 'Delivery Driver',
                  action: 'Unlocked Front Door',
                  time: 'Yesterday',
                ),
                _buildLogItem(
                  icon: Icons.lock_open,
                  iconColor: AppColors.textPrimary(context),
                  iconBgColor: AppColors.cardSurface(context),
                  name: 'John Appleseed',
                  action: 'Unlocked Front Door',
                  time: 'Oct 23, 2023',
                ),
                _buildLogItem(
                  icon: Icons.lock,
                  iconColor: AppColors.textPrimary(context),
                  iconBgColor: AppColors.cardSurface(context),
                  name: 'John Appleseed',
                  action: 'Locked Front Door',
                  time: 'Oct 23, 2023',
                ),
              ],
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

  // Widget Helper for Filter Chips
  Widget _buildFilterChip(String label) {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 12, right: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
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
    );
  }

  // Widget Helper for Log Items
  Widget _buildLogItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String name,
    required String action,
    required String time,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/log-detail');
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
                          name,
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
                time,
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
