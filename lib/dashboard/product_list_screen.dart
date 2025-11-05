import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool isGrid = true;
  List<Map<String, String>> products = [
    {
      'title': 'Dog Body Belt',
      'price': '\$80',
      'old': '\$95',
      'image': 'assets/images/product/product1/pic1.png'
    },
    {
      'title': 'Dog Cloths',
      'price': '\$80',
      'old': '\$95',
      'image': 'assets/images/product/product1/pic2.png'
    },
    {
      'title': 'Pet Bed For Dog',
      'price': '\$80',
      'old': '\$95',
      'image': 'assets/images/product/product1/pic3.png'
    },
    {
      'title': 'Dog Chew Toys',
      'price': '\$80',
      'old': '\$95',
      'image': 'assets/images/product/product1/pic4.png'
    },
    {
      'title': 'Dog Package',
      'price': '\$120',
      'old': '\$150',
      'image': 'assets/images/product/product1/pic5.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Products',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.grid_view : Icons.list, color: Colors.black),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isGrid ? _buildGrid() : _buildList(),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.72,
      children: products.map((p) => _ProductCard(product: p)).toList(),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                p['image']!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.pets, color: Colors.grey),
                ),
              ),
            ),
            title: Text(p['title']!),
            subtitle: Text('${p['price']}  ${p['old']}', style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, String> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Image.asset(
                    product['image']!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(product['price']!, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      Text(product['old']!, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
