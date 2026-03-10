import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'square_screen.dart';
import 'vision_screen.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SquareScreen(),
    const SizedBox(), // Placeholder for center button
    const VisionScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex, // Skip center button
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.85),
          border: Border(
            top: BorderSide(
              color: Colors.white60,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.explore, '彼趣'),
                _buildNavItem(1, Icons.grid_view, '广场'),
                _buildCenterButton(),
                _buildNavItem(3, Icons.movie, '视界'),
                _buildNavItem(4, Icons.person, '我的'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive 
                ? const Color(0xFFF72E1E) 
                : const Color(0xFF9C8E8E),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive 
                  ? const Color(0xFFF72E1E) 
                  : const Color(0xFF9C8E8E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () {
        // 打开AI助手聊天页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AIChatScreen(),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF72E1E), Color(0xFFFF7E7E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(247, 46, 30, 0.4),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFFF0F0),
            width: 4,
          ),
        ),
        child: const Icon(
          Icons.smart_toy,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}