import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Address model
class Address {
  final String id;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city, $state - $pincode';
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'street': street,
    'city': city,
    'state': state,
    'pincode': pincode,
    'isDefault': isDefault,
  };

  factory Address.fromJson(Map<String, dynamic> map) => Address(
    id: map['id'] ?? '',
    phone: map['phone'] ?? '',
    street: map['street'] ?? '',
    city: map['city'] ?? '',
    state: map['state'] ?? '',
    pincode: map['pincode'] ?? '',
    isDefault: map['isDefault'] ?? false,
  );
}

/// Manages saved addresses with persistence
class AddressProvider extends ChangeNotifier {
  static const String _storageKey = 'saved_addresses';
  static const String _selectedKey = 'selected_address_id';
  
  final List<Address> _addresses = [];
  String? _selectedAddressId;
  bool _isLoaded = false;

  AddressProvider() {
    _loadFromStorage();
  }

  /// Get all addresses
  List<Address> get addresses => List.unmodifiable(_addresses);

  /// Get selected address
  Address? get selectedAddress {
    if (_selectedAddressId == null && _addresses.isEmpty) return null;
    if (_selectedAddressId == null && _addresses.isNotEmpty) {
      // Return default or first
      return _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);
    }
    return _addresses.where((a) => a.id == _selectedAddressId).firstOrNull;
  }

  /// Check if has addresses
  bool get hasAddresses => _addresses.isNotEmpty;

  /// Add new address
  void addAddress(Address address) {
    // If first address, make it default
    if (_addresses.isEmpty) {
      _addresses.add(Address(
        id: address.id,
        phone: address.phone,
        street: address.street,
        city: address.city,
        state: address.state,
        pincode: address.pincode,
        isDefault: true,
      ));
      _selectedAddressId = address.id;
    } else {
      _addresses.add(address);
    }
    _saveToStorage();
    notifyListeners();
  }

  /// Select address
  void selectAddress(String id) {
    _selectedAddressId = id;
    _saveToStorage();
    notifyListeners();
  }

  /// Remove address
  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
    _saveToStorage();
    notifyListeners();
  }

  /// Set default address
  void setDefaultAddress(String id) {
    for (int i = 0; i < _addresses.length; i++) {
      final addr = _addresses[i];
      _addresses[i] = Address(
        id: addr.id,
        phone: addr.phone,
        street: addr.street,
        city: addr.city,
        state: addr.state,
        pincode: addr.pincode,
        isDefault: addr.id == id,
      );
    }
    _saveToStorage();
    notifyListeners();
  }

  /// Clear all addresses
  void clearAddresses() {
    _addresses.clear();
    _selectedAddressId = null;
    _saveToStorage();
    notifyListeners();
  }

  /// Load addresses from SharedPreferences
  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      _selectedAddressId = prefs.getString(_selectedKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _addresses.clear();
        for (var item in jsonList) {
          _addresses.add(Address.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
    
    _isLoaded = true;
  }

  /// Save addresses to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _addresses.map((a) => a.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
      if (_selectedAddressId != null) {
        await prefs.setString(_selectedKey, _selectedAddressId!);
      } else {
        await prefs.remove(_selectedKey);
      }
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }
}
