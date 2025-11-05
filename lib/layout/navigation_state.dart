import 'package:flutter/material.dart';

/// NavigationState - Manages shared state across bottom navigation
/// Similar to Context API or state management in Next.js
class NavigationState extends ChangeNotifier {
  int _cartItemCount = 14;
  final List<String> _wishlistItems = [];

  int get cartItemCount => _cartItemCount;
  int get wishlistItemCount => _wishlistItems.length;

  void updateCartCount(int count) {
    _cartItemCount = count;
    notifyListeners();
  }

  void addToWishlist(String itemId) {
    if (!_wishlistItems.contains(itemId)) {
      _wishlistItems.add(itemId);
      notifyListeners();
    }
  }

  void removeFromWishlist(String itemId) {
    _wishlistItems.remove(itemId);
    notifyListeners();
  }

  bool isInWishlist(String itemId) {
    return _wishlistItems.contains(itemId);
  }
}

/// Example usage with Provider (if you want to use it):
/// 
/// 1. Add provider to pubspec.yaml:
///    dependencies:
///      provider: ^6.0.0
/// 
/// 2. Wrap MainLayout with ChangeNotifierProvider in main.dart:
///    home: ChangeNotifierProvider(
///      create: (_) => NavigationState(),
///      child: const MainLayout(),
///    ),
/// 
/// 3. Access state in any screen:
///    final navState = context.watch<NavigationState>();
///    Text('Cart items: ${navState.cartItemCount}')
/// 
/// 4. Update state from any screen:
///    context.read<NavigationState>().updateCartCount(15);
