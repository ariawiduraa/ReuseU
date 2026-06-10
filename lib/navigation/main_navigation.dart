import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/lapak/lapak_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // List halaman yang akan ditampilkan sesuai urutan tab
  final List<Widget> _children = [
    const HomeScreen(),
    const WishlistScreen(),
    const LapakScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _children),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(
          0xFF6D4C41,
        ), // Warna coklat aktif sesuai desain
        unselectedItemColor: Colors.grey[400],
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        showSelectedLabels:
            false, // Menghilangkan label teks saat aktif sesuai mockup
        showUnselectedLabels:
            false, // Menghilangkan label teks saat tidak aktif
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
            icon: Icon(
              Icons.add,
              size: 28,
            ), // Tombol '+' untuk fungsionalitas Jual
            activeIcon: Icon(Icons.add_box, size: 28),
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
