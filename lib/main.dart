import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase for now
  }
  
  runApp(const PetPerksApp());
}

class PetPerksApp extends StatelessWidget {
  const PetPerksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetPerks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Temporary: Always show login page until Firebase is configured
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
