class Product {
  final String id;
  final String name;
  final String? description;
  final int quantity;
  final double price;
  final double? offerPrice;
  final List<String> images;
  final CategoryRef? category;
  final CategoryRef? subCategory;
  final CategoryRef? brand;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.price,
    this.offerPrice,
    required this.images,
    this.category,
    this.subCategory,
    this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse images from image1-image5 fields
    List<String> imageList = [];
    for (int i = 1; i <= 5; i++) {
      final img = json['image$i'];
      if (img != null && img.toString().isNotEmpty && img != 'no_url') {
        imageList.add(img);
      }
    }
    // Fallback to images array if present
    if (imageList.isEmpty && json['images'] != null) {
      imageList = List<String>.from(json['images']);
    }

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      offerPrice: json['offerPrice'] != null ? (json['offerPrice']).toDouble() : null,
      images: imageList,
      category: json['proCategoryId'] != null ? CategoryRef.fromJson(json['proCategoryId']) : null,
      subCategory: json['proSubCategoryId'] != null ? CategoryRef.fromJson(json['proSubCategoryId']) : null,
      brand: json['proBrandId'] != null ? CategoryRef.fromJson(json['proBrandId']) : null,
    );
  }

  // Calculate EMI per month (for display like Snapmint)
  double get emiPerMonth => (offerPrice ?? price) / 12;

  // Get discount percentage
  int get discountPercentage {
    if (offerPrice == null || offerPrice! >= price) return 0;
    return (((price - offerPrice!) / price) * 100).round();
  }

  // Get first image or placeholder
  String get primaryImage => images.isNotEmpty ? images.first : '';
}

class CategoryRef {
  final String id;
  final String name;

  CategoryRef({required this.id, required this.name});

  factory CategoryRef.fromJson(Map<String, dynamic> json) {
    return CategoryRef(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
