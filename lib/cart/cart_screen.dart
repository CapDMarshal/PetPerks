import 'package:flutter/material.dart';
import 'changelocation_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // --- 1. ADDED THE DATA LIST (from myorder_screen.dart) ---
  static const List<Map<String, String>> _items = [
    {
      "title": "Dog Body Belt",
      "imagePath": "assets/belt_product.jpg",
    },
    {
      "title": "Pet Bed For Dog",
      "imagePath": "assets/bed_product.jpg",
    },
    {
      "title": "Dog Cloths",
      "imagePath": "assets/cloths_product.jpg",
    },
    {
      "title": "Dog Chew Toys",
      "imagePath": "assets/chew_toys_product.jpg",
    },
    {
      "title": "Dog Pillow",
      "imagePath": "assets/pillow.jpg",
    },
  ];
  // --- END OF DATA LIST ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // --- 2. UPDATED ITEM COUNT ---
                Text(
                  '${_items.length} Items  •  Deliver To: London', // Dynamic count
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                // --- END OF UPDATE ---
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangeLocationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.location_on_outlined, size: 18),
              label: const Text('Change'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: Stack(
        children: [
          // Main cart content
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 95.0, 16.0, 100.0),
            // --- 3. MODIFIED LISTVIEW ---
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return CartItemCard(
                  title: item['title']!,
                  imagePath: item['imagePath']!,
                );
              },
            ),
            // --- END MODIFICATION ---
          ),

          // Subtotal card
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((255 * 0.2).round()),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        '\$3,599',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Your order is eligible for free Delivery',
                        style: TextStyle(fontSize: 15, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // "Proceed To Buy" button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((255 * 0.2).round()),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                ),
                // --- 4. UPDATED BUTTON TEXT ---
                child: Text(
                  'Proceed To Buy (${_items.length} Items)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // --- END UPDATE ---
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. MODIFIED CartItemCard WIDGET ---
class CartItemCard extends StatefulWidget {
  // --- ADDED PROPERTIES ---
  final String title;
  final String imagePath;

  const CartItemCard({
    super.key,
    required this.title,
    required this.imagePath,
  });
  // --- END OF ADDED PROPERTIES ---

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Widget _buildCounterButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              widget.imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(Icons.pets, size: 40, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- USE WIDGET PROPERTY (and remove const) ---
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: const [
                    Text(
                      '\$80',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '\$95',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      '(2k Review)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'FREE Delivery',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildCounterButton(
                          icon: Icons.remove,
                          onPressed: _decrementQuantity,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildCounterButton(
                          icon: Icons.add,
                          onPressed: _incrementQuantity,
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        print('Removing item...');
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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
}