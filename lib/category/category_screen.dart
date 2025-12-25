import 'package:flutter/material.dart';
import 'widgets/category_card.dart'; 
import 'widgets/product_card.dart';
import 'search_screen.dart';
import '../products/product_list_page.dart'; // Product list moved to products folder

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna latar belakang dari CategoryPage (0xFFF9F9F9)
      backgroundColor: const Color(0xFFF9F9F9), 
      appBar: AppBar(
        // Menggunakan properti AppBar dari CategoryPage
        backgroundColor: Colors.white,
        elevation: 0.5,
        // Menggunakan title 'Categories' dari CategoryScreen awal, 
        // tapi dengan style dari CategoryPage
        title: const Text(
          'Categories', // Judul sesuai CategoryScreen awal
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // Menambahkan action button (Search) dari CategoryPage
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
          ),
        ],
        // Menghilangkan foregroundColor/title color lama karena sudah diset di style title
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Header/Slogan ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Explore The World Of Pet Care\nAnd Find Your Furry Friends!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),

            // --- Bagian Kategori Utama (GridView) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
                children: const [
                  CategoryCard(
                      categoryName: 'Dogs',
                      imagePath: 'assets/dog.jpg',
                      backgroundColor: Color(0xFFFFECEC)),
                  CategoryCard(
                      categoryName: 'Cats',
                      imagePath: 'assets/cat.jpg',
                      backgroundColor: Color(0xFFFFF7EB)),
                  CategoryCard(
                      categoryName: 'Rabbits',
                      imagePath: 'assets/rabbit.jpg',
                      backgroundColor: Color(0xFFE9FBF3)),
                  CategoryCard(
                      categoryName: 'Parrot',
                      imagePath: 'assets/parrot.jpg',
                      backgroundColor: Color(0xFFEBF6FF)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- Bagian Judul Produk/Aksesoris ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Pet Fashion And Accessories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- Bagian Daftar Produk (GridView) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
                children: [
                  ProductCard(
                      productName: 'Belt',
                      itemCount: 24,
                      imagePath: 'assets/belt.jpg',
                      backgroundColor: const Color(0xFFFFF7EB),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProductListPage()));
                      }),
                  ProductCard(
                      productName: 'Pillow',
                      itemCount: 24,
                      imagePath: 'assets/pillow.jpg',
                      backgroundColor: const Color(0xFFEBF6FF),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProductListPage()));
                      }),
                  ProductCard(
                      productName: 'Cloths',
                      itemCount: 24,
                      imagePath: 'assets/cloths.jpg',
                      backgroundColor: const Color(0xFFE9FBF3),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProductListPage()));
                      }),
                  ProductCard(
                      productName: 'Chew Toys',
                      itemCount: 24,
                      imagePath: 'assets/chew_toys.jpg',
                      backgroundColor: const Color(0xFFFFECEC),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProductListPage()));
                      }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
