import 'package:flutter/material.dart';
import 'package:petperks/category/search_screen.dart'; 
import 'package:petperks/cart/cart_screen.dart';
import '../services/api_service.dart';
import '../widgets/wishlist_icon_button.dart';
import '../products/product_detail_page.dart';

// ====================================================================
// MODEL DATA 📚
// ====================================================================

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double oldPrice;
  final String category;

  const Product({
    required this.id, required this.name, required this.imageUrl, required this.price, required this.oldPrice, required this.category,
  });
}

// ====================================================================
// FUNGSI NAVIGASI GLOBAL 🛒
// ====================================================================

// Fungsi bantu untuk navigasi ke CartScreen
void _navigateToCartScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CartScreen(), 
    ),
  );
}

// ====================================================================
// APLIKASI UTAMA & WISHLIST SCREEN
// ====================================================================

class WishlistApp extends StatelessWidget {
  const WishlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishlist Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity,),
      home: const WishlistScreen(),
    );
  }
}

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final DataService _dataService = DataService();
  List<Map<String, dynamic>> wishlistItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Body Belt', 'Ped Food', 'Dog Cloths', 'Ball'];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh wishlist every time this screen becomes visible
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    print('DEBUG: Loading wishlist...');
    try {
      final data = await _dataService.getWishlist();
      print('DEBUG: Wishlist loaded - ${data.length} items found');
      if (mounted) {
        setState(() {
          wishlistItems = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading wishlist: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changeCategory(String category) { setState(() { _selectedCategory = category; }); }
  
  List<Map<String, dynamic>> _getFilteredProducts() {
    if (_selectedCategory == 'All') { return wishlistItems; } 
    return wishlistItems.where((item) => item['products']['category'] == _selectedCategory).toList();
  }
  
  Future<void> _removeItem(String productId) async {
    try {
      await _dataService.removeFromWishlist(productId);
      if (mounted) {
        setState(() {
          wishlistItems.removeWhere((item) => item['product_id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item dihapus dari Wishlist!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  // Fungsi ini sekarang tidak lagi berisi navigasi, navigasi diurus di ProductCard
  void _addToCart(String productId) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item ditambahkan ke Keranjang!')));
  }

  double _calculateTotal() {
    return wishlistItems.fold(0.0, (sum, item) {
      final product = item['products'];
      final price = product != null ? (product['price'] as num?)?.toDouble() ?? 0.0 : 0.0;
      return sum + price;
    });
  }

  void _navigateToSearchScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen(),));
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = wishlistItems.length;
    final totalPrice = _calculateTotal();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.white, elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadWishlist();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildWishlistHeader(context, totalItems, totalPrice),
            ),
            SliverToBoxAdapter(
              child: _buildCategoryTabs(),
            ),
            const SliverToBoxAdapter(
              child: Divider(height: 1, color: Color(0xFFE0E0E0)),
            ),
            _buildWishlistGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistGrid() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    final filteredProducts = _getFilteredProducts();
    
    if (filteredProducts.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Your wishlist is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }
    
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = filteredProducts[index];
            final product = item['products'];
            if (product == null) return const SizedBox.shrink();
            
            // Create Product object from database data
            final productObj = Product(
              id: item['product_id'] ?? '',
              name: product['name'] ?? 'Unknown',
              price: (product['price'] as num?)?.toDouble() ?? 0.0,
              oldPrice: (product['old_price'] as num?)?.toDouble() ?? 0.0,
              imageUrl: product['image_url'] ?? 'assets/belt_product.jpg',
              category: product['category'] ?? 'Unknown',
            );
            
            // Convert database data to format expected by ProductDetailPage
            final productMap = {
              'id': item['product_id'] ?? '',
              'name': product['name'] ?? 'Unknown',
              'price': (product['price'] as num?)?.toDouble() ?? 0.0,
              'oldPrice': (product['old_price'] as num?)?.toDouble() ?? 0.0,
              'imagePath': product['image_url'] ?? 'assets/belt_product.jpg',
              'category': product['category'] ?? 'Unknown',
              'description': product['description'] ?? '',
              'review': product['reviews_count'] ?? 0,
            };
            
            return ProductCard(
              product: productObj,
              productMap: productMap,
              onRemove: () => _removeItem(item['product_id']),
              onAddToCart: () => _addToCart(item['product_id']),
            );
          },
          childCount: filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildWishlistHeader(BuildContext context, int itemCount, double total) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              const Text('Wishlist', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 28),
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await _loadWishlist();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wishlist refreshed!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(icon: const Icon(Icons.search, size: 28), onPressed: () => _navigateToSearchScreen(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('$itemCount Items • Total: \$${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: _categories.map((title) {
          return _buildTab(title, title == _selectedCategory, () => _changeCategory(title));
        }).toList(),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black),
          ),
          child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }
}

// ====================================================================
// PRODUCT CARD & DETAIL SCREEN
// ====================================================================

class ProductCard extends StatelessWidget {
  final Product product;
  final Map<String, dynamic> productMap;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const ProductCard({
    required this.product,
    required this.productMap,
    required this.onRemove,
    required this.onAddToCart,
    super.key,
  });

  void _navigateToDetailScreen(BuildContext context) {
    print('DEBUG: Navigating to ProductDetailPage with product: ${productMap['name']}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: productMap),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToDetailScreen(context),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Stack(
              alignment: Alignment.topRight,
              children: [
                Center(child: Container(
                  padding: const EdgeInsets.all(16), 
                  width: double.infinity, 
                  child: Image.asset(product.imageUrl, fit: BoxFit.contain), 
                )),
                Positioned(top: 0, right: 0, child: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: onRemove)),
              ],
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(width: 8),
                      Text('\$${product.oldPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4), 
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)), 
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20)
                ),
                // PERUBAHAN 1: Navigasi ke CartScreen dari Product Card
                onPressed: () => _navigateToCartScreen(context), 
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}