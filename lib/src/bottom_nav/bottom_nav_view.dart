import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/view/reels_list_screen.dart';

class BottomNavView extends StatefulWidget {
  const BottomNavView({super.key});

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  int _currentPage = 0;

  static final List<Widget> _screens = [
    ReelsListScreen(key: Key("first_view")),
    ReelsListScreen(key: Key("second_view")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: IndexedStack(index: _currentPage, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.white70,
        currentIndex: _currentPage,
        onTap: (value) {
          _currentPage = value;
          setState(() {});
        },
        unselectedLabelStyle: context.theme.textTheme.bodyMedium,
        selectedLabelStyle: context.theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Mix'),
        ],
      ),
    );
  }
}
