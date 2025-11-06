import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final String imagePath;
  final Color backgroundColor;

  const CategoryCard({super.key, required this.categoryName, required this.imagePath, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Text(categoryName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}