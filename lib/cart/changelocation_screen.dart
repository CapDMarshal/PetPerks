import 'package:flutter/material.dart';
import 'listlocation_screen.dart';
import '../services/api_service.dart';

class ChangeLocationScreen extends StatefulWidget {
  const ChangeLocationScreen({super.key});

  @override
  State<ChangeLocationScreen> createState() => _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {
  // --- ADDED STATE VARIABLE FOR THE BUTTONS ---
  String _selectedAddressType = 'Office'; // Default selection
  bool _isLoading = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _localityController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  final DataService _dataService = DataService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Basic validation
      if (_addressController.text.isEmpty ||
          _cityController.text.isEmpty ||
          _stateController.text.isEmpty) {
        throw Exception('Please fill in required address fields');
      }

      // Construct full address string
      final fullAddress = [
        _fullNameController.text,
        _mobileController.text,
        _addressController.text,
        _localityController.text,
        _cityController.text,
        _stateController.text,
        _pincodeController.text,
      ].where((s) => s.isNotEmpty).join(', ');

      await _dataService.addUserAddress(
        title: _selectedAddressType,
        addressLine: fullAddress,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully!')),
        );
        // Navigate to ListLocationScreen to see the list
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ListLocationScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save address: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24.0),
          _CustomTextField(label: 'Full Name', controller: _fullNameController),
          const SizedBox(height: 24.0),
          _CustomTextField(
            label: 'Mobile No.',
            controller: _mobileController,
            isNumber: true,
          ),

          // --- Address Section ---
          const SizedBox(height: 32.0),
          const Text(
            'Address',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24.0),
          _CustomTextField(
            label: 'Pin Code',
            controller: _pincodeController,
            isNumber: true,
          ),
          const SizedBox(height: 24.0),
          _CustomTextField(label: 'Address', controller: _addressController),
          const SizedBox(height: 24.0),
          _CustomTextField(
            label: 'Locality/Town',
            controller: _localityController,
          ),
          const SizedBox(height: 24.0),
          _CustomTextField(label: 'City/District', controller: _cityController),
          const SizedBox(height: 24.0),
          _CustomTextField(label: 'State', controller: _stateController),

          // --- "SAVE ADDRESS AS" SECTION ---
          const SizedBox(height: 32.0),
          const Text(
            'Save Address As',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          onPressed: _isLoading ? null : _saveAddress,
          // --- END MODIFICATION ---
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Black background
            foregroundColor: Colors.white, // White text
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            minimumSize: const Size(double.infinity, 50), // Make it full-width
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
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

// --- HELPER WIDGET ---
class _CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool isNumber;

  const _CustomTextField({
    required this.label,
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
              return 'Please enter $label';
            }
            return null;
          },
          decoration: InputDecoration(
            // Padding inside the text field
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
