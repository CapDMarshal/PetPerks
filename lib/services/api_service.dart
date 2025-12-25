import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class DataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadProductImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      await _supabase.storage
          .from('product-images')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // --- PROFILES ---

  Future<Map<String, dynamic>> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return data;
    } catch (e) {
      // If profile doesn't exist, return basic user info
      return {
        'id': user.id,
        'email': user.email,
        'display_name': user.userMetadata?['display_name'],
      };
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final updates = {
      'id': user.id,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (displayName != null) updates['display_name'] = displayName;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;

    await _supabase.from('profiles').upsert(updates);

    // Also update auth metadata for display name
    if (displayName != null) {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'display_name': displayName}),
      );
    }
  }

  // --- PRODUCTS ---

  Future<List<Map<String, dynamic>>> getProducts({String? category}) async {
    try {
      var query = _supabase.from('products').select();
      if (category != null && category != 'All') {
        query = query.eq('category', category);
      }
      return List<Map<String, dynamic>>.from(await query);
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to add products');

    // In a real app, you might check for specific roles here
    try {
      await _supabase.from('products').insert({
        ...data,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to update products');

    try {
      await _supabase.from('products').update(data).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to delete products');

    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // --- CART ---

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Please login to add to cart');

    await _supabase.from('cart_items').upsert({
      'user_id': user.id,
      'product_id': productId,
      'quantity':
          quantity, // Note: This logic might need to be 'increment' if upserting, but for simple MVP valid
    }, onConflict: 'user_id, product_id');
  }

  Future<void> removeFromCart(String productId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('cart_items').delete().match({
      'user_id': user.id,
      'product_id': productId,
    });
  }

  // --- WISHLIST ---

  Future<List<Map<String, dynamic>>> getWishlist() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('wishlist_items')
          .select('*, products(*)')
          .eq('user_id', user.id);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching wishlist: $e');
      return [];
    }
  }

  Future<void> addToWishlist(String productId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Please login');

    await _supabase.from('wishlist_items').upsert({
      'user_id': user.id,
      'product_id': productId,
    }, onConflict: 'user_id, product_id');
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('wishlist_items').delete().match({
      'user_id': user.id,
      'product_id': productId,
    });
  }

  // --- ORDERS ---

  Future<List<Map<String, dynamic>>> getOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      // Simple fetch, expanded for items would be more complex
      final data = await _supabase
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}
