/// Product model with full field support for clothes e-commerce
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
  final String? gender;
  
  // New fields for clothes
  final String? sku;
  final bool emiEligible;
  final String stockStatus; // in_stock, out_of_stock, low_stock, pre_order
  final int lowStockThreshold;
  final double? weight;
  final ProductDimensions? dimensions;
  final String? variantType; // Size, Color, etc.
  final List<String> variants; // [S, M, L, XL] or [Red, Blue]
  final List<ProductSpec> specifications;
  final List<String> tags;
  final String? warranty;
  final bool featured;
  final bool isActive;

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
    this.gender,
    this.sku,
    this.emiEligible = true,
    this.stockStatus = 'in_stock',
    this.lowStockThreshold = 10,
    this.weight,
    this.dimensions,
    this.variantType,
    this.variants = const [],
    this.specifications = const [],
    this.tags = const [],
    this.warranty,
    this.featured = false,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse images from image1-image5 fields or images array
    List<String> imageList = [];
    for (int i = 1; i <= 5; i++) {
      final img = json['image$i'];
      String? imgUrl;
      if (img is String) {
        imgUrl = img;
      } else if (img is Map) {
        imgUrl = img['path'] ?? img['url'] ?? img['secure_url'];
      }
      if (imgUrl != null && imgUrl.isNotEmpty && imgUrl != 'no_url') {
        imageList.add(imgUrl);
      }
    }
    // Fallback to images array
    if (imageList.isEmpty && json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img is Map && img['url'] != null) {
          imageList.add(img['url'].toString());
        } else if (img is String) {
          imageList.add(img);
        }
      }
    }

    // Parse variants
    List<String> variantList = [];
    if (json['proVariantId'] != null && json['proVariantId'] is List) {
      variantList = List<String>.from(json['proVariantId']);
    }

    // Parse specifications
    List<ProductSpec> specList = [];
    if (json['specifications'] != null && json['specifications'] is List) {
      specList = (json['specifications'] as List)
          .map((e) => ProductSpec.fromJson(e))
          .toList();
    }

    // Parse tags
    List<String> tagList = [];
    if (json['tags'] != null && json['tags'] is List) {
      tagList = List<String>.from(json['tags']);
    }

    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description']?.toString(),
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      offerPrice: json['offerPrice'] != null ? (json['offerPrice']).toDouble() : null,
      images: imageList,
      category: json['proCategoryId'] is Map 
          ? CategoryRef.fromJson(json['proCategoryId']) 
          : (json['category'] is Map ? CategoryRef.fromJson(json['category']) : null),
      subCategory: json['proSubCategoryId'] is Map 
          ? CategoryRef.fromJson(json['proSubCategoryId']) 
          : null,
      brand: json['proBrandId'] is Map 
          ? CategoryRef.fromJson(json['proBrandId']) 
          : null,
      gender: json['gender'],
      // New fields
      sku: json['sku'],
      emiEligible: json['emiEligible'] ?? true,
      stockStatus: json['stockStatus'] ?? 'in_stock',
      lowStockThreshold: json['lowStockThreshold'] ?? 10,
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'] != null 
          ? ProductDimensions.fromJson(json['dimensions']) 
          : null,
      variantType: json['proVariantTypeId'] is Map 
          ? json['proVariantTypeId']['type'] 
          : null,
      variants: variantList,
      specifications: specList,
      tags: tagList,
      warranty: json['warranty'],
      featured: json['featured'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'quantity': quantity,
    'price': price,
    'offerPrice': offerPrice,
    'images': images,
    'category': category?.toJson(),
    'subCategory': subCategory?.toJson(),
    'brand': brand?.toJson(),
    'gender': gender,
    'sku': sku,
    'emiEligible': emiEligible,
    'stockStatus': stockStatus,
    'weight': weight,
    'variantType': variantType,
    'variants': variants,
    'specifications': specifications.map((s) => s.toJson()).toList(),
    'tags': tags,
    'warranty': warranty,
    'featured': featured,
    'isActive': isActive,
  };

  // Helper getters
  double get emiPerMonth => (offerPrice ?? price) / 12;

  int get discountPercentage {
    if (offerPrice == null || offerPrice! >= price) return 0;
    return (((price - offerPrice!) / price) * 100).round();
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';

  String get stockLabel {
    switch (stockStatus) {
      case 'in_stock': return 'In Stock';
      case 'out_of_stock': return 'Out of Stock';
      case 'low_stock': return 'Only $quantity left!';
      case 'pre_order': return 'Pre-Order';
      default: return 'In Stock';
    }
  }

  bool get isInStock => stockStatus != 'out_of_stock' && quantity > 0;
  bool get isLowStock => stockStatus == 'low_stock' || (quantity > 0 && quantity <= lowStockThreshold);
}

/// Product specification (Material, Fabric, Care Instructions, etc.)
class ProductSpec {
  final String key;
  final String value;

  ProductSpec({required this.key, required this.value});

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    return ProductSpec(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}

/// Product dimensions for shipping
class ProductDimensions {
  final double length;
  final double width;
  final double height;

  ProductDimensions({
    this.length = 0,
    this.width = 0,
    this.height = 0,
  });

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      length: (json['length'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'length': length,
    'width': width,
    'height': height,
  };

  String get displayString => '${length.round()} × ${width.round()} × ${height.round()} cm';
}

/// Reference to category/brand
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

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
