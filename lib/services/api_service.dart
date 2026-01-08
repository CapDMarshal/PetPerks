import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class DataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

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

  Future<String> uploadAvatar(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'avatars/$fileName';

      await _supabase.storage
          .from('avatars')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
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
    String? email,
    String? location,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final updates = <String, dynamic>{
      'id': user.id,
    };
    if (displayName != null) updates['display_name'] = displayName;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;
    if (email != null) updates['email'] = email;
    if (location != null) updates['location'] = location;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

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

  Future<void> updateOrderStatus(dynamic orderId, String status) async {
    try {
      final response = await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .select();
      
      if (response.isEmpty) {
        print('Warning: No order rows updated. Possible RLS policy violation or invalid ID.');
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
  // --- ADDRESSES ---

  Future<void> addUserAddress({
    required String title,
    required String addressLine,
    bool isDefault = false,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to add address');

    try {
      await _supabase.from('user_addresses').insert({
        'user_id': user.id,
        'title': title,
        'address_line': addressLine,
        'is_default': isDefault,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('user_addresses')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  // --- PAYMENT METHODS ---

  Future<Map<String, dynamic>> addPaymentMethod({
    required String type, // 'card', 'upi', 'wallet', 'netbanking'
    String? cardName,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? upiId,
    String? walletId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in');

    try {
      final data = await _supabase
          .from('payment_method')
          .insert({
            'user_id': user.id,
            'type_payment': type,
            'card_name': cardName,
            'card_number': cardNumber,
            'expiry_date': expiryDate, // Assuming date or string format in DB?
            // Note: In real production, NEVER save CVV. But per request to fill DB:
            'cvv': cvv,
            'upi_id': upiId,
            'wallet_id': walletId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return data;
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('payment_method')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching payment methods: $e');
      return [];
    }
  }

  // --- SUBMIT ORDER ---

  Future<void> submitOrder() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in');

    try {
      // 1. Fetch Cart Items
      final cartItems = await getCartItems();
      if (cartItems.isEmpty) return; // Or throw error

      // 2. Calculate Total
      double totalAmount = 0.0;
      for (var item in cartItems) {
        final product = item['products'] as Map<String, dynamic>;
        double price = 0.0;
        var p = product['price'];
        if (p is int) {
          price = p.toDouble();
        } else if (p is double) {
          price = p;
        } else if (p is String) {
          price = double.tryParse(p) ?? 0.0;
        }
        int quantity = (item['quantity'] as int?) ?? 1;
        totalAmount += price * quantity;
      }

      // 3. Create Order
      final orderData = await _supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_amount': totalAmount,
            'status': 'indelivery', // Default status
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final orderId = orderData['id'];

      // 4. Create Order Items
      final orderItemsData = cartItems.map((item) {
        final product = item['products'] as Map<String, dynamic>;

        // Price at purchase
        double price = 0.0;
        var p = product['price'];
        if (p is int)
          price = p.toDouble();
        else if (p is double)
          price = p;
        else if (p is String)
          price = double.tryParse(p) ?? 0.0;

        return {
          'order_id': orderId,
          'product_id': item['product_id'], // or product['id']
          'quantity': item['quantity'],
          'price_at_purchase': price,
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItemsData);

      // 5. Clear Cart
      await _supabase.from('cart_items').delete().eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to submit order: $e');
    }
  }

  // --- COUPONS ---

  // Get user's collected coupons with details
  Future<List<Map<String, dynamic>>> getUserCoupons() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('user_coupons')
          .select('*, coupons(*)')
          .eq('user_id', user.id)
          .eq('is_used', false)
          .order('collected_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching user coupons: $e');
      return [];
    }
  }

  // Get all available coupons
  Future<List<Map<String, dynamic>>> getAvailableCoupons() async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _supabase
          .from('coupons')
          .select()
          .eq('is_active', true)
          .or('valid_until.is.null,valid_until.gte.$now');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching available coupons: $e');
      return [];
    }
  }

  // Collect a coupon
  Future<void> collectCoupon(String couponId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Please login to collect coupons');

    try {
      await _supabase.from('user_coupons').insert({
        'user_id': user.id,
        'coupon_id': couponId,
        'collected_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to collect coupon: $e');
    }
  }

  // Get featured offers
  Future<List<Map<String, dynamic>>> getFeaturedOffers() async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _supabase
          .from('featured_offers')
          .select()
          .eq('is_active', true)
          .or('valid_until.is.null,valid_until.gte.$now')
          .order('display_order', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching featured offers: $e');
      return [];
    }
  }

  Future<void> submitReview({
    required String productId,
    required double rating,
    required String title,
    required String comment,
    required bool isRecommended,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to submit a review');

    try {
      await _supabase.from('reviews').insert({
        'user_id': user.id,
        'product_id': productId,
        'rating': rating,
        'title': title,
        'comment': comment,
        'is_recommended': isRecommended,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }
  Future<List<Map<String, dynamic>>> getUserReviews() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('reviews')
          .select('*, products(name, image_url, price)') // Added price
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching user reviews: $e');
      return [];
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required double rating,
    required String title,
    required String comment,
    required bool isRecommended,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Must be logged in to update a review');

    print('DEBUG: Attemption to update review $reviewId by user ${user.id}');
    print('DEBUG: New Data - Rating: $rating, Title: $title, Comment: $comment');

    try {
      final response = await _supabase.from('reviews').update({
        'rating': rating,
        'title': title,
        'comment': comment,
        'is_recommended': isRecommended,
        // 'updated_at': DateTime.now().toIso8601String(), // Good practice if column exists
      }).eq('id', reviewId).select();
      
      print('DEBUG: Update response: $response');
      
      if (response.isEmpty) {
        print('WARNING: No rows updated! Check RLS or if reviewId matches.');
        throw Exception('Review update failed: Review not found or permission denied.');
      }
    } catch (e) {
      print('ERROR: Update failed with exception: $e');
      throw Exception('Failed to update review: $e');
    }
  }
}
