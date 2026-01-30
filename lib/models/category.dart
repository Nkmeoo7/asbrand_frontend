class Category {
  final String id;
  final String name;
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] is Map ? (json['image']['path'] ?? json['image']['url']) : json['image'],
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final Category? category;

  SubCategory({
    required this.id,
    required this.name,
    this.category,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['categoryId'] is Map 
          ? Category.fromJson(json['categoryId']) 
          : null, // Ignore if it's just an ID string, as we can't build a full Category object
    );
  }
}
