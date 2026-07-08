import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/lapak/lapak_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  /// [initialIndex] dipakai untuk navigasi langsung ke tab tertentu,
  /// misalnya setelah post barang → langsung ke Profile (index 4).
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  // Tab yang ditampilkan di bottom nav (tanpa Lapak — Lapak dibuka via push)
  final List<Widget> _children = [
    const HomeScreen(),
    const WishlistScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Jika initialIndex == 4 (Profile), map ke index 3 karena Lapak sudah
    // dikeluarkan dari daftar tab IndexedStack
    _currentIndex = widget.initialIndex == 4 ? 3 : widget.initialIndex;
  }

  void onTabTapped(int index) {
    // index 2 = tombol Lapak "+" → buka sebagai push (bukan switch tab)
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LapakScreen()),
      );
      return;
    }

    // Map index bottom nav ke index IndexedStack
    // Nav: 0=Home, 1=Wishlist, 2=Lapak(push), 3=Chat, 4=Profile
    // Stack: 0=Home, 1=Wishlist, 2=Chat, 3=Profile
    final stackIndex = index > 2 ? index - 1 : index;
    setState(() {
      _currentIndex = stackIndex;
    });
  }

  /// Konversi _currentIndex (stack) ke bottomNav index
  int get _bottomNavIndex => _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _children),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6D4C41),
        unselectedItemColor: Colors.grey[400],
        currentIndex: _bottomNavIndex,
        onTap: onTabTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            activeIcon: Icon(Icons.add_circle, size: 32),
            label: 'Jual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
