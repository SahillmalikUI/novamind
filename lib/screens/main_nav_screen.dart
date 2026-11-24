import 'package:flutter/material.dart';
import '../core/widgets/nova_floating_dock.dart';
import 'home_screen.dart';
import 'task_screen.dart';
import 'chat_screen.dart';
import 'quiz_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B16),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Current tab screen
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(onNavigateTab: _onTabSelected),
              const TaskScreen(),
              const ChatScreen(),
              const QuizScreen(),
              const ProfileScreen(),
            ],
          ),

          // Floating Glass Island Dock
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NovaFloatingDock(
              currentIndex: _currentIndex,
              onTabSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}
