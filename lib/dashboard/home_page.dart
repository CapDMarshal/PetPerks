import 'package:flutter/material.dart';
import '../products/product_detail_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../products/product_list_page.dart';
import '../notifications/notification_screen.dart';
import '../search/search_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../category/category_screen.dart';

import '../services/api_service.dart';
import '../auth/login_page.dart';

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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// HomePage wrapper - kept for backward compatibility
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageContent();
  }
}

/// HomePageContent - The actual home page content without bottom nav
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  // Kunci untuk mengontrol Drawer (sidebar)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true; // Untuk Preloader
  String _displayName = 'Guest'; // Default display name
  String _email = 'guest@example.com'; // Default email
  String? _avatarUrl;

  // Cart State
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoadingCart = true;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _fetchCartItems(); // Fetch cart items on init
    // Simulate loading time (preloader)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchCartItems() async {
    print("DEBUG: _fetchCartItems called (in HomePage)");
    try {
      final items = await _dataService.getCartItems();
      print("DEBUG: _fetchCartItems items received: $items");
      if (mounted) {
        setState(() {
          _cartItems = items;
          _isLoadingCart = false;
        });
      }
    } catch (e) {
      print("DEBUG: Error fetching cart items in HomePage: $e");
      if (mounted) {
        setState(() {
          _cartItems = [];
          _isLoadingCart = false;
        });
      }
    }
  }

  final DataService _dataService = DataService();

  void _setupAuthListener() {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final Session? session = data.session;
      final User? user =
          session?.user ?? Supabase.instance.client.auth.currentUser;

      if (mounted) {
        if (user != null) {
          // Try to get from metadata first for immediate feedback
          String name = user.userMetadata?['display_name'] ??
              user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              'Guest';

          setState(() {
            _displayName = name;
            _email = user.email ?? 'guest@example.com';
          });

          // Fetch full profile from DB to be accurate
          try {
            final profile = await _dataService.getProfile();
            if (mounted) {
              setState(() {
                _displayName = profile['display_name'] ?? name;
                _avatarUrl = profile['avatar_url'];
              });
            }
          } catch (e) {
            print('Error fetching profile on home: $e');
          }
        } else {
          setState(() {
            _displayName = 'Guest';
            _email = 'guest@example.com';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(),
          drawer: _buildDrawer(),
          body: _buildBody(),
        ),
        // Preloader
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.9),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  /// Membangun AppBar (Header)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // Nonaktifkan tombol drawer default
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 0,
      // Bagian Kiri (Menu Toggler)
      leading: InkWell(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: Container(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.grey[200],
                  child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? Image.network(
                          _avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person,
                                  size: 24, color: Colors.grey),
                        )
                      : const Icon(Icons.person, size: 24, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      // Bagian Tengah (Greeting)
      title: Text(
        "Hello, $_displayName",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Bagian Kanan (Ikon)
      actions: [
        // Ikon Notifikasi dengan Badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black,
                size: 24,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
          ],
        ),
        // Ikon Search
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 24),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Membangun Drawer (Sidebar)
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Author Box (Header Drawer)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? Image.network(
                          _avatarUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 60),
                        )
                      : Image.asset(
                          'assets/images/avatar/chat/2.png', // Fallback local
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 60),
                        ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_displayName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_email, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          // Nav Links - Scrollable area
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  Icons.home,
                  "Home",
                  isActive: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  Icons.shopping_bag_outlined,
                  "Products",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProductListPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.star_border,
                  "Featured",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProductListPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.favorite_border,
                  "Wishlist",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.shopping_cart_outlined,
                  "My Cart",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.person_outline,
                  "Profile",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  Icons.logout,
                  "Logout",
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Capture the navigator from the PARENT context (the page), not the dialog
                              final navigator = Navigator.of(context);

                              Navigator.pop(dialogContext); // Close dialog

                              try {
                                // Sign out from Supabase
                                await Supabase.instance.client.auth.signOut();

                                // Navigate immediately using the captured navigator
                                navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                print('Error logging out: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Error logging out: $e')),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                // Sidebar Bottom
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text("Dark Mode"),
                  trailing: Switch(
                    value:
                        false, // Ganti dengan state management (Provider, dll)
                    onChanged: (bool value) {
                      // Logika ganti tema
                    },
                  ),
                ),
              ],
            ),
          ),
          // Footer - Fixed at bottom
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: const Column(
              children: [
                Text(
                  "PetPerks Pet Care Shop",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "App Version 1.0",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk item drawer
  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  /// Membangun Body (Main Content)
  Widget _buildBody() {
    return SingleChildScrollView(
      // Padding untuk `space-top` dan `container`
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(),
          _buildCategorySection(),
          _buildProductSection(
            "Reliable Healthy Food For Your Pet",
          ),
          _buildPeopleAlsoViewedSection(),
          _buildCartSection(),
          _buildWishlistSection(),
          _buildFeaturedNowSection(),
          _buildFeaturedOfferSection(),
          _buildGreatSavingSection(),
        ],
      ),
    );
  }

  /// Widget untuk Banner (Swiper)
  Widget _buildBanner() {
    final List<Widget> bannerItems = [
      _buildBannerItem(
        'assets/images/banner/pic1.png',
        'We Give Preference To Your Pets',
      ),
      _buildBannerItem(
        'assets/images/banner/pic1.png',
        'Another Great Offer for Pets',
      ),
      _buildBannerItem(
        'assets/images/banner/pic1.png',
        'Shop Now and Save Big!',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          viewportFraction: 1.0,
        ),
        items: bannerItems,
      ),
    );
  }

  Widget _buildBannerItem(String imagePath, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Plus free shipping on \$99+ orders!",
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductListPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text("Adopt A Pet"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.pets, size: 60, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Title Bar
  // `onTap` allows sections to provide custom action for the actionText (eg. navigate to a new screen)
  Widget _buildTitleBar(
    String title,
    String actionText, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: onTap ?? () {},
            child: Text(
              actionText,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk Kategori Grid
  Widget _buildCategorySection() {
    return Column(
      children: [
        _buildTitleBar(
          "Find Best Pet For You",
          "See All",
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CategoryScreen()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildCategoryGridItem("Dogs", "assets/dog.jpg"),
              _buildCategoryGridItem("Cats", "assets/cat.jpg"),
              _buildCategoryGridItem("Rabbits", "assets/rabbit.jpg"),
              _buildCategoryGridItem("Parrot", "assets/parrot.jpg"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGridItem(String name, String imagePath) {
    return InkWell(
      onTap: () {
        // Map display name to DB value (simple singularization)
        String categoryParam = name;
        if (name == 'Dogs')
          categoryParam = 'Dog';
        else if (name == 'Cats')
          categoryParam = 'Cat';
        else if (name == 'Rabbits') categoryParam = 'Rabbit';

        Navigator.of(
          context,
        ).push(MaterialPageRoute(
            builder: (_) =>
                ProductListPage(initialPetCategory: categoryParam)));
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.pets, size: 80, color: Colors.grey),
            ),
            Positioned(
              bottom: 10,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white, // Asumsi teks di atas gambar
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk Tag Chip

  /// Widget untuk Produk (Nearby)
  Widget _buildProductSection(String title) {
    return Column(
      children: [
        _buildTitleBar(
          title,
          "See All",
          onTap: () {
            Navigator.of(
              context,
            ).push(
              MaterialPageRoute(
                builder: (_) =>
                    const ProductListPage(initialFilterCategory: 'Food'),
              ),
            );
          },
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
            future: DataService().getProducts(category: 'Food'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading food"));
              }
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return const Center(child: Text("No food items found"));
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75, // Sesuaikan rasio agar pas
                  children: products.take(4).map((item) {
                    return _buildProductCard(item);
                  }).toList(),
                ),
              );
            }),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // Normalisasi data untuk display dan pass ke detail page
    final String title = product['name'] ?? 'Unknown';
    final String price = "\$${product['price']}";
    final String oldPrice =
        product['old_price'] != null ? "\$${product['old_price']}" : "";
    final String imagePath = product['image_url'] ?? "";

    // Map untuk ProductDetailPage (sesuaikan dengan ekspektasi page tersebut)
    final Map<String, dynamic> productForDetail = {
      'id': product['id'],
      'name': title,
      'price': product['price'], // Kirim raw number/string
      'oldPrice': product['old_price'],
      'imagePath': imagePath, // Standardize key to imagePath
      'category': product['category'],
      'description': product['description'],
      'review': product['reviews_count'],
    };

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: productForDetail),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 150,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Image.asset(
                          imagePath,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 150,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (oldPrice.isNotEmpty)
                        Text(
                          oldPrice,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk People Also Viewed Section
  Widget _buildPeopleAlsoViewedSection() {
    return Column(
      children: [
        _buildTitleBar(
          "People Also Viewed",
          "See All",
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProductListPage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
            children: [
              _buildProductCard({
                'name': "Dog Body Belt",
                'price': "80",
                'old_price': "95",
                'image_url': "assets/belt_product.jpg",
                'category': 'Accessories',
                'description': 'High quality dog belt',
                'reviews_count': 100,
                'id': 'dummy_1',
              }),
              _buildProductCard({
                'name': "Dog Cloths",
                'price': "80",
                'old_price': "95",
                'image_url': "assets/cloths_product.jpg",
                'category': 'Clothing',
                'description': 'Warm clothes for your dog',
                'reviews_count': 50,
                'id': 'dummy_2',
              }),
              _buildProductCard({
                'name': "Pet Bed For Dog",
                'price': "80",
                'old_price': "95",
                'image_url': "assets/bed_product.jpg",
                'category': 'Bedding',
                'description': 'Comfortable bed for pets',
                'reviews_count': 200,
                'id': 'dummy_3',
              }),
              _buildProductCard({
                'name': "Dog Chew Toys",
                'price': "80",
                'old_price': "95",
                'image_url': "assets/chew_toys_product.jpg",
                'category': 'Toys',
                'description': 'Durable chew toys',
                'reviews_count': 150,
                'id': 'dummy_4',
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCartSection() {
    if (_isLoadingCart) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cartItems.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "Shop now to add items in your cart",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(
                    MaterialPageRoute(builder: (_) => const ProductListPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Shop Now"),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Items In Your Cart",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
                child: Text(
                  "View Cart",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._cartItems.map((item) {
            final product = item['products'] as Map<String, dynamic>;
            return Column(
              children: [
                _buildCartItem(
                  product['name'] ?? 'Unknown',
                  "\$${product['price']}",
                  product['old_price'] != null
                      ? "\$${product['old_price']}"
                      : "",
                  product['image_url'] ?? "",
                  quantity: item['quantity'] ?? 1,
                ),
                const Divider(height: 24),
              ],
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Proceed To Checkout (${_cartItems.length})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    String title,
    String price,
    String oldPrice,
    String imagePath, {
    required int quantity,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.pets, size: 30, color: Colors.grey),
                  ),
                )
              : Image.asset(
                  imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.pets, size: 30, color: Colors.grey),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (oldPrice.isNotEmpty)
                    Text(
                      oldPrice,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Quantity: $quantity",
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () {},
          color: Colors.grey,
        ),
      ],
    );
  }

  /// Widget untuk Add To Your Wishlist Section
  Widget _buildWishlistSection() {
    return Column(
      children: [
        _buildTitleBar(
          "Add To Your Wishlist",
          "See All",
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProductListPage()));
          },
        ),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildWishlistCard(
                "Dog Body Belt",
                "\$80",
                "\$95",
                "assets/belt_product.jpg",
                Colors.blue.shade50,
              ),
              _buildWishlistCard(
                "Dog Cloths",
                "\$80",
                "\$95",
                "assets/cloths_product.jpg",
                Colors.green.shade50,
              ),
              _buildWishlistCard(
                "Pet Bed",
                "\$80",
                "\$95",
                "assets/bed_product.jpg",
                Colors.orange.shade50,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWishlistCard(
    String title,
    String price,
    String oldPrice,
    String imagePath,
    Color backgroundColor,
  ) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with Heart Icon
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    imagePath,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.pets, size: 80, color: Colors.grey.shade400),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    color: Colors.red.shade300,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          // Product Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      oldPrice,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk Featured Now Section
  Widget _buildFeaturedNowSection() {
    return Column(
      children: [
        _buildTitleBar(
          "Featured Now",
          "See All",
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProductListPage()));
          },
        ),
        SizedBox(
          height: 140,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DataService().getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const SizedBox();
              }

              var products = snapshot.data!;

              var discountedProducts = products.where((p) {
                final price = (p['price'] as num).toDouble();
                final oldPrice = (p['old_price'] as num?)?.toDouble() ?? 0;
                return oldPrice > price;
              }).toList();

              discountedProducts.sort((a, b) {
                final priceA = (a['price'] as num).toDouble();
                final oldPriceA = (a['old_price'] as num).toDouble();
                final pctA = (oldPriceA - priceA) / oldPriceA;

                final priceB = (b['price'] as num).toDouble();
                final oldPriceB = (b['old_price'] as num).toDouble();
                final pctB = (oldPriceB - priceB) / oldPriceB;

                return pctB.compareTo(pctA);
              });

              if (discountedProducts.isEmpty) {
                return const Center(child: Text("No featured offers"));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: discountedProducts.take(5).length,
                itemBuilder: (context, index) {
                  final product = discountedProducts[index];
                  final price = (product['price'] as num).toDouble();
                  final oldPrice = (product['old_price'] as num).toDouble();
                  final percentOff =
                      ((oldPrice - price) / oldPrice * 100).round();

                  final displayProduct = Map<String, dynamic>.from(product);
                  displayProduct['discount_display'] = "$percentOff% Off";

                  return _buildFeaturedNowCard(displayProduct);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeaturedNowCard(Map<String, dynamic> product) {
    final String title = product['name'] ?? 'Unknown';
    final String price = "\$${product['price']}";
    final String oldPrice = "\$${product['old_price']}";
    final String discount = product['discount_display'] ?? "Offer";
    final String reviews = "${product['reviews_count'] ?? 0} Review";
    final String imagePath = product['image_url'] ?? "";

    // Map for details
    final Map<String, dynamic> productForDetail = {
      'id': product['id'],
      'name': title,
      'price': product['price'],
      'oldPrice': product['old_price'],
      'imagePath': imagePath,
      'category': product['category'],
      'description': product['description'],
      'review': product['reviews_count'],
    };

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: productForDetail),
            ),
          );
        },
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.pets,
                            size: 40,
                            color: Colors.grey.shade400),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.pets,
                            size: 40,
                            color: Colors.grey.shade400),
                      ),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          oldPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          reviews,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        discount,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk Featured Offer For You Section
  Widget _buildFeaturedOfferSection() {
    return Column(
      children: [
        _buildTitleBar(
          "Featured Offer For You",
          "See All",
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProductListPage()));
          },
        ),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFeaturedOfferCard(
                "Opening Promotion",
                "20%",
                "Get Flat \$75 Back",
                "Up to 40% Off",
                "assets/opening_offer.jpeg",
                Colors.yellow.shade100,
              ),
              _buildFeaturedOfferCard(
                "Pet Sitting",
                "35%",
                "Get Flat \$75 Back",
                "Up to 40% Off",
                "assets/pet_sitting.jpg",
                Colors.purple.shade600,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeaturedOfferCard(
    String title,
    String discount,
    String subtitle1,
    String subtitle2,
    String imagePath,
    Color backgroundColor,
  ) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with badge
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.pets,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle1,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle2,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text(
                "Collect Now",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk Great Saving On Everyday Essentials Section
  Widget _buildGreatSavingSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Great Saving On Everyday Essentials",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Up to 60% off + up to \$107 Cash Back",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: [
              _buildGreatSavingCard(
                "Dog Body Belt",
                "\$80",
                "\$95",
                "Free delivery",
                "assets/belt_product.jpg",
                Colors.blue.shade50,
              ),
              _buildGreatSavingCard(
                "Dog Cloths",
                "\$80",
                "\$95",
                "Free delivery",
                "assets/cloths_product.jpg",
                Colors.green.shade50,
              ),
              _buildGreatSavingCard(
                "Pet Bed For Dog",
                "\$80",
                "\$95",
                "Free delivery",
                "assets/bed_product.jpg",
                Colors.orange.shade50,
              ),
              _buildGreatSavingCard(
                "Dog Chew Toys",
                "\$80",
                "\$95",
                "Free delivery",
                "assets/chew_toys_product.jpg",
                Colors.pink.shade50,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGreatSavingCard(
    String title,
    String price,
    String oldPrice,
    String deliveryText,
    String imagePath,
    Color backgroundColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.pets, size: 60, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      oldPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  deliveryText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
