import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'biqu_home_screen.dart';
import 'square_screen.dart';
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
    const BiquHomeScreen(),
    const SquareScreen(),
    const AIChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: IndexedStack(
        index: _currentIndex,
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
                _buildNavItem(2, Icons.smart_toy_outlined, 'AI助手'),
                _buildNavItem(3, Icons.person, '我的'),
              ],
            ),
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

}