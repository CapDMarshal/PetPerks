import 'package:flutter/material.dart';
import 'layout/main_layout.dart';

void main() {
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
      // Use MainLayout which includes bottom navigation
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
