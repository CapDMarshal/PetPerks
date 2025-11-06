import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final int itemCount;
  final String imagePath;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.productName,
    required this.itemCount,
    required this.imagePath,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.black, size: 18),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(productName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('($itemCount Items)', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}