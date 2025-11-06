import 'package:flutter/material.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  String _selectedSortOption = 'Above 8 to 9 year'; 

  final List<String> _sortOptions = [
    'Above 8 to 9 year', 
    '8 Months', 
    'Price Low to High', 
    'Newest',
  ];

  Widget _buildSortChip(String label) {
    bool isSelected = _selectedSortOption == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedSortOption = label;
          });
        }
      },
      selectedColor: Colors.black,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300),
      ),
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
              const Text('Sort By', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            children: _sortOptions.map((option) => _buildSortChip(option)).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}