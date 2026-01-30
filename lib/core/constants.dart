class ApiConstants {
  // ---------------------------------------------------------------------------
  // NETWORK CONFIGURATION
  // ---------------------------------------------------------------------------
  // If you are using the Android Emulator, use 'http://10.0.2.2:3000'
  // If you are using the iOS Simulator, use 'http://localhost:3000'
  // If you are using a physical device, use your PC's LAN IP (e.g., 'http://192.168.1.5:3000')
  static const String baseUrl = 'http://localhost:3000'; 

  // ---------------------------------------------------------------------------
  // ENDPOINTS
  // ---------------------------------------------------------------------------
  
  // Auth
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  static const String profile = '$baseUrl/users/profile';

  // Products
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/categories';

  // Cart & Orders
  static const String orders = '$baseUrl/orders';
  
  // Images (Cloudinary or Local)
  // If local, we might need a helper to fix the URL for emulator
}
