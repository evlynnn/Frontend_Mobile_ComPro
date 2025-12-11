import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      // Already on home
      return;
    } else if (index == 1) {
      Navigator.pushNamed(context, '/logs');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        // Menambahkan tombol notifikasi di sebelah kanan sesuai HTML baru
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          const SizedBox(width: 8), // Sedikit jarak dari tepi kanan
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Summary Card (Updated Content)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C242D), // dark:bg-[#1C242D]
                borderRadius: BorderRadius.circular(12), // rounded-xl
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Summary',
                    style: TextStyle(
                      color: Color(0xFF9DABB9), // dark:text-[#9dabb9]
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total Detections Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '45',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Total Detections',
                            style: TextStyle(
                              color: Color(0xFF9DABB9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // Unknown Alerts Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            '2',
                            style: TextStyle(
                              color: Color(0xFFEF4444), // text-red-500
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Unknown Alerts',
                            style: TextStyle(
                              color: Color(0xFF9DABB9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(
                      color: Color(0xFF334155), height: 1), // border-t
                  const SizedBox(height: 16),
                  const Text(
                    'Device Online',
                    style: TextStyle(
                      color: Color(0xFF9DABB9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Latest Activity Header
            const Text(
              'Latest Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Activity Item
            Row(
              children: [
                // Icon Container
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF283039), // dark:bg-[#283039]
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF94A3B8), // dark:text-slate-400
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Text Content
                const Expanded(
                  child: Text(
                    'John Doe unlocked the door',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Time
                const Text(
                  '2 min ago',
                  style: TextStyle(
                    color: Color(0xFF9DABB9), // dark:text-[#9dabb9]
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
                color: Color(0xFF283039), width: 1), // dark:border-[#283039]
          ),
          color: Color(0xCC1C242D), // Footer bg with slight opacity
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
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
}
