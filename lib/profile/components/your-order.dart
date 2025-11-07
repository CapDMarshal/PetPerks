import 'package:flutter/material.dart';
import 'track-order.dart'; // Pastikan file ini ada

class YourOrderPage extends StatefulWidget {
  const YourOrderPage({super.key});

  @override
  State<YourOrderPage> createState() => _YourOrderPageState();
}

class _YourOrderPageState extends State<YourOrderPage> {
  bool isOngoing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Order',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.black),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Tab Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Ongoing',
                    isOngoing,
                    () {
                      setState(() {
                        isOngoing = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    'Completed',
                    !isOngoing,
                    () {
                      setState(() {
                        isOngoing = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Order List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildOrderItem(
                  context,
                  'Dog Body Belt',
                  '\$80',
                  '\$95',
                  'Qty: 2',
                  'In Delivery',
                  '40% Off',
                  Colors.orange[100]!,
                  'https://via.placeholder.com/200x200/FFE0B2/000000?text=Dog+Belt',
                  isOngoing ? 'Track Order' : 'Write Review',
                ),
                _buildOrderItem(
                  context,
                  'Pet Bed For Dog',
                  '\$80',
                  '\$95',
                  'Qty: 2',
                  'In Delivery',
                  '40% Off',
                  Colors.blue[100]!,
                  'https://via.placeholder.com/200x200/BBDEFB/000000?text=Pet+Bed',
                  isOngoing ? 'Track Order' : 'Write Review',
                ),
                _buildOrderItem(
                  context,
                  'Dog Cloths',
                  '\$80',
                  '\$95',
                  'Qty: 2',
                  'In Delivery',
                  '40% Off',
                  Colors.green[100]!,
                  'https://via.placeholder.com/200x200/C8E6C9/000000?text=Dog+Cloths',
                  isOngoing ? 'Track Order' : 'Write Review',
                ),
                _buildOrderItem(
                  context,
                  'Dog Chew Toys',
                  '\$80',
                  '\$95',
                  'Qty: 2',
                  'In Delivery',
                  '40% Off',
                  Colors.pink[100]!,
                  'https://via.placeholder.com/200x200/F8BBD0/000000?text=Chew+Toys',
                  isOngoing ? 'Track Order' : 'Write Review',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET TOMBOL (dipisahkan dari _buildOrderItem) ---
  Widget _buildActionButton(BuildContext context, String buttonText) {
    return ElevatedButton(
      onPressed: () {
        if (buttonText == 'Track Order') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TrackOrderPage()),
          );
        } else {
          // Handle Write Review
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Write Review feature coming soon')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // --- WIDGET ITEM PESANAN (MODIFIKASI UTAMA DI SINI) ---
  Widget _buildOrderItem(
    BuildContext context,
    String title,
    String price,
    String originalPrice,
    String quantity,
    String status,
    String discount,
    Color backgroundColor,
    String imageUrl,
    String buttonText,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row( // Menggunakan Row agar tidak perlu Column terluar lagi
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.pets, size: 50);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Product Details (Expanded)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // --- BARIS DETAIL (Harga, Qty, dan Tombol) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Penting untuk penataan
                  children: [
                    // Kolom Detail Harga & Qty
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Harga
                        Row(
                          children: [
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              originalPrice,
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Qty: 2
                        Text(
                          quantity,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(), // Spacer mendorong tombol ke kanan
                    
                    // Tombol (Track Order / Write Review)
                    SizedBox(
                      width: 120, // Batasi lebar tombol
                      child: _buildActionButton(context, buttonText),
                    ),
                  ],
                ),
                // --- Akhir BARIS DETAIL ---
                
                const SizedBox(height: 8),

                // Status dan Discount (di bawah baris detail)
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  discount,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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