import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'homepage_screen.dart';
import 'access_logs_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _navigateToLogs() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of screens to display
    final List<Widget> screens = [
      HomeScreen(onViewAllLogs: _navigateToLogs),
      const AccessLogsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
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
              icon: Icon(Icons.more_horiz_rounded),
              activeIcon: Icon(Icons.more_horiz_rounded),
              label: 'More',
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
}
