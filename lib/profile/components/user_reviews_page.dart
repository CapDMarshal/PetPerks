import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'reviews.dart'; // Import WriteReviewPage

class UserReviewsPage extends StatefulWidget {
  const UserReviewsPage({super.key});

  @override
  State<UserReviewsPage> createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  final DataService _dataService = DataService();
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final reviews = await _dataService.getUserReviews();
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Reviews'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? const Center(child: Text('You haven\'t written any reviews yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    final product = review['products'] as Map<String, dynamic>?;
                    final productName = product?['name'] ?? 'Unknown Product';
                    final imageUrl = product?['image_url'] ?? '';
                    final price = product?['price']; // Dynamic type (int or double)
                    final priceString = price != null ? price.toString() : '0.00';
                    final rating = (review['rating'] as num).toDouble();
                    final title = review['title'] ?? '';
                    final comment = review['comment'] ?? '';
                    final date = DateTime.parse(review['created_at']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl.isNotEmpty
                                        ? (imageUrl.startsWith('assets/')
                                            ? Image.asset(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.shopping_bag),
                                              )
                                            : Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.shopping_bag),
                                              ))
                                        : const Icon(Icons.shopping_bag),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Header Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (price != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '\$$priceString',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(5, (starIndex) {
                                          return Icon(
                                            Icons.star,
                                            size: 16,
                                            color: starIndex < rating
                                                ? Colors.orange
                                                : Colors.grey[300],
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                // Edit Button
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    // Navigate to WriteReviewPage in edit mode
                                    if (product != null) {
                                      // We need to pass product ID which is in top level product_id column
                                      // But WriteReviewPage expects a full product Map.
                                      // The joined 'products' map might not have all fields like price/category unless selected.
                                      // For now, let's pass what we have. API select was '*, products(name, image_url)'
                                      // We might need to select more product fields or just use what we have.
                                      // Let's rely on what we have. 
                                      // Construct a product map merging review's product_id with joined product data.
                                      final productData = {
                                        'id': review['product_id'],
                                        ...product!,
                                      };
                                      
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WriteReviewPage(
                                            product: productData,
                                            existingReview: review,
                                          ),
                                        ),
                                      );

                                      if (result == true) {
                                        _loadReviews(); // Reload if updated
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Posted on ${date.toString().split(' ')[0]}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
