import 'package:flutter/material.dart';
import 'changelocation_screen.dart';

import '../services/api_service.dart';

class ListLocationScreen extends StatefulWidget {
  final int? initialSelectedId;

  const ListLocationScreen({super.key, this.initialSelectedId});

  @override
  State<ListLocationScreen> createState() => _ListLocationScreenState();
}

class _ListLocationScreenState extends State<ListLocationScreen> {
  int _selectedAddressId = -1; // -1 indicates none selected or default
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    // Initialize with passed ID or -1
    _selectedAddressId = widget.initialSelectedId ?? -1;
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addresses = await _dataService.getUserAddresses();
    if (mounted) {
      setState(() {
        _addresses = addresses;
        _isLoading = false;
        // Optional: Select the first one ONLY if nothing was passed initially
        // AND nothing is currently selected (which is covered by init logic, but here we check list empty)
        if (_addresses.isNotEmpty && _selectedAddressId == -1) {
          _selectedAddressId = _addresses.first['id'] as int;
        }
      });
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'office':
        return Icons.location_pin; // Or building icon
      case 'shop':
        return Icons.storefront_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true, // <-- ADD THIS LINE
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              children: [
                if (_addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No addresses found. Add one below!'),
                  ),
                ..._addresses.map((address) {
                  final id = address['id'] as int;
                  final title = address['title'] as String;
                  return _AddressListTile(
                    icon: _getIconForType(title),
                    title: title,
                    subtitle: address['address_line'] as String,
                    value: id,
                    groupValue: _selectedAddressId,
                    onChanged: (value) {
                      setState(() {
                        _selectedAddressId = value!;
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 16.0),
                _AddAddressButton(),
                const SizedBox(height: 16.0),
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
          onPressed: () {
            if (_selectedAddressId == -1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an address')),
              );
              return;
            }
            final selected = _addresses.firstWhere(
              (a) => a['id'] == _selectedAddressId,
              orElse: () => {},
            );
            if (selected.isNotEmpty) {
              Navigator.pop(context, selected);
            }
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
          child: const Text('Save Address'),
        ),
      ),
    );
  }
}

// --- _AddressListTile WIDGET (Unchanged) ---
class _AddressListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  const _AddressListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: Colors.white, size: 28.0),
          ),
          const SizedBox(width: 16.0),
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
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Radio<int>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: Colors.black,
          ),
        ],
      ),
    );
  }
}

// --- _AddAddressButton WIDGET (Unchanged) ---
class _AddAddressButton extends StatelessWidget {
  const _AddAddressButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChangeLocationScreen()),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        side: BorderSide(color: Colors.grey[400]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.add_circle_outline, color: Colors.black, size: 24.0),
              SizedBox(width: 12.0),
              Text(
                'Add Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16.0),
        ],
      ),
    );
  }
}
