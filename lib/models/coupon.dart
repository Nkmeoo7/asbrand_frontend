/// Coupon model matching backend Coupon schema
class Coupon {
  final String id;
  final String couponCode;
  final String discountType; // 'fixed' or 'percentage'
  final double discountAmount;
  final double minimumPurchaseAmount;
  final DateTime endDate;
  final String status; // 'active' or 'inactive'
  final String? applicableCategory;
  final String? applicableSubCategory;
  final String? applicableProduct;

  Coupon({
    required this.id,
    required this.couponCode,
    required this.discountType,
    required this.discountAmount,
    required this.minimumPurchaseAmount,
    required this.endDate,
    required this.status,
    this.applicableCategory,
    this.applicableSubCategory,
    this.applicableProduct,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'] ?? json['id'] ?? '',
      couponCode: json['couponCode'] ?? '',
      discountType: json['discountType'] ?? 'fixed',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      minimumPurchaseAmount: (json['minimumPurchaseAmount'] ?? 0).toDouble(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      status: json['status'] ?? 'active',
      applicableCategory: json['applicableCategory']?.toString(),
      applicableSubCategory: json['applicableSubCategory']?.toString(),
      applicableProduct: json['applicableProduct']?.toString(),
    );
  }

  bool get isValid => status == 'active' && endDate.isAfter(DateTime.now());

  double calculateDiscount(double cartTotal) {
    if (cartTotal < minimumPurchaseAmount) return 0;
    if (discountType == 'percentage') {
      return cartTotal * (discountAmount / 100);
    }
    return discountAmount;
  }
}
