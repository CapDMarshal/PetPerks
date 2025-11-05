import 'package:flutter/material.dart';

class NewCardScreen extends StatelessWidget {
  const NewCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title from previous context
        title: const Text('Add New Card'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- 1. Card Preview Widget ---
            const _CardPreviewWidget(),
            const SizedBox(height: 24.0),

            // --- 2. Form Fields ---
            const _CustomTextField(label: 'Card Name'),
            const SizedBox(height: 24.0),
            const _CustomTextField(label: 'Card Number'),
            const SizedBox(height: 24.0),

            // --- 3. Expiry and CVV Row ---
            Row(
              children: const [
                Expanded(
                  child: _CustomTextField(
                    label: 'Expiry Date',
                    hint: 'mm/dd/yyyy',
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: _CustomTextField(
                    label: 'CVV',
                    hint: 'CVV',
                  ),
                ),
              ],
            ),
          ],
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
          onPressed: () {
            // Goes back to the payment screen
            Navigator.pop(context);
          },
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
          child: const Text('Add Card'),
        ),
      ),
    );
  }
}

// --- HELPER WIDGET FOR CARD PREVIEW ---
// (Simplified from the previous screen, no radio button)
class _CardPreviewWidget extends StatelessWidget {
  const _CardPreviewWidget();

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
            children: [
              const Text(
                'CREDIT CARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
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
          const Text(
            '**** **** **** 4532',
            style: TextStyle(
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
              const Text(
                'ROOPA SMITH',
                style: TextStyle(
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
                    children: const [
                      Text(
                        'EXP',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '14/07',
                        style: TextStyle(
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
                    children: const [
                      Text(
                        'CVV',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '012',
                        style: TextStyle(
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

  const _CustomTextField({required this.label, this.hint});

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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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