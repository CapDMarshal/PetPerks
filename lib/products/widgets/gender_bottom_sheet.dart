import 'package:flutter/material.dart';

class GenderBottomSheet extends StatefulWidget {
  const GenderBottomSheet({super.key});

  @override
  State<GenderBottomSheet> createState() => _GenderBottomSheetState();
}

class _GenderBottomSheetState extends State<GenderBottomSheet> {
  String _selectedGender = 'Male'; 

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  Widget _buildGenderButton(String label) {
    bool isSelected = _selectedGender == label;
    return OutlinedButton(
      onPressed: () => _selectGender(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gender',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildGenderButton('Male'),
              const SizedBox(width: 10),
              _buildGenderButton('Female'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
