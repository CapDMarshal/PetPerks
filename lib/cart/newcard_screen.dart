import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NewCardScreen extends StatefulWidget {
  const NewCardScreen({super.key});

  @override
  State<NewCardScreen> createState() => _NewCardScreenState();
}

class _NewCardScreenState extends State<NewCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final DataService _dataService = DataService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Rebuild UI when text changes to update preview
    _nameController.addListener(() => setState(() {}));
    _numberController.addListener(() => setState(() {}));
    _expiryController.addListener(() => setState(() {}));
    _cvvController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate Expiry Format (MM/YY)
    final expiryInput = _expiryController.text.trim();
    // Matches 01-12 / 00-99
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expiryInput)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid expiry date. Please use MM/YY format.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert MM/YY to YYYY-MM-DD for Postgres Date type
      final parts = expiryInput.split('/');
      final month = parts[0];
      final year = '20${parts[1]}'; // Assuming 2000s
      final formattedExpiry = '$year-$month-01'; // Store as first day of month

      await _dataService.addPaymentMethod(
        type: 'cards', // Enum value verified from user image
        cardName: _nameController.text,
        cardNumber: _numberController.text,
        expiryDate: formattedExpiry,
        cvv: _cvvController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add card: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Card'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- 1. Card Preview Widget ---
              _CardPreviewWidget(
                name: _nameController.text,
                number: _numberController.text,
                expiry: _expiryController.text,
                cvv: _cvvController.text,
              ),
              const SizedBox(height: 24.0),

              // --- 2. Form Fields ---
              _CustomTextField(
                label: 'Card Name',
                controller: _nameController,
                hint: 'ROOPA SMITH',
              ),
              const SizedBox(height: 24.0),
              _CustomTextField(
                label: 'Card Number',
                controller: _numberController,
                hint: 'XXXX XXXX XXXX XXXX',
                isNumber: true,
              ),
              const SizedBox(height: 24.0),

              // --- 3. Expiry and CVV Row ---
              Row(
                children: [
                  Expanded(
                    child: _CustomTextField(
                      label: 'Expiry Date',
                      controller: _expiryController,
                      hint: 'MM/YY', // Changed hint to MM/YY
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _CustomTextField(
                      label: 'CVV',
                      controller: _cvvController,
                      hint: '123',
                      isNumber: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // --- 4. Bottom Navigation Button ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -2), // Shadow at the top
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveCard,
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
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Add Card'),
        ),
      ),
    );
  }
}

// --- HELPER WIDGET FOR CARD PREVIEW ---
class _CardPreviewWidget extends StatelessWidget {
  final String name;
  final String number;
  final String expiry;
  final String cvv;

  const _CardPreviewWidget({
    this.name = '',
    this.number = '',
    this.expiry = '',
    this.cvv = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Make it full width
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Row 1: Type, Logo ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'CREDIT CARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          // --- Row 2: Card Number ---
          Text(
            number.isEmpty ? '**** **** **** ****' : number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 20.0),
          // --- Row 3: Card Holder, EXP, CVV ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Card Holder
              Text(
                name.isEmpty ? 'CARD HOLDER' : name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // EXP and CVV
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EXP',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        expiry.isEmpty ? 'MM/YY' : expiry,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CVV',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        cvv.isEmpty ? '***' : cvv,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGET FOR TEXT FIELDS ---
class _CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isNumber;

  const _CustomTextField({
    required this.label,
    this.hint,
    this.controller,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        // 2. The Text Field
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
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
              borderSide: const BorderSide(color: Colors.black, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }
}
