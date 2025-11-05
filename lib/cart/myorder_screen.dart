import 'package:flutter/material.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  bool _isOngoingSelected = true;

  final List<Map<String, dynamic>> _items = [
    {
      "title": "Dog Body Belt",
      "icon": Icons.pets,
      "color": const Color(0xFFE0D9CF),
    },
    {
      "title": "Pet Bed For Dog",
      "icon": Icons.bed,
      "color": const Color(0xFFE2E6C6),
    },
    {
      "title": "Dog Cloths",
      "icon": Icons.shopping_bag,
      "color": const Color(0xFFD4E5E2),
    },
    {
      "title": "Dog Chew Toys",
      "icon": Icons.auto_awesome,
      "color": const Color(0xFFF5E0E4),
    },
    {
      "title": "Dog Body Belt",
      "icon": Icons.circle,
      "color": const Color(0xFFD4EBEB),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Order'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Handle home button tap
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Toggle Tab Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _ToggleButton(
                  text: 'Ongoing',
                  isSelected: _isOngoingSelected,
                  onPressed: () {
                    setState(() {
                      _isOngoingSelected = true;
                    });
                  },
                ),
                const SizedBox(width: 12.0),
                _ToggleButton(
                  text: 'Completed',
                  isSelected: !_isOngoingSelected,
                  onPressed: () {
                    setState(() {
                      _isOngoingSelected = false;
                    });
                  },
                ),
              ],
            ),
          ),

          // --- List of Orders ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _OrderItemCard(
                  title: item['title'],
                  icon: item['icon'],
                  imageColor: item['color'],
                  isOngoing: _isOngoingSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- _ToggleButton (Unchanged) ---
class _ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ToggleButton({
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: isSelected
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(text),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(text),
            ),
    );
  }
}

// --- !! MODIFIED _OrderItemCard !! ---
class _OrderItemCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color imageColor;
  final bool isOngoing;

  const _OrderItemCard({
    required this.title,
    required this.icon,
    required this.imageColor,
    required this.isOngoing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, size: 50, color: Colors.black54),
          ),
          const SizedBox(width: 16.0),

          // 2. Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0), // Reduced gap
                Row(
                  children: const [
                    Text(
                      '\$80',
                      style: TextStyle(
                        fontSize: 18,
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
                    SizedBox(width: 16.0), // Space between price and qty
                    Text(
                      'Qty: 2',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0), // Reduced gap
                const Text(
                  'In Delivery',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4.0), // Reduced gap
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '40% Off',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // Made button smaller
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        textStyle: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isOngoing ? 'Track Order' : 'Write Review',
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