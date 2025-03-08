import 'package:flutter/material.dart';
import 'package:reels_demo/src/bottom_nav/bottom_nav_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reels Demo',
      debugShowCheckedModeBanner: false,
      home: const BottomNavView(),
      themeMode: ThemeMode.dark,
    );
  }
}
