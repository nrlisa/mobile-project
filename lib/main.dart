import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project3_lab04_nurlisa_52215124595/firebase_options.dart';
import 'package:project3_lab04_nurlisa_52215124595/utils/routes.dart';

// [Unverified] This is the required entry point for the application to run.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initializes Firebase using the configurations in your firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [Inference] The GoRouter configuration in routes.dart handles the initial 
    // location of '/guest', ensuring the GuestHomeScreen is the main page.
    return MaterialApp.router(
      title: 'Exhibition Management App',
      debugShowCheckedModeBanner: false,
      routerConfig: router, // Uses the router defined in lib/utils/routes.dart
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}