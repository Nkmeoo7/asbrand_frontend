import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/product_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _selectedSort = 'newest';
  
  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    // Initialize with current values if any
    double min = provider.minPrice ?? 0;
    double max = provider.maxPrice ?? 10000;
    if (max < min) max = min + 1000;
    _priceRange = RangeValues(min, max);
    _selectedSort = provider.sort ?? 'newest';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  context.read<ProductProvider>().clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Reset', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          
          // Price Range
          const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 10000, // Assuming max price, ideally dynamic
            divisions: 20,
            activeColor: AppTheme.primaryColor,
            labels: RangeLabels(
              '₹${_priceRange.start.round()}',
              '₹${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${_priceRange.start.round()}'),
              Text('₹${_priceRange.end.round()}'),
            ],
          ),
          const SizedBox(height: 24),

          // Sort Order
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSortChip('Newest', 'newest'),
              _buildSortChip('Price: Low to High', 'price_asc'),
              _buildSortChip('Price: High to Low', 'price_desc'),
            ],
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<ProductProvider>().setFilters(
                  min: _priceRange.start,
                  max: _priceRange.end,
                  sortOrder: _selectedSort,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.grey.shade100,
      onSelected: (bool selected) {
        if (selected) setState(() => _selectedSort = value);
      },
    );
  }
}
