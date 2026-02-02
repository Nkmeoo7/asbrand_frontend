import 'package:flutter/material.dart';

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
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'phone': phone,
    'street': street,
    'city': city,
    'state': state,
    'pincode': pincode,
    'isDefault': isDefault,
  };

  factory Address.fromMap(Map<String, dynamic> map) => Address(
    id: map['id'] ?? '',
    phone: map['phone'] ?? '',
    street: map['street'] ?? '',
    city: map['city'] ?? '',
    state: map['state'] ?? '',
    pincode: map['pincode'] ?? '',
    isDefault: map['isDefault'] ?? false,
  );
}

/// Manages saved addresses
class AddressProvider extends ChangeNotifier {
  final List<Address> _addresses = [];
  String? _selectedAddressId;

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
    notifyListeners();
  }

  /// Select address
  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  /// Remove address
  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
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
    notifyListeners();
  }

  /// Clear all addresses
  void clearAddresses() {
    _addresses.clear();
    _selectedAddressId = null;
    notifyListeners();
  }
}
