import 'package:flutter/material.dart';
import 'listlocation_screen.dart';
import 'paymentmethod_screen.dart';
import 'myorder_screen.dart'; // <-- 1. ADD THIS IMPORT

import '../services/api_service.dart';
import '../services/midtrans_service.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? initialAddress;

  const CheckoutScreen({super.key, this.initialAddress});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  final DataService _dataService = DataService();
  final MidtransService _midtransService = MidtransService();

  Map<String, dynamic>? _addressData;
  Map<String, dynamic>? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _addressData = widget.initialAddress;
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final cartItems = await _dataService.getCartItems();
    if (mounted) {
      setState(() {
        _items = cartItems.map((item) {
          final product = item['products'] as Map<String, dynamic>;
          // Parse price safely
          double price = 0.0;
          var p = product['price'];
          if (p is int) {
            price = p.toDouble();
          } else if (p is double) {
            price = p;
          } else if (p is String) {
            price = double.tryParse(p) ?? 0.0;
          }

          return {
            "title": product['name'] as String,
            "price": price,
            "quantity": (item['quantity'] as int?) ?? 1,
          };
        }).toList();
        _isLoading = false;
      });
    }
  }

  double get _subtotal {
    double total = 0.0;
    for (var item in _items) {
      double price = item['price'] as double;
      int qty = item['quantity'] as int;
      total += price * qty;
    }
    return total;
  }

  String _getPaymentDisplayString(Map<String, dynamic> method) {
    final type = method['type_payment'];
    if (type == 'cards') {
      final num = method['card_number'] as String? ?? '****';
      if (num.length >= 4) {
        return '**** **** **** ${num.substring(num.length - 4)}';
      }
      return num;
    }
    if (type == 'upi') {
      return 'UPI - ${method['upi_id'] ?? ''}';
    }
    if (type == 'wallet') {
      return 'Wallet - ${method['wallet_id'] ?? ''}';
    }
    return method['title'] ?? 'Selected';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- 1. SCROLLABLE TOP PART ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // --- DELIVERY ADDRESS WIDGET ---
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListLocationScreen(
                                initialSelectedId: _addressData?['id'],
                              ),
                            ),
                          );
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              _addressData = result;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.white,
                                  size: 28.0,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _addressData?['title'] ??
                                          'Delivery Address',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      _addressData?['address_line'] ??
                                          'Please select address',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black54,
                                size: 18.0,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- SEPARATOR ---
                      const Divider(
                        color: Colors.black12,
                        thickness: 1,
                        height: 16,
                      ),

                      // --- PAYMENT WIDGET ---
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentMethodScreen(),
                            ),
                          );

                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              _paymentMethod = result;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Colors.white,
                                  size: 28.0,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Payment',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      _paymentMethod == null
                                          ? 'Select Payment Method'
                                          : _getPaymentDisplayString(
                                              _paymentMethod!,
                                            ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black54,
                                size: 18.0,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- "ADDITIONAL NOTES" SECTION ---
                      const SizedBox(height: 16.0),
                      const Text(
                        'Additional Notes:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Write Here',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // --- 2. STATIC BOTTOM PART (ORDER SUMMARY) ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: _OrderSummary(items: _items, subtotal: _subtotal),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        // --- 2. MODIFIED OnPressed ---
        child: ElevatedButton(
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });

            try {
              if (_paymentMethod != null &&
                  _paymentMethod!['type_payment'] == 'midtrans') {
                await _midtransService.initiatePayment(
                  context,
                  amount: _subtotal,
                );
              } else {
                await _dataService.submitOrder(
                    paymentMethod: _paymentMethod?['title'] ?? 'Unknown');
              }

              if (mounted) {
                // Use pushReplacement so user can't go back to checkout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyOrderScreen(),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to place order: $e')),
                );
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
          // --- END MODIFICATION ---
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Submit Order'),
        ),
      ),
    );
  }
}

// --- _OrderSummaryRow HELPER WIDGET (Unchanged) ---
class _OrderSummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _OrderSummaryRow({
    required this.title,
    required this.value,
    this.valueColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// --- _OrderSummary HELPER WIDGET (Unchanged) ---
// --- _OrderSummary HELPER WIDGET ---
class _OrderSummary extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double subtotal;

  const _OrderSummary({required this.items, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dynamic Items
        ...items.map((item) {
          final title = item['title'] as String;
          final price = item['price'] as double;
          final qty = item['quantity'] as int;
          return _OrderSummaryRow(
            title: title.length > 25
                ? '${title.substring(0, 22)}...'
                : title, // Truncate
            value: '$qty x \$${price.toStringAsFixed(0)}',
          );
        }).toList(),

        // Subtotal / Discount / Delivery
        const _OrderSummaryRow(
          title: 'Discount',
          value: '-\$0.00', // No discount logic yet
        ),
        const _OrderSummaryRow(
          title: 'Shipping',
          value: 'FREE Delivery',
          valueColor: Colors.green,
        ),
        const Divider(color: Colors.black, thickness: 1, height: 24.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Order',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '\$${subtotal.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
