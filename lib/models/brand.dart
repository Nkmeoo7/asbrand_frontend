/// Brand model matching backend Brand schema
class Brand {
  final String id;
  final String name;
  final String? subcategoryId;

  Brand({
    required this.id,
    required this.name,
    this.subcategoryId,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      subcategoryId: json['subcategoryId'] is Map ? json['subcategoryId']['_id'] : json['subcategoryId'],
    );
  }
}
