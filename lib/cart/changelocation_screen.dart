import 'package:flutter/material.dart';
import 'listlocation_screen.dart'; // <-- 1. ADD THIS IMPORT

// --- CONVERTED TO STATEFULWIDGET ---
class ChangeLocationScreen extends StatefulWidget {
  const ChangeLocationScreen({super.key});

  @override
  State<ChangeLocationScreen> createState() => _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {
  // --- ADDED STATE VARIABLE FOR THE BUTTONS ---
  String _selectedAddressType = 'Office'; // Default selection

  // --- HELPER WIDGET FOR RADIO BUTTONS ---
  Widget _buildAddressTypeButton(String label) {
    bool isSelected = (_selectedAddressType == label);

    // Common style for both selected and unselected buttons
    final style = OutlinedButton.styleFrom(
      foregroundColor: isSelected ? Colors.white : Colors.black,
      backgroundColor: isSelected ? Colors.black : Colors.white,
      side: const BorderSide(color: Colors.black, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Pill shape
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );

    return OutlinedButton(
      onPressed: () {
        // Update the state to reflect the new selection
        setState(() {
          _selectedAddressType = label;
        });
      },
      style: style,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery Address'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Contact Details Section ---
          const Text(
            'Contact Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          const _CustomTextField(
            label: 'Full Name',
          ),
          const SizedBox(height: 24.0),
          const _CustomTextField(
            label: 'Mobile No.',
          ),

          // --- Address Section ---
          const SizedBox(height: 32.0),
          const Text(
            'Address',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          const _CustomTextField(
            label: 'Pin Code',
          ),
          const SizedBox(height: 24.0),
          const _CustomTextField(
            label: 'Address',
          ),
          const SizedBox(height: 24.0),
          const _CustomTextField(
            label: 'Locality/Town',
          ),
          const SizedBox(height: 24.0),
          const _CustomTextField(
            label: 'City/District',
          ),
          const SizedBox(height: 24.0),
          const _CustomTextField(
            label: 'State',
          ),

          // --- "SAVE ADDRESS AS" SECTION ---
          const SizedBox(height: 32.0),
          const Text(
            'Save Address As',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            // Use the helper widget to build the buttons
            children: [
              _buildAddressTypeButton('Home'),
              const SizedBox(width: 12.0),
              _buildAddressTypeButton('Shop'),
              const SizedBox(width: 12.0),
              _buildAddressTypeButton('Office'),
            ],
          ),
          // Add some padding at the bottom so it doesn't touch
          // the floating bottom navigation bar
          const SizedBox(height: 16.0),
          // --- END OF NEW SECTION ---
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
              offset: const Offset(0, -2), // Shadow at the top of the bar
            ),
          ],
        ),
        child: ElevatedButton(
          // --- 2. MODIFY THIS OnPressed HANDLER ---
          onPressed: () {
            // Handle save address logic
            print('Address Saved as: $_selectedAddressType');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListLocationScreen(),
              ),
            );
          },
          // --- END MODIFICATION ---
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Black background
            foregroundColor: Colors.white, // White text
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            minimumSize: const Size(double.infinity, 50), // Make it full-width
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8.0), // Rounded corners
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Save Address'),
        ),
      ),
    );
  }
}

// --- HELPER WIDGET (Unchanged) ---
class _CustomTextField extends StatelessWidget {
  final String label;

  const _CustomTextField({required this.label});

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
            // Padding inside the text field
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            // The border style
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            // Border style when the field is focused
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.black, width: 2.0),
            ),
            // Border style when the field is not focused
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