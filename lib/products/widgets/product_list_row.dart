import 'package:flutter/material.dart';
import '../../wishlist/wishlist_screen.dart';
import '../../cart/cart_screen.dart';

// 1. Diubah menjadi StatefulWidget
class ProductListRow extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductListRow({super.key, required this.product});

  @override
  State<ProductListRow> createState() => _ProductListRowState();
}

class _ProductListRowState extends State<ProductListRow> {
  // 2. State untuk melacak favorit
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProductDetailScreen(details: dummyDetailData),
          ),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Produk
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.product['imagePath'].startsWith('http')
                          ? Image.network(
                              widget.product['imagePath'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.broken_image)),
                            )
                          : Image.asset(
                              widget.product['imagePath'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                    ),

                    // ===== PERUBAHAN DI SINI =====
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        // <-- Dibungkus GestureDetector
                        onTap: _toggleFavorite,
                        child: Icon(
                          // <-- Container putih dihilangkan
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border, // <-- Ikon dinamis
                          color: Colors.red,
                          size: 20, // Ukuran disesuaikan
                          // Tambahkan shadow agar terlihat jelas di atas gambar
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ===== AKHIR PERUBAHAN =====
                  ],
                ),
              ),
            ),

            // 2. Detail Produk
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product['name'], // <-- pakai 'widget.'
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              '\$${widget.product['price']}', // <-- pakai 'widget.'
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 5),
                            if (widget.product['oldPrice'] != null)
                              Text(
                                '\$${widget.product['oldPrice']}', // <-- pakai 'widget.'
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text(
                              '(${widget.product['review']}k Review)', // <-- pakai 'widget.'
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Detail Tambahan dan Tombol Keranjang
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FREE Delivery',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '40% Off',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        // Tombol Keranjang
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
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
}
