class ApiConstants {
  // ---------------------------------------------------------------------------
  // NETWORK CONFIGURATION
  // ---------------------------------------------------------------------------
  // If you are using the Android Emulator, use 'http://10.0.2.2:3000'
  // If you are using the iOS Simulator, use 'http://localhost:3000'
  // If you are using a physical device, use your PC's LAN IP (e.g., 'http://192.168.1.5:3000')
  static const String baseUrl = 'http://localhost:3000'; // LAN IP for physical device 

  // ---------------------------------------------------------------------------
  // AUTH ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  static const String profile = '$baseUrl/users/profile';
  static const String users = '$baseUrl/users';

  // ---------------------------------------------------------------------------
  // PRODUCT ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/categories';
  static const String subCategories = '$baseUrl/subCategories';
  static const String brands = '$baseUrl/brands';
  static const String variants = '$baseUrl/variants';
  static const String variantTypes = '$baseUrl/variantTypes';

  // ---------------------------------------------------------------------------
  // ORDER & CART ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String orders = '$baseUrl/orders';
  static const String cart = '$baseUrl/cart';
  static const String wishlist = '$baseUrl/wishlist';
  static const String address = '$baseUrl/address';
  static const String coupons = '$baseUrl/couponCodes';

  // ---------------------------------------------------------------------------
  // EMI & KYC ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String emiPlans = '$baseUrl/emi/plans';
  static const String emiApply = '$baseUrl/emi/apply';
  static const String emiApplications = '$baseUrl/emi/my-emis';
  static const String kyc = '$baseUrl/kyc';
  static const String kycSubmit = '$baseUrl/kyc/submit';
  static const String kycStatus = '$baseUrl/kyc/status';

  // ---------------------------------------------------------------------------
  // OTHER ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String posters = '$baseUrl/posters';
  static const String notifications = '$baseUrl/notification';
  static const String payment = '$baseUrl/payment';

  // Change these three lines to match your router.post() paths
static const String initiateOrder = '$payment/initiate'; // Removed '-order'
static const String verifyPayment = '$payment/verify';   // Removed '-payment'
static const String cod = '$payment/cod';              // This one is already correct

}
