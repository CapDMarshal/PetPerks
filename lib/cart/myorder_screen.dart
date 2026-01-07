import 'package:flutter/material.dart';
import 'dart:async';
import 'package:petperks/profile/components/track-order.dart';
import 'package:petperks/profile/components/reviews.dart';
import '../services/api_service.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  bool _isOngoingSelected = true;
  bool _isLoading = true;
  final DataService _dataService = DataService();
  List<Map<String, dynamic>> _allOrders = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _startAutoCompletionCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final orders = await _dataService.getOrders();
    if (mounted) {
      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });
    }
  }

  void _startAutoCompletionCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      bool needsReload = false;
      final now = DateTime.now();

      for (var order in _allOrders) {
        final String status = order['status'] ?? 'indelivery';
        final String? createdAtStr = order['created_at'];

        if (status == 'indelivery' && createdAtStr != null) {
          final createdAt = DateTime.parse(createdAtStr);
          if (now.difference(createdAt).inMinutes >= 1) {
            // Auto-complete order
            try {
              await _dataService.updateOrderStatus(order['id'], 'delivered');
              needsReload = true;
              print('Order ${order['id']} auto-completed');
            } catch (e) {
              print('Error updating order status: $e');
            }
          }
        }
      }

      if (needsReload) {
        _loadOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Flatten orders into a list of items
    final List<Map<String, dynamic>> displayItems = [];

    for (var order in _allOrders) {
      final status = order['status'] as String? ?? 'indelivery';
      // Filter based on status
      bool match = false;
      if (_isOngoingSelected) {
        if (status == 'indelivery') match = true;
      } else {
        if (status == 'delivered' || status == 'canceled') match = true;
      }

      if (match) {
        final items = order['order_items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final product = item['products'] as Map<String, dynamic>?;
          displayItems.add({
            'title': product?['name'] ?? 'Unknown Product',
            'price': item['price_at_purchase'].toString(),
            'quantity': item['quantity'],
            'status': status,
            // 'icon': Icons.pets, // Could be dynamic if we had category
          });
        }
      }
    }

    // Sort: 'indelivery' first, then by date descending (implicit from DB usually)
    // But since we flatten, we might want to ensure ongoing is at top if mixed?
    // Actually the tabs separate them.


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
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

                // --- List of Items ---
                Expanded(
                  child: displayItems.isEmpty
                      ? const Center(child: Text('No orders found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: displayItems.length,
                          itemBuilder: (context, index) {
                            final item = displayItems[index];

                            return _OrderItemCard(
                              title: item['title'],
                              icon: Icons.shopping_bag,
                              imageColor: const Color(0xFFD4E5E2),
                              isOngoing: _isOngoingSelected,
                              price: item['price'],
                              itemCount: item['quantity'],
                              status: item['status'],
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

// --- _OrderItemCard (Updated) ---
class _OrderItemCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color imageColor;
  final bool isOngoing;
  final String price;
  final int itemCount;
  final String status;

  const _OrderItemCard({
    required this.title,
    required this.icon,
    required this.imageColor,
    required this.isOngoing,
    required this.price,
    required this.itemCount,
    required this.status,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Text(
                      'Qty: $itemCount',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status == 'indelivery' ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isOngoing)
                      const Text(
                        'In Transit', // Placeholder
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      )
                    else
                      Container(),

                    ElevatedButton(
                      onPressed: () {
                        if (isOngoing) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TrackOrderPage(),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const WriteReviewPage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(isOngoing ? 'Track Order' : 'Write Review'),
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
