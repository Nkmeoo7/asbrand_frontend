import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../core/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  /// Create from Backend JSON (maps _id to id)
  factory Address.fromBackendJson(Map<String, dynamic> map) => Address(
    id: map['_id'] ?? '',
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

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AddressProvider() {
    _loadFromStorage().then((_) => syncWithBackend());
  }

  /// Check if user is logged in
  Future<bool> get _isLoggedIn async {
    String? token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  /// Sync with backend
  Future<void> syncWithBackend() async {
    if (await _isLoggedIn) {
      if (_addresses.isNotEmpty) {
        await _syncLocalToBackend();
      }
      await fetchAddressesFromBackend();
    }
  }

  /// Fetch from backend
  Future<void> fetchAddressesFromBackend() async {
    if (!(await _isLoggedIn)) return;

    try {
      final response = await _apiService.get(ApiConstants.address);
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        _addresses.clear();
        for (var item in data) {
           _addresses.add(Address.fromBackendJson(item));
        }
        
        // Update selected based on default
        if (_addresses.isNotEmpty) {
           final defaultAddr = _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);
           _selectedAddressId = defaultAddr.id;
        }

        _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    }
  }

  /// Sync local to backend
  Future<void> _syncLocalToBackend() async {
    try {
      final addressesData = _addresses.map((a) => a.toJson()).toList();
      await _apiService.post('${ApiConstants.address}/sync', {'addresses': addressesData});
    } catch (e) {
      debugPrint('Error syncing addresses: $e');
    }
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
  Future<void> addAddress(Address address) async {
    // Optimistic update
    if (_addresses.isEmpty) {
      _addresses.add(Address(
        id: address.id, // ID might change after backend save, but sticking to local ID for now or refetch
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

    // Backend update
    if (await _isLoggedIn) {
      try {
        await _apiService.post('${ApiConstants.address}/add', address.toJson());
        await fetchAddressesFromBackend(); // Refresh to get real IDs
      } catch (e) {
        debugPrint('Error adding address to backend: $e');
      }
    }
  }

  /// Select address
  void selectAddress(String id) {
    _selectedAddressId = id;
    _saveToStorage();
    notifyListeners();
  }

  /// Remove address
  Future<void> removeAddress(String id) async {
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
    _saveToStorage();
    notifyListeners();

    // Backend update
    if (await _isLoggedIn) {
      try {
        await _apiService.delete('${ApiConstants.address}/remove/$id');
      } catch (e) {
        debugPrint('Error removing address from backend: $e');
      }
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String id) async {
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

    // Backend update
    if (await _isLoggedIn) {
       // We can trigger an update on the specific ID to set as default
       try {
         await _apiService.put('${ApiConstants.address}/update/$id', {'isDefault': true});
         await fetchAddressesFromBackend();
       } catch (e) {
         debugPrint('Error setting default address: $e');
       }
    }
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
