import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/product_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _selectedSort = 'relevance';
  String? _selectedGender;
  String? _selectedCategory;
  int? _minDiscount;
  List<String> _selectedBrands = [];

  // Mock Data for filters (In real app, fetch from backend)
  final List<String> _genders = ['Men', 'Women', 'Kids', 'Unisex'];
  final List<String> _brands = ['Nike', 'Adidas', 'Puma', 'Zara', 'H&M', 'Levis', 'Allen Solly'];
  final List<int> _discounts = [10, 20, 30, 40, 50, 60, 70];

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    _priceRange = RangeValues(
      provider.minPrice ?? 0,
      provider.maxPrice ?? 10000,
    );
    if (_priceRange.end < _priceRange.start) _priceRange = RangeValues(_priceRange.start, _priceRange.start + 1000);
    
    _selectedSort = provider.sort ?? 'relevance';
    _selectedGender = provider.gender;
    _selectedCategory = provider.categoryId;
    _selectedBrands = List.from(provider.selectedBrands);
    _minDiscount = provider.minDiscount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sort & Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(0, 10000);
                      _selectedSort = 'relevance';
                      _selectedGender = null;
                      _selectedCategory = null; // Ideally keep category if navigated from category screen
                      _selectedBrands = [];
                      _minDiscount = null;
                    });
                    context.read<ProductProvider>().clearFilters();
                  },
                  child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // filter Body (Two panes: Left for sections, right for details? Or just vertical list)
          // Doing vertical list for simplicity and standard mobile UX
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                 // Sort Section
                _buildSectionHeader('Sort By'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildChoiceChip('Relevance', 'relevance', _selectedSort, (val) => _selectedSort = val),
                    _buildChoiceChip('Price: Low to High', 'price_asc', _selectedSort, (val) => _selectedSort = val),
                    _buildChoiceChip('Price: High to Low', 'price_desc', _selectedSort, (val) => _selectedSort = val),
                    _buildChoiceChip('Newest First', 'newest', _selectedSort, (val) => _selectedSort = val),
                  ],
                ),
                const SizedBox(height: 24),

                // Price Section
                _buildSectionHeader('Price Range'),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  activeColor: AppTheme.primaryColor,
                  labels: RangeLabels(
                    '₹${_priceRange.start.round()}',
                    '₹${_priceRange.end.round()}',
                  ),
                  onChanged: (values) => setState(() => _priceRange = values),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${_priceRange.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹${_priceRange.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Gender Section
                _buildSectionHeader('Gender'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _genders.map((g) => ChoiceChip(
                    label: Text(g),
                    selected: _selectedGender == g,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(color: _selectedGender == g ? AppTheme.primaryColor : Colors.black),
                    onSelected: (selected) => setState(() => _selectedGender = selected ? g : null),
                  )).toList(),
                ),
                const SizedBox(height: 24),

                // Discount Section
                _buildSectionHeader('Discount'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _discounts.map((d) => ChoiceChip(
                    label: Text('$d% or more'),
                    selected: _minDiscount == d,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(color: _minDiscount == d ? AppTheme.primaryColor : Colors.black),
                    onSelected: (selected) => setState(() => _minDiscount = selected ? d : null),
                  )).toList(),
                ),
                const SizedBox(height: 24),

                // Brand Section
                _buildSectionHeader('Brand'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _brands.map((b) => FilterChip(
                    label: Text(b),
                    selected: _selectedBrands.contains(b),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(color: _selectedBrands.contains(b) ? AppTheme.primaryColor : Colors.black),
                    onSelected: (selected) {
                      setState(() {
                         if (selected) {
                           _selectedBrands.add(b);
                         } else {
                           _selectedBrands.remove(b);
                         }
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Footer Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProductProvider>().setFilters(
                    min: _priceRange.start,
                    max: _priceRange.end,
                    sortOrder: _selectedSort,
                    gender: _selectedGender,
                    brands: _selectedBrands.isNotEmpty ? _selectedBrands : null,
                    discount: _minDiscount,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('APPLY FILTERS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChoiceChip(String label, String value, String groupValue, Function(String) onSelected) {
    final isSelected = groupValue == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      onSelected: (selected) {
        if (selected) onSelected(value);
        setState(() {}); // Trigger rebuild
      },
    );
  }
}
