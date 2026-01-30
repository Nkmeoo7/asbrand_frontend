/// EMI Plan model matching backend EmiPlan schema
class EmiPlan {
  final String id;
  final String name;
  final int tenure;
  final double interestRate;
  final double processingFee;
  final double minOrderAmount;
  final double? maxOrderAmount;
  final bool isActive;
  final List<String> applicableCategories;
  final List<BankPartner> bankPartners;

  EmiPlan({
    required this.id,
    required this.name,
    required this.tenure,
    this.interestRate = 0,
    this.processingFee = 0,
    required this.minOrderAmount,
    this.maxOrderAmount,
    this.isActive = true,
    this.applicableCategories = const [],
    this.bankPartners = const [],
  });

  factory EmiPlan.fromJson(Map<String, dynamic> json) {
    return EmiPlan(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      tenure: json['tenure'] ?? 3,
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      processingFee: (json['processingFee'] ?? 0).toDouble(),
      minOrderAmount: (json['minOrderAmount'] ?? 0).toDouble(),
      maxOrderAmount: json['maxOrderAmount']?.toDouble(),
      isActive: json['isActive'] ?? true,
      applicableCategories: (json['applicableCategories'] as List?)
          ?.map((e) => e is Map ? e['_id']?.toString() ?? '' : e.toString())
          .toList() ?? [],
      bankPartners: (json['bankPartners'] as List?)
          ?.map((e) => BankPartner.fromJson(e))
          .toList() ?? [],
    );
  }

  /// Calculate EMI for given principal amount
  double calculateEMI(double principal) {
    final P = principal;
    final R = interestRate / 12 / 100; // Monthly interest rate
    final N = tenure;

    if (R == 0) {
      // No-cost EMI: simple division
      return (P / N).ceilToDouble();
    }

    // EMI Formula: P * R * (1+R)^N / ((1+R)^N - 1)
    final pow = _pow(1 + R, N);
    final emi = P * R * pow / (pow - 1);
    return emi.ceilToDouble();
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

class BankPartner {
  final String bankName;
  final String cardType; // 'credit', 'debit', 'both'

  BankPartner({required this.bankName, required this.cardType});

  factory BankPartner.fromJson(Map<String, dynamic> json) {
    return BankPartner(
      bankName: json['bankName'] ?? '',
      cardType: json['cardType'] ?? 'both',
    );
  }
}
