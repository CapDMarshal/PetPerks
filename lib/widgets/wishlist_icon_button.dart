import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

/// Reusable Wishlist Icon Button Widget
/// 
/// Displays a heart icon that toggles between favorited and non-favorited states.
/// Integrates with Supabase for persisting wishlist items.
class WishlistIconButton extends StatefulWidget {
  final String productId;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const WishlistIconButton({
    super.key,
    required this.productId,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<WishlistIconButton> createState() => _WishlistIconButtonState();
}

class _WishlistIconButtonState extends State<WishlistIconButton> {
  final DataService _dataService = DataService();
  bool _isFavorited = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  /// Check if the product is already in the wishlist
  Future<void> _checkWishlistStatus() async {
    try {
      final wishlistItems = await _dataService.getWishlist();
      if (mounted) {
        setState(() {
          _isFavorited = wishlistItems.any(
            (item) => item['product_id'] == widget.productId,
          );
        });
      }
    } catch (e) {
      // Silently fail - assumes not in wishlist
      if (mounted) {
        setState(() {
          _isFavorited = false;
        });
      }
    }
  }

  /// Toggle wishlist status
  Future<void> _toggleWishlist() async {
    if (_isLoading) return;

    // Validation: Check if productId is valid
    if (widget.productId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Product ID is empty'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      print('ERROR: Product ID is empty in WishlistIconButton');
      return;
    }

    // Validation: Check if user is logged in
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add items to wishlist'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      print('ERROR: User not logged in');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG: Toggling wishlist for product: ${widget.productId}, current state: $_isFavorited');
      
      if (_isFavorited) {
        // Remove from wishlist
        await _dataService.removeFromWishlist(widget.productId);
        if (mounted) {
          setState(() {
            _isFavorited = false;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from wishlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        print('SUCCESS: Removed from wishlist - Product: ${widget.productId}');
      } else {
        // Add to wishlist
        await _dataService.addToWishlist(widget.productId);
        if (mounted) {
          setState(() {
            _isFavorited = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to wishlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        print('SUCCESS: Added to wishlist - Product: ${widget.productId}, User: ${user.id}');
      }
    } catch (e) {
      print('ERROR: Failed to toggle wishlist - Product: ${widget.productId}, Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = widget.activeColor ?? Colors.red;
    final Color inactiveColor = widget.inactiveColor ?? Colors.grey;

    return IconButton(
      icon: _isLoading
          ? SizedBox(
              width: widget.size,
              height: widget.size,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              size: widget.size,
              color: _isFavorited ? activeColor : inactiveColor,
            ),
      onPressed: _toggleWishlist,
    );
  }
}
