import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class TrackOrderPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? product;

  const TrackOrderPage({super.key, required this.orderId, this.product});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final DataService _dataService = DataService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _trackingSteps = [];

  @override
  void initState() {
    super.initState();
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    try {
      final steps = await _dataService.getOrderTracking(widget.orderId);
      if (mounted) {
        setState(() {
          _trackingSteps = steps;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tracking data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Product details
    final product = widget.product;
    final String title = product?['name'] ?? 'Unknown Product';
    final String? imageUrl = product?['image_url'];
    // Price might need parsing/checking type if it comes from different sources
    // In myorder_screen we handled price carefully, here let's try to display if available
    final price = product?['price'];
    String priceStr = '0';
    if (price != null) priceStr = price.toString();

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
          'Track Order',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Product Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? (imageUrl.startsWith('assets/')
                                    ? Image.asset(imageUrl, fit: BoxFit.cover)
                                    : Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.pets, size: 50),
                                      ))
                                : const Icon(Icons.pets, size: 50),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Product Details
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
                              Row(
                                children: [
                                  Text(
                                    '\$$priceStr',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // Discount logic omitted as it's not standard in product map yet
                                ],
                              ),
                              const SizedBox(height: 8),
                              // You might want to pass 'status' from previous screen if needed here
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Track Order Timeline
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Track order',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Timeline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _trackingSteps.isEmpty
                        ? const Text('No tracking details available yet.')
                        : Column(
                            children: List.generate(_trackingSteps.length, (index) {
                              final step = _trackingSteps[index];
                              final isLast = index == _trackingSteps.length - 1;
                              
                              // Parse date
                              String dateStr = '';
                              if (step['event_date'] != null) {
                                try {
                                  final date = DateTime.parse(step['event_date']);
                                  dateStr = DateFormat('dd MMM yyyy').format(date);
                                } catch (e) {
                                  dateStr = step['event_date'] ?? '';
                                }
                              }

                              return _buildTimelineItem(
                                title: step['title'] ?? '',
                                date: dateStr,
                                description: step['description'] ?? '',
                                isCompleted: step['is_completed'] ?? false,
                                isLast: isLast,
                              );
                            }),
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String description,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80, // Fixed height might be issue if text is long, but keeping simple
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: ConstrainedBox(
             constraints: const BoxConstraints(minHeight: 80), // Ensure at least enough height for line
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.black,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (!isLast) const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
