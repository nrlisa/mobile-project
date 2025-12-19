import 'package:flutter/material.dart';
import 'utils/routes.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Exhibition App',
      theme: AppTheme.lightTheme,
      routerConfig: router, // This handles all navigation
      debugShowCheckedModeBanner: false,
    );
  }
}