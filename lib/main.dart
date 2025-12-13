// main.dart
import 'package:flutter/material.dart';
import 'utils/routes.dart';
import 'utils/app_theme.dart'; // Import the theme file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Exhibition App',
      theme: AppTheme.lightTheme, // <--- APPLY THE THEME HERE
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}