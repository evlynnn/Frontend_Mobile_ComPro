import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2; // "Profile" is selected (index 2)

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/logs');
    } else if (index == 2) {
      // Already on profile
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            16, 16, 16, 96), // Bottom padding for nav bar
        child: Column(
          children: [
            // --- Profile Header ---
            const SizedBox(height: 16),
            Stack(
              children: [
                // Profile Image
                Container(
                  width: 96, // size-24 (24 * 4 = 96px)
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF283039), // bg-slate-200 equivalent
                    border: Border.all(
                      color: const Color(
                          0xFF1C242D), // border-white dark equivalent
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuDoqUYKFRMSgvSOwZu0Gf4lN_W6KWM3ivc7_fBNgkDfLGboe7OVGrn59ot1WDsy30lVhL4BZuBGjsomOifzXGv0ETEaj0rByAyA0vDcz1TSlUkypUi9rdQMm5r78ozXxJ7JGgfASwP7Xlo5CXKfiyMp_DHrRd1Wd0Mu_Pm5M-iACiPDv60ARtKkEtmOYLlqT749yHYcAeb-nhTWMiYKRXhjGzdKtaCwndD-sMRIpdFoHRwZXqmbuZZkl8Xb-3hrUSeYzYJL3J344bg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Edit Button Overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF137FEC), // primary
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1C242D), // match border
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Alex Morgan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // text-xl
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'alex.morgan@example.com',
              style: TextStyle(
                color: Color(0xFF9DABB9), // text-[#9dabb9]
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // --- Menu Options ---
            _buildMenuItem(
              icon: Icons.person_outline,
              iconColor: const Color(0xFF137FEC), // primary
              iconBgColor:
                  const Color(0xFF1E3A8A).withOpacity(0.2), // blue-900/20
              title: 'Edit Profile',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.lock_outline,
              iconColor: const Color(0xFFC084FC), // purple-400
              iconBgColor:
                  const Color(0xFF581C87).withOpacity(0.2), // purple-900/20
              title: 'Change Password',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFF94A3B8), // slate-400
              iconBgColor:
                  const Color(0xFF334155).withOpacity(0.5), // slate-700/50
              title: 'App Settings',
              onTap: () {},
            ),

            // --- Logout Section ---
            const SizedBox(height: 32),
            InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F1D1D).withOpacity(0.1), // red-900/10
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        const Color(0xFF7F1D1D).withOpacity(0.3), // red-900/30
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout,
                        color: Color(0xFFF87171), size: 20), // red-400
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFF87171), // red-400
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'App Version 2.4.0',
              style: TextStyle(
                color: Color(0xFF475569), // slate-600
                fontSize: 12,
              ),
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
          color: Color(0xCC1C242D), // Footer bg
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
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

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C242D), // Card bg
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
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
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF475569), // slate-600
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
