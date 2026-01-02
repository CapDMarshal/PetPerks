import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart'; // Contains DataService
import 'add_edit_product_page.dart';
import 'product_detail_page.dart';
import '../search/search_screen.dart';
import '../cart/cart_screen.dart';
import 'widgets/product_item_card.dart';
import 'widgets/product_list_row.dart';
import 'widgets/gender_bottom_sheet.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'widgets/filter_bottom_sheet.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  bool _isListView = false;

  // --- 1. TAMBAHAN: State untuk mengelola filter chips ---
  final List<String> _filterCategories = [
    'Crazy Deals',
    'Budget Buys',
    'Best Offer',
    'Vouchers',
    'Top Rated',
    'Newest',
  ];
  // Menyimpan kategori chip yang sedang aktif
  String _selectedFilterCategory = 'Crazy Deals';
  // --- Akhir Tambahan ---

  final DataService _dataService = DataService();
  List<Map<String, dynamic>> products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final fetchedProducts = await _dataService.getProducts();
    if (mounted) {
      setState(() {
        products = fetchedProducts
            .map(
              (p) => {
                'name': p['name'],
                'price': (p['price'] as num).toDouble(), // Safe cast
                'oldPrice': p['old_price'] != null
                    ? (p['old_price'] as num).toDouble()
                    : null,
                'review': p['reviews_count'] ?? 0,
                'imagePath':
                    p['image_url'] ?? 'assets/belt_product.jpg', // Fallback
                'id': p['id'].toString(), // Ensure ID is passed
                'description': p['description'],
                'category': p['category'],
              },
            )
            .toList();
        _isLoading = false;
      });
    }
  }

  void _toggleView() {
    setState(() {
      _isListView = !_isListView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildCustomAppBar(context),
      body: Column(
        children: [
          // Widget ini akan memanggil _buildFilterChips yang sudah dimodifikasi
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildBanner(),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _isListView
                              ? _buildListView()
                              : _buildGridView(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    // Only show FAB if user is logged in
    if (Supabase.instance.client.auth.currentUser == null) return null;

    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditProductPage()),
        );
        if (result == true) {
          _loadProducts(); // Refresh list if product added
        }
      },
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildListView() {
    return Column(
      children: products
          .map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: product),
                    ),
                  );
                  // Refresh jika ada perubahan (edit/delete)
                  if (result == true) {
                    _loadProducts();
                  }
                },
                child: ProductListRow(product: product),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
              ),
            );
            // Refresh jika ada perubahan (edit/delete)
            if (result == true) {
              _loadProducts();
            }
          },
          child: ProductItemCard(
            productId: product['id'], // Pass product ID
            name: product['name'],
            price: product['price'],
            oldPrice: product['oldPrice'],
            imagePath: product['imagePath'],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
        },
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const TextField(
            enabled: false,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
              hintText: 'Search Product',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isListView ? Icons.grid_view : Icons.list,
            color: Colors.black,
          ),
          onPressed: _toggleView,
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                child: const Text(
                  '14',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // --- 2. MODIFIKASI: Mengganti _buildFilterChips ---
  Widget _buildFilterChips() {
    // Mengganti Row statis menjadi ListView.builder yang dinamis
    return Padding(
      // Menambahkan padding vertikal agar konsisten dengan desain lama
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height:
            35, // Tinggi yang pas untuk chip (konsisten dengan SearchScreen)
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // Padding horizontal sekarang diatur oleh ListView
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _filterCategories.length,
          itemBuilder: (context, index) {
            final category = _filterCategories[index];
            // Cek apakah chip ini sedang dipilih
            final isSelected = category == _selectedFilterCategory;

            return Padding(
              // Jarak antar chip
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text(category),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                // Ganti warna latar belakang berdasarkan state isSelected
                backgroundColor: isSelected ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    // Ganti warna border berdasarkan state isSelected
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                onPressed: () {
                  // Update state saat chip ditekan
                  setState(() {
                    _selectedFilterCategory = category;
                    // TODO: Di sini Anda bisa menambahkan logika
                    // untuk memfilter daftar 'products' berdasarkan 'category'
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
  // --- Akhir Modifikasi ---

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1F3D78),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Damar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Agency WordPress Theme',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'BUY NOW',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context,
            Icons.person_outline,
            'GENDER',
            const GenderBottomSheet(),
          ),
          _buildActionButton(
            context,
            Icons.arrow_upward,
            'SORT',
            const SortBottomSheet(),
          ),
          _buildActionButton(
            context,
            Icons.filter_list,
            'FILTER',
            const FilterBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Widget modalContent,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: label == 'FILTER',
            builder: (context) => modalContent,
            backgroundColor: Colors.transparent,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 20),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
