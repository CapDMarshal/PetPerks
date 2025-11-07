import 'package:flutter/material.dart';
import 'package:petperks/category/search_screen.dart'; 
import 'package:petperks/cart/cart_screen.dart';

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

class ProductDetail {
  final String title;
  final String category;
  final double rating;
  final int reviews;
  final double price;
  final double oldPrice;
  final List<String> imageUrls;
  final List<String> availableSizes;
  final List<Color> availableColors;
  final String description;

  const ProductDetail({
    required this.title, required this.category, required this.rating, required this.reviews, required this.price, 
    required this.oldPrice, required this.imageUrls, required this.availableSizes, required this.availableColors, required this.description,
  });
}

// Data dummy dengan path assets yang sudah diperbarui
final List<Product> dummyWishlist = [
  const Product(id: 'p1', name: 'Dog Body Belt', imageUrl: 'assets/belt.jpg', price: 80.00, oldPrice: 95.00, category: 'Body Belt'),
  const Product(id: 'p2', name: 'Dog Cloths', imageUrl: 'assets/cloths.jpg', price: 80.00, oldPrice: 95.00, category: 'Dog Cloths'),
  const Product(id: 'p3', name: 'Pet Bed For Dog', imageUrl: 'assets/bed_product.jpg', price: 80.00, oldPrice: 95.00, category: 'Ped Food'),
  const Product(id: 'p4', name: 'Dog Chew Toys (Bone)', imageUrl: 'assets/chew_toys.jpg', price: 80.00, oldPrice: 95.00, category: 'Ball'),
  const Product(id: 'p5', name: 'Dog Pillow', imageUrl: 'assets/pillow.jpg', price: 80.00, oldPrice: 95.00, category: 'Body Belt'),
  const Product(id: 'p6', name: 'Dog Ball (Green)', imageUrl: 'assets/chew_toys_product.jpg', price: 80.00, oldPrice: 95.00, category: 'Ball'),
];

const ProductDetail dummyDetailData = ProductDetail(
  title: 'Fashionable Canines: Dog Clothes for Every Season', category: 'Cloth', rating: 4.5, reviews: 470, price: 270.00, oldPrice: 310.00,
  imageUrls: ['assets/cloths_product.jpg', 'assets/belt_product.jpg', 'assets/chew_toys_product.jpg', ],
  availableSizes: ['S', 'M', 'L', 'XL', '2XI'],
  availableColors: [Color(0xFF8B0000), Color(0xFFD2B48C), Color(0xFF808080), Color(0xFF9932CC), Color(0xFF6B8E23), ],
  description: 'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humor.',
);

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
  List<Product> wishlistItems = List.from(dummyWishlist);
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Body Belt', 'Ped Food', 'Dog Cloths', 'Ball'];

  void _changeCategory(String category) { setState(() { _selectedCategory = category; }); }
  List<Product> _getFilteredProducts() {
    if (_selectedCategory == 'All') { return wishlistItems; } 
    return wishlistItems.where((item) => item.category == _selectedCategory).toList();
  }
  void _removeItem(String productId) {
    setState(() { wishlistItems.removeWhere((item) => item.id == productId); });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item dihapus dari Wishlist!')));
  }
  
  // Fungsi ini sekarang tidak lagi berisi navigasi, navigasi diurus di ProductCard
  void _addToCart(String productId) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item ditambahkan ke Keranjang!')));
  }

  double _calculateTotal() {
    return wishlistItems.fold(0.0, (sum, item) => sum + item.price);
  }

  void _navigateToSearchScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen(),));
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();
    final totalItems = wishlistItems.length;
    final totalPrice = _calculateTotal();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.white, elevation: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWishlistHeader(context, totalItems, totalPrice),
          _buildCategoryTabs(),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10,),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(product: product, onRemove: () => _removeItem(product.id), onAddToCart: () => _addToCart(product.id));
                },
              ),
            ),
          ),
        ],
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
              IconButton(icon: const Icon(Icons.search, size: 28), onPressed: () => _navigateToSearchScreen(context)),
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
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const ProductCard({required this.product, required this.onRemove, required this.onAddToCart, super.key,});

  void _navigateToDetailScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductDetailScreen(details: dummyDetailData),
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

class ProductDetailScreen extends StatelessWidget {
  final ProductDetail details;

  const ProductDetailScreen({required this.details, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Product Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              // PERUBAHAN 2: Navigasi ke CartScreen dari AppBar Detail
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 28), onPressed: () => _navigateToCartScreen(context)), 
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 1.5)),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: const Text('14', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ProductDetailContent(details: details),
      // PERUBAHAN 3: Menambahkan tombol "Add to Cart" di bottomNavigationBar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: ElevatedButton(
          onPressed: () {
            // Memberi feedback bahwa produk ditambahkan
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk ditambahkan ke Keranjang!')));
            // Navigasi ke CartScreen
            _navigateToCartScreen(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class ProductDetailContent extends StatefulWidget {
  final ProductDetail details;

  const ProductDetailContent({required this.details, super.key});

  @override
  State<ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends State<ProductDetailContent> {
  int _quantity = 2; 
  String _selectedSize = 'M';
  Color _selectedColor = const Color(0xFF8B0000); 
  
  void _incrementQuantity() { setState(() { _quantity++; }); }
  void _decrementQuantity() { if (_quantity > 1) { setState(() { _quantity--; }); } }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(context, details.imageUrls), 
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndRating(details),
                const SizedBox(height: 12),
                _buildPriceAndQuantity(details),
                const SizedBox(height: 20),
                _buildSizeOptions(details.availableSizes),
                const SizedBox(height: 20),
                _buildColorOptions(details.availableColors),
                const SizedBox(height: 20),
                _buildDescription(details.description),
                const SizedBox(height: 100), // Memberi ruang agar tombol Add to Cart di bottomBar tidak tertutup
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageGallery(BuildContext context, List<String> imageUrls) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45, 
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          PageView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) { 
              return Container(
                alignment: Alignment.center, 
                color: Colors.transparent, // Warna latar belakang dihapus
                child: Image.asset(imageUrls[index], fit: BoxFit.contain), // BoxFit.contain untuk fit
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: IconButton(icon: const Icon(Icons.favorite_border, color: Colors.grey), onPressed: () {}),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitleAndRating(ProductDetail details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(details.category, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(details.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), const SizedBox(width: 4), Text('${details.rating.toString()} (${details.reviews})', style: const TextStyle(fontSize: 14)),]),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPriceAndQuantity(ProductDetail details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Price:', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Row(children: [
            Text('\$${details.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('\$${details.oldPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
          ]),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Quantity:', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Row(children: [
            _buildQuantityButton(Icons.remove, _decrementQuantity),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            _buildQuantityButton(Icons.add, _incrementQuantity),
          ]),
        ]),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
      child: InkWell(onTap: onPressed, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(icon, size: 20, color: Colors.black))),
    );
  }

  Widget _buildSizeOptions(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Items Size:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(children: sizes.map((size) {
            final isSelected = size == _selectedSize;
            return Padding(padding: const EdgeInsets.only(right: 8.0), child: ChoiceChip(
                label: Text(size), selected: isSelected, selectedColor: Colors.black,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.black : Colors.grey)),
                onSelected: (selected) { if (selected) { setState(() { _selectedSize = size; }); }},
            ));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOptions(List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Items Color:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(children: colors.map((color) {
            final isSelected = color == _selectedColor;
            return Padding(padding: const EdgeInsets.only(right: 12.0), child: GestureDetector(
                onTap: () { setState(() { _selectedColor = color; }); },
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2)),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                ),
            ));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}