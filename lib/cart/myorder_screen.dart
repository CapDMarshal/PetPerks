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
  Set<String> _reviewedProductIds = {}; // Track reviewed products
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData(); // Changed name to reflect multiple data sources
    _startAutoCompletionCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _dataService.getOrders();
      final reviews = await _dataService.getUserReviews();
      
      final reviewedIds = reviews
          .map((r) => r['product_id'] as String)
          .toSet();

      if (mounted) {
        setState(() {
          _allOrders = orders;
          _reviewedProductIds = reviewedIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAutoCompletionCheck() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      bool needsReload = false;
      final now = DateTime.now();

      for (var order in _allOrders) {
        final String status = order['status'] ?? 'indelivery';
        final String? createdAtStr = order['created_at'];

        if (status == 'indelivery' && createdAtStr != null) {
          // Robust checking: Convert both to UTC
          final createdAt = DateTime.parse(createdAtStr).toUtc();
          final nowUtc = DateTime.now().toUtc();
          final minutesDiff = nowUtc.difference(createdAt).inMinutes;

          print('DEBUG: Order ${order['id']} diff: $minutesDiff mins. Created: $createdAt, Now: $nowUtc');

          // Change to 5 minutes as implied by user ("more than 5 minutes") 
          // or keep 1 if that was intended. User complaint implies they expect it to happen by 5 mins.
          // Let's set it to 5 to match the user's mention, or stick to logic. 
          // If the code had 1, it should have happened ALREADY. 
          // I will stick to the existing logic '1' for now but fix the comparison. 
          // Actually, let's bump to 5 if that's what a "production" app would do, 
          // but the user asked "why it didn't update", confusing. 
          // Let's keep 1 for faster testing, but ensure logging.
          
          if (minutesDiff >= 1) { 
            // Auto-complete order
            try {
              print('DEBUG: Attempting to auto-complete order ${order['id']}');
              await _dataService.updateOrderStatus(order['id'], 'delivered');
              needsReload = true;
              print('SUCCESS: Order ${order['id']} auto-completed to delivered');
            } catch (e) {
              print('ERROR: Failed to auto-complete order: $e');
            }
          }
        }
      }

      if (needsReload) {
        _loadData();
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
          print('DEBUG: Product data: $product'); // Debugging image issue
          final productId = product?['id'] as String?;
          final isReviewed = productId != null && _reviewedProductIds.contains(productId);

          displayItems.add({
            'title': product?['name'] ?? 'Unknown Product',
            'price': item['price_at_purchase'].toString(),
            'quantity': item['quantity'],
            'status': status,
            'product': product,
            'isReviewed': isReviewed,
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
                              imageUrl: item['product']?['image_url'],
                              isOngoing: _isOngoingSelected,
                              price: item['price'],
                              itemCount: item['quantity'],
                              status: item['status'],
                              product: item['product'],
                              isReviewed: item['isReviewed'] ?? false,
                              onReviewSubmitted: _loadData, // Pass reload callback
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
  final String? imageUrl;
  final bool isOngoing;
  final String price;
  final int itemCount;
  final String status;
  final Map<String, dynamic>? product;
  final bool isReviewed;
  final VoidCallback? onReviewSubmitted; // Add callback

  const _OrderItemCard({
    required this.title,
    required this.icon,
    required this.imageColor,
    this.imageUrl,
    required this.isOngoing,
    required this.price,
    required this.itemCount,
    required this.status,
    this.product,
    this.isReviewed = false,
    this.onReviewSubmitted, // Add to constructor
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
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: imageUrl!.startsWith('assets/')
                        ? Image.asset(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(icon, size: 50, color: Colors.black54),
                          )
                        : Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(icon, size: 50, color: Colors.black54),
                          ),
                  )
                : Icon(icon, size: 50, color: Colors.black54),
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
                          // If reviewed, maybe just show a snackbar or navigate to edit?
                          if (isReviewed) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You have already reviewed this product. Check "Reviews" in Profile to edit.')),
                            );
                            return;
                          }

                          // Ensure we have valid product data
                          if (product != null && product!['id'] != null) {
                             Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WriteReviewPage(product: product!),
                              ),
                            ).then((value) {
                              // Reload if value is true (submitted)
                              if (value == true || true) { // Reload anyway to be safe
                                onReviewSubmitted?.call();
                              }
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cannot review this product')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isReviewed ? Colors.green : Colors.black,
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
                      child: Text(
                        isOngoing 
                          ? 'Track Order' 
                          : (isReviewed ? 'Reviewed' : 'Write Review')
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
