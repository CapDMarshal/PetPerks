import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../products/product_list_page.dart';
import '../notifications/notification_screen.dart';
import '../search/search_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../category/category_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Mensimulasikan waktu loading (preloader)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Load user data from Firebase Auth
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _displayName = user.displayName ?? user.email?.split('@')[0] ?? 'Guest';
      });
    }
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
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
                child: Image.asset(
                  'assets/images/avatar/1.png', // Ganti dengan path aset
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                  // Tampilkan placeholder jika gambar error
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 30),
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
            color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      // Bagian Kanan (Ikon)
      actions: [
        // Ikon Notifikasi dengan Badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.black, size: 24),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '14',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
        // Ikon Search
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 24),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SearchScreen(),
              ),
            );
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
                  child: Image.asset(
                    'assets/images/avatar/chat/2.png', // Ganti path
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 60),
                  ),
                ),
                const SizedBox(width: 15),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TEst",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("example@gmail.com", style: TextStyle(fontSize: 14)),
                  ],
                )
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
                      MaterialPageRoute(
                        builder: (_) => const WishlistScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.shopping_cart_outlined,
                  "My Cart",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  Icons.person_outline,
                  "Profile",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  Icons.logout,
                  "Logout",
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Add logout logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logout functionality coming soon'),
                        duration: Duration(seconds: 2),
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
                    value: false, // Ganti dengan state management (Provider, dll)
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
          )
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
      leading: Icon(icon,
          color: isActive
              ? Theme.of(context).primaryColor
              : Colors.grey.shade700),
      title: Text(title,
          style: TextStyle(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.black,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
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
          _buildPetServicesSection(),
          _buildProductSection("Reliable Healthy Food For Your Pet", "Dogs Food"),
          _buildTestimonialSection(),
          _buildPeopleAlsoViewedSection(),
          _buildCartSection(),
          _buildPopularNearbySection(),
          _buildBlockbusterDealsSection(),
          _buildWishlistSection(),
          _buildFeaturedNowSection(),
          _buildFeaturedOfferSection(),
          _buildGreatSavingSection(),
          _buildSponsoredSection(),
        ],
      ),
    );
  }

  /// Widget untuk Banner (Swiper)
  Widget _buildBanner() {
    final List<Widget> bannerItems = [
      _buildBannerItem(
          'assets/images/banner/pic1.png', 'We Give Preference To Your Pets'),
      _buildBannerItem(
          'assets/images/banner/pic1.png', 'Another Great Offer for Pets'),
      _buildBannerItem(
          'assets/images/banner/pic1.png', 'Shop Now and Save Big!'),
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
                        fontSize: 16, fontWeight: FontWeight.bold),
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
                        MaterialPageRoute(builder: (_) => const ProductListPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text("Adopt A Pet"),
                  )
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
  Widget _buildTitleBar(String title, String actionText, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        _buildTitleBar("Find Best Category", "See All", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CategoryScreen()),
          );
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildCategoryGridItem(
                  "Dogs", "assets/dog.jpg"),
              _buildCategoryGridItem(
                  "Cats", "assets/cat.jpg"),
              _buildCategoryGridItem(
                  "Rabbits", "assets/rabbit.jpg"),
              _buildCategoryGridItem(
                  "Parrot", "assets/parrot.jpg"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGridItem(String name, String imagePath) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CategoryScreen()),
        );
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
                  shadows: [
                    Shadow(blurRadius: 2.0, color: Colors.black54)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk Layanan (Category Style 2)
  Widget _buildPetServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _buildTitleBar("Our pet care services", "See All", onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductListPage()),
            );
          }),
          // Horizontal Tags
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTagChip("Pet Grooming", isActive: true),
                _buildTagChip("Walking and sitting"),
                _buildTagChip("Dog Training"),
                _buildTagChip("Dog Boarding Kennels"),
              ],
            ),
          ),
          // About Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (Icon dan Teks 'Pet Grooming') ...
                const SizedBox(height: 10),
                const Text(
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. ...",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                // Offer Banner
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProductListPage()),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/dog_grooming.jpg",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(height: 100, color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProductListPage()),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/cat_grooming.jpeg",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(height: 100, color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper untuk Tag Chip
  Widget _buildTagChip(String label, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        backgroundColor:
            isActive ? Theme.of(context).primaryColor : Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.black,
        ),
        onPressed: () {},
      ),
    );
  }

  /// Widget untuk Produk (Nearby)
  Widget _buildProductSection(String title, String activeTag) {
    return Column(
      children: [
        _buildTitleBar(title, "See All", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        }),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildTagChip(activeTag, isActive: true),
              _buildTagChip("Cats Food"),
              _buildTagChip("Rabbits Food"),
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
            childAspectRatio: 0.75, // Sesuaikan rasio agar pas
            children: [
              _buildProductCard("Dog Body Belt", "\$80", "\$95",
                  "assets/belt_product.jpg"),
              _buildProductCard("Dog Cloths", "\$80", "\$95",
                  "assets/cloths_product.jpg"),
              _buildProductCard("Pet Bed For Dog", "\$80", "\$95",
                  "assets/bed_product.jpg"),
              _buildProductCard("Dog Chew Toys", "\$80", "\$95",
                  "assets/chew_toys_product.jpg"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
      String title, String price, String oldPrice, String imagePath) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    imagePath,
                    height: 150, // Tentukan tinggi gambar
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.pets,
                            size: 50, color: Colors.grey)),
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
                      child: Icon(Icons.favorite_border,
                          size: 20, color: Colors.grey),
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
                        fontWeight: FontWeight.bold, fontSize: 14),
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

  /// Widget untuk Testimonial Section
  Widget _buildTestimonialSection() {
    return Column(
      children: [
        _buildTitleBar("What Pet Lovers Say About Us?", "See All", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        }),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildTestimonialCard(
                name: "Kenneth Fong",
                avatarPath: "assets/images/avatar/1.png",
                review:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
              ),
              _buildTestimonialCard(
                name: "Sarah Johnson",
                avatarPath: "assets/images/avatar/2.png",
                review:
                    "Excellent service! My pet absolutely loves the products. The quality is outstanding and delivery was super fast. Highly recommended for all pet owners!",
              ),
              _buildTestimonialCard(
                name: "Mike Chen",
                avatarPath: "assets/images/avatar/3.png",
                review:
                    "Great experience shopping here. The staff is knowledgeable and the prices are very competitive. Will definitely come back for more!",
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String avatarPath,
    required String review,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  avatarPath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, size: 30),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.pets,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              review,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk People Also Viewed Section
  Widget _buildPeopleAlsoViewedSection() {
    return Column(
      children: [
        _buildTitleBar("People Also Viewed", "See All", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        }),
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
              _buildProductCard(
                "Dog Body Belt",
                "\$80",
                "\$95",
                "assets/belt_product.jpg",
              ),
              _buildProductCard(
                "Dog Cloths",
                "\$80",
                "\$95",
                "assets/cloths_product.jpg",
              ),
              _buildProductCard(
                "Pet Bed For Dog",
                "\$80",
                "\$95",
                "assets/bed_product.jpg",
              ),
              _buildProductCard(
                "Dog Chew Toys",
                "\$80",
                "\$95",
                "assets/chew_toys_product.jpg",
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Widget untuk Items In Your Cart Section
  Widget _buildCartSection() {
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
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
          _buildCartItem(
            "Dog Cloths",
            "\$80",
            "\$95",
            "assets/cloths_product.jpg",
            quantity: 1,
            reviews: "2k Review",
          ),
          const Divider(height: 24),
          _buildCartItem(
            "Pet Bed For Dog",
            "\$80",
            "\$95",
            "assets/bed_product.jpg",
            quantity: 1,
            reviews: "2k Review",
          ),
          const Divider(height: 24),
          _buildCartItem(
            "Dog Chew Toys",
            "\$80",
            "\$95",
            "assets/chew_toys_product.jpg",
            quantity: 1,
            reviews: "2k Review",
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Proceed To Checkout (3)",
                style: TextStyle(
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
    required String reviews,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
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
                  Text(
                    oldPrice,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    reviews,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Quantity: $quantity",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
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

  /// Widget untuk Popular Nearby Section
  Widget _buildPopularNearbySection() {
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
                    "Popular Nearby",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Up to 60% off + up to \$107 casHACK",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProductListPage()),
                  );
                },
                child: Text(
                  "See All",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
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
              _buildPopularNearbyCard(
                "Beagle",
                "Special Offer",
                "assets/beagle.jpg",
                Colors.orange.shade100,
              ),
              _buildPopularNearbyCard(
                "Labrador",
                "Min. 70% Off",
                "assets/labrador.jpeg",
                Colors.teal.shade100,
              ),
              _buildPopularNearbyCard(
                "Golden Retriever",
                "Best Price",
                "assets/golden_retriever.jpg",
                Colors.red.shade100,
              ),
              _buildPopularNearbyCard(
                "Poodle",
                "Limited Offer",
                "assets/poodle.jpg",
                Colors.pink.shade100,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPopularNearbyCard(
    String title,
    String subtitle,
    String imagePath,
    Color backgroundColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk Blockbuster Deals Section
  Widget _buildBlockbusterDealsSection() {
    return Column(
      children: [
        _buildTitleBar("Blockbuster Deals", "See All Deals", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        }),
        // Main Featured Product
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
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
                // Product Image
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/belt_product.jpg',
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.pets,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                // Product Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Up To 79% Off",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Fresh & Fit: Raw Food Diet For Dogs",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Horizontal Scrolling Products
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSmallProductCard(
                'assets/dog.jpg',
                Colors.orange.shade50,
              ),
              _buildSmallProductCard(
                'assets/cat.jpg',
                Colors.pink.shade50,
              ),
              _buildSmallProductCard(
                'assets/rabbit.jpg',
                Colors.blue.shade50,
              ),
              _buildSmallProductCard(
                'assets/parrot.jpg',
                Colors.orange.shade50,
              ),
              _buildSmallProductCard(
                'assets/dog.jpg',
                Colors.teal.shade50,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSmallProductCard(String imagePath, Color backgroundColor) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.pets,
            size: 40,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  /// Widget untuk Add To Your Wishlist Section
  Widget _buildWishlistSection() {
    return Column(
      children: [
        _buildTitleBar("Add To Your Wishlist", "See All", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        }),
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
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
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
        _buildTitleBar("Featured Now", "See All", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        }),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFeaturedNowCard(
                "Russell Terrier",
                "\$80",
                "\$95",
                "40% Off",
                "2k Review",
                "assets/russel.png",
              ),
              _buildFeaturedNowCard(
                "Labrador",
                "\$80",
                "\$95",
                "40% Off",
                "2k Review",
                "assets/labrador.jpeg",
              ),
              _buildFeaturedNowCard(
                "Golden Retriever",
                "\$80",
                "\$95",
                "35% Off",
                "1.8k Review",
                "assets/golden_retriever.jpg",
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeaturedNowCard(
    String title,
    String price,
    String oldPrice,
    String discount,
    String reviews,
    String imagePath,
  ) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.pets,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
    );
  }

  /// Widget untuk Featured Offer For You Section
  Widget _buildFeaturedOfferSection() {
    return Column(
      children: [
        _buildTitleBar("Featured Offer For You", "See All", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        }),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
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
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.pets,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
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

  /// Widget untuk Sponsored Section
  Widget _buildSponsoredSection() {
    return Column(
      children: [
        _buildTitleBar("Sponsored", "See All", onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductListPage()),
          );
        }),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSponsoredCard(
                "Pet Shop",
                "Min. 30% Off",
                "assets/pet_shop.jpeg",
                Colors.pink.shade100,
              ),
              _buildSponsoredCard(
                "Best Dog Food",
                "Up To 20% Off",
                "assets/dog_food.jpg",
                Colors.orange.shade100,
              ),
              _buildSponsoredCard(
                "Rabbit Food",
                "Min. 30% Off",
                "assets/rabbit_food.jpg",
                Colors.orange.shade50,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSponsoredCard(
    String title,
    String subtitle,
    String imagePath,
    Color backgroundColor,
  ) {
    return Container(
      width: 140,
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
          // Image
          Expanded(
            child: Container(
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
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}