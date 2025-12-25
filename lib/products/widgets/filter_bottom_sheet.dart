import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(18, 100);

  // State untuk Multiple Selection
  Set<String> _selectedBrands = {'Royal Canine'};
  Set<String> _selectedCategories = {'Dogs', 'Cats'};
  Set<String> _selectedSizes = {'Small', 'Large'};

  final List<String> brands = ['Royal Canine', 'Purina', 'Blue Buffalo', 'Origin', 'Nutra'];
  final List<String> categories = ['All', 'Dogs', 'Cats', 'Birds', 'Fish', 'Reptiles', 'Rodents', 'Rabbits'];
  final List<String> sizes = ['Small', 'Medium', 'Large', 'XL', '2XL'];

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('See All', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Set<String> selectionSet) {
    bool isSelected = selectionSet.contains(label);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectionSet.add(label);
          } else {
            selectionSet.remove(label);
          }
        });
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
      height: MediaQuery.of(context).size.height * 0.85, 
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 10),

          // Content Filters (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Section
                  _buildSectionTitle('Brand'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: brands.map((brand) => _buildFilterChip(brand, _selectedBrands)).toList(),
                  ),
                  const Divider(),

                  // Categories Section
                  _buildSectionTitle('Categories:'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: categories.map((cat) => _buildFilterChip(cat, _selectedCategories)).toList(),
                  ),
                  const Divider(),

                  // Size Section
                  _buildSectionTitle('Size:'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: sizes.map((size) => _buildFilterChip(size, _selectedSizes)).toList(),
                  ),
                  const Divider(),

                  // Price Section
                  _buildSectionTitle('Price:'),
                  Text('${_priceRange.start.round()} and ${_priceRange.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 200,
                    divisions: 200,
                    labels: RangeLabels(_priceRange.start.round().toString(), _priceRange.end.round().toString()),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons (Fixed at Bottom)
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Logika Reset
                      setState(() {
                        _priceRange = const RangeValues(18, 100);
                        _selectedBrands.clear();
                        _selectedCategories.clear();
                        _selectedSizes.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.grey.shade100,
                    ),
                    child: const Text('Reset', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logika Apply Filter
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
