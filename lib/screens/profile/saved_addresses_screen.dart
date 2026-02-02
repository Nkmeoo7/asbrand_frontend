import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';

/// Screen for managing saved addresses
class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addressProvider = context.read<AddressProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isLoggedIn && authProvider.user != null) {
      await addressProvider.loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            onPressed: () => _showAddAddressDialog(),
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, _) {
          if (addressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = addressProvider.addresses;

          if (addresses.isEmpty) {
            return _buildEmptyView();
          }

          return RefreshIndicator(
            onRefresh: _loadAddresses,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                return _buildAddressCard(addresses[index], addressProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Iconsax.add),
        label: const Text('Add Address'),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.location,
              size: 60,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Saved Addresses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add an address for faster checkout',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAddressDialog(),
            icon: const Icon(Iconsax.add),
            label: const Text('Add New Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address, AddressProvider addressProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: address.isDefault
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.location,
                  color: address.isDefault ? AppTheme.primaryColor : Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  address.isDefault ? 'Default Address' : 'Delivery Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: address.isDefault ? AppTheme.primaryColor : Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Address Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Street
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.home_2, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address.street,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // City, State, Pincode
                Row(
                  children: [
                    Icon(Iconsax.map, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${address.city}, ${address.state} - ${address.pincode}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Phone
                Row(
                  children: [
                    Icon(Iconsax.call, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      address.phone,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Row(
              children: [
                if (!address.isDefault)
                  _buildActionButton(
                    icon: Iconsax.tick_circle,
                    label: 'Set Default',
                    color: AppTheme.primaryColor,
                    onTap: () async {
                      final authProvider = context.read<AuthProvider>();
                      final userId = authProvider.user?.id;
                      if (userId != null) {
                        await addressProvider.setDefaultAddress(address.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Default address updated'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                const Spacer(),
                _buildActionButton(
                  icon: Iconsax.edit,
                  label: 'Edit',
                  color: Colors.blue,
                  onTap: () => _showEditAddressDialog(address),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Iconsax.trash,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () => _confirmDelete(address, addressProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Address address, AddressProvider addressProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              final userId = authProvider.user?.id;
              if (userId != null) {
                await addressProvider.deleteAddress(address.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog() {
    _showAddressFormDialog(null);
  }

  void _showEditAddressDialog(Address address) {
    _showAddressFormDialog(address);
  }

  void _showAddressFormDialog(Address? existingAddress) {
    final phoneController = TextEditingController(text: existingAddress?.phone ?? '');
    final streetController = TextEditingController(text: existingAddress?.street ?? '');
    final cityController = TextEditingController(text: existingAddress?.city ?? '');
    final stateController = TextEditingController(text: existingAddress?.state ?? '');
    final pincodeController = TextEditingController(text: existingAddress?.pincode ?? '');
    bool isDefault = existingAddress?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      existingAddress == null ? Iconsax.add : Iconsax.edit,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      existingAddress == null ? 'Add New Address' : 'Edit Address',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildTextField(phoneController, 'Phone', Iconsax.call, TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField(streetController, 'Street Address', Iconsax.home_2, TextInputType.streetAddress),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(cityController, 'City', Iconsax.building, TextInputType.text)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(stateController, 'State', Iconsax.map, TextInputType.text)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(pincodeController, 'Pincode', Iconsax.location, TextInputType.number),
                const SizedBox(height: 16),

                // Default checkbox
                GestureDetector(
                  onTap: () => setModalState(() => isDefault = !isDefault),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isDefault,
                        onChanged: (val) => setModalState(() => isDefault = val ?? false),
                        activeColor: AppTheme.primaryColor,
                      ),
                      const Text('Set as default address'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_validateForm(phoneController, streetController, cityController, stateController, pincodeController)) {
                        Navigator.pop(context);
                        final addressProvider = context.read<AddressProvider>();
                        final authProvider = context.read<AuthProvider>();
                        final userId = authProvider.user?.id;

                        if (userId != null) {
                          if (existingAddress != null) {
                            await addressProvider.updateAddress(
                              existingAddress.id,
                              phone: phoneController.text,
                              street: streetController.text,
                              city: cityController.text,
                              state: stateController.text,
                              pincode: pincodeController.text,
                              isDefault: isDefault,
                            );
                          } else {
                            final newAddress = Address(
                              id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
                              phone: phoneController.text,
                              street: streetController.text,
                              city: cityController.text,
                              state: stateController.text,
                              pincode: pincodeController.text,
                              isDefault: isDefault,
                            );
                            await addressProvider.addAddress(newAddress);
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(existingAddress != null ? 'Address updated' : 'Address added'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      existingAddress != null ? 'Update Address' : 'Save Address',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  bool _validateForm(TextEditingController phone, TextEditingController street, TextEditingController city, TextEditingController state, TextEditingController pincode) {
    if (phone.text.isEmpty || street.text.isEmpty || city.text.isEmpty || state.text.isEmpty || pincode.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }
}
