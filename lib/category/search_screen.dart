import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Data dummy untuk Kategori
  final List<String> _categories = [
    'Dogs Food',
    'Cats Food',
    'Rabbits Food',
    'Parrot Food',
    'Bird Food',
    'Fish Food',
  ];

  // Data dummy untuk Riwayat Pencarian
  List<String> _searchHistory = [
    'Dogs Food',
    'Cats Food',
    'Rabbits Food',
    'Parrot Food',
    'Dog Body Belt',
  ];

  // Kategori yang sedang aktif (untuk tampilan Toggle Chip)
  String _selectedCategory = 'Dogs Food';

  // Fungsi untuk menghapus semua riwayat
  void _clearSearchHistory() {
    setState(() {
      _searchHistory = [];
    });
    // Menampilkan feedback ke user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search history cleared!')),
    );
  }

  // Fungsi untuk menghapus satu item riwayat
  void _removeHistoryItem(String item) {
    setState(() {
      _searchHistory.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0), // Padding di atas AppBar
          child: AppBar(
            automaticallyImplyLeading: false, // Nonaktifkan tombol back default
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                // Tombol Back (Menggunakan warna Black solid)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // Field Pencarian Kustom (menggantikan judul)
                Expanded(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.only(right: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0), // Latar belakang abu-abu terang
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Best Items For You',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // --- Bagian Categories ---
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            
            // Daftar Kategori Horizontal
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SizedBox(
                height: 35, // Tinggi yang cukup untuk Chip
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    
                    return Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: ActionChip(
                        label: Text(category),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: isSelected ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? Colors.black : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = category;
                            // TODO: Implementasi logika pencarian berdasarkan kategori
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            
            // --- Bagian Search History Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Search History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearSearchHistory,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- Bagian Search History List ---
            // Menggunakan ListView.builder di dalam Column memerlukan ShrinkWrap dan NeverScrollableScrollPhysics
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final historyItem = _searchHistory[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.access_time, color: Colors.grey, size: 20), // Icon jam
                  title: Text(
                    historyItem,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 18), // Icon close
                    onPressed: () => _removeHistoryItem(historyItem),
                  ),
                  onTap: () {
                    // TODO: Implementasi logika untuk mencari berdasarkan item riwayat
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Searching for: $historyItem')),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Contoh Penggunaan (Opsional, untuk menjalankannya) ---
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SearchScreen(),
    );
  }
}
*/