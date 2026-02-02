/// Store model with dummy data for popular stores
class Store {
  final String id;
  final String name;
  final String logo;
  final String banner;
  final String description;
  final double rating;
  final String category;
  final int productCount;
  final List<String> tags;
  final String brandColor; // Hex color for fallback

  Store({
    required this.id,
    required this.name,
    required this.logo,
    required this.banner,
    required this.description,
    required this.rating,
    required this.category,
    required this.productCount,
    this.tags = const [],
    this.brandColor = '#006D77',
  });

  /// Get all dummy stores
  static List<Store> getDummyStores() {
    return [
      // Fashion Stores
      Store(
        id: 'store_hm',
        name: 'H&M',
        logo: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
        description: 'Fashion and quality at the best price. Explore the latest trends in clothing, accessories, and more.',
        rating: 4.5,
        category: 'Fashion',
        productCount: 2500,
        tags: ['Fashion', 'Clothing', 'Accessories'],
        brandColor: '#E50010',
      ),
      Store(
        id: 'store_zara',
        name: 'Zara',
        logo: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800',
        description: 'Latest fashion trends for women, men and kids at ZARA online. Find the best styles and latest collections.',
        rating: 4.6,
        category: 'Fashion',
        productCount: 1800,
        tags: ['Fashion', 'Premium', 'International'],
        brandColor: '#000000',
      ),
      Store(
        id: 'store_forever21',
        name: 'Forever 21',
        logo: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
        description: 'Shop the latest trends in fashion and accessories for women, men, and girls.',
        rating: 4.2,
        category: 'Fashion',
        productCount: 1200,
        tags: ['Fashion', 'Youth', 'Trendy'],
        brandColor: '#FFD700',
      ),
      Store(
        id: 'store_levis',
        name: "Levi's",
        logo: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800',
        description: 'The inventor of the blue jean. Iconic jeans, jackets, and apparel for men and women.',
        rating: 4.7,
        category: 'Fashion',
        productCount: 800,
        tags: ['Denim', 'Classic', 'Premium'],
        brandColor: '#C41230',
      ),
      
      // Beauty & Personal Care
      Store(
        id: 'store_nykaa',
        name: 'Nykaa',
        logo: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=800',
        description: 'India\'s premier beauty destination. Shop makeup, skincare, haircare, and wellness products.',
        rating: 4.4,
        category: 'Beauty',
        productCount: 5000,
        tags: ['Beauty', 'Makeup', 'Skincare'],
        brandColor: '#FC2779',
      ),
      Store(
        id: 'store_mamaearth',
        name: 'Mamaearth',
        logo: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?w=800',
        description: 'Toxin-free, natural skincare and baby care products. Made with love from nature.',
        rating: 4.3,
        category: 'Beauty',
        productCount: 400,
        tags: ['Natural', 'Organic', 'Baby Care'],
        brandColor: '#00A651',
      ),
      Store(
        id: 'store_loreal',
        name: "L'Oreal Paris",
        logo: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=800',
        description: 'Because you\'re worth it. Premium beauty products for skincare, haircare, and makeup.',
        rating: 4.6,
        category: 'Beauty',
        productCount: 600,
        tags: ['Premium', 'International', 'Professional'],
        brandColor: '#000000',
      ),
      
      // Sports & Fitness
      Store(
        id: 'store_nike',
        name: 'Nike',
        logo: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        description: 'Just Do It. Shop the latest sneakers, athletic clothing, and sports gear.',
        rating: 4.8,
        category: 'Sports',
        productCount: 2000,
        tags: ['Sports', 'Sneakers', 'Athletic'],
        brandColor: '#000000',
      ),
      Store(
        id: 'store_adidas',
        name: 'Adidas',
        logo: 'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=800',
        description: 'Impossible is Nothing. Premium sportswear, sneakers, and athletic accessories.',
        rating: 4.7,
        category: 'Sports',
        productCount: 1800,
        tags: ['Sports', 'Sneakers', 'Originals'],
        brandColor: '#000000',
      ),
      Store(
        id: 'store_puma',
        name: 'Puma',
        logo: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800',
        description: 'Forever Faster. Sports footwear, apparel, and accessories for athletes.',
        rating: 4.5,
        category: 'Sports',
        productCount: 1200,
        tags: ['Sports', 'Running', 'Training'],
        brandColor: '#000000',
      ),
      Store(
        id: 'store_reebok',
        name: 'Reebok',
        logo: 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=800',
        description: 'Be More Human. Fitness footwear and apparel for training and lifestyle.',
        rating: 4.4,
        category: 'Sports',
        productCount: 900,
        tags: ['Fitness', 'CrossFit', 'Training'],
        brandColor: '#D81B3C',
      ),
      
      // Electronics
      Store(
        id: 'store_boat',
        name: 'boAt',
        logo: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        description: 'India\'s #1 audio brand. Shop wireless earbuds, headphones, speakers, and more.',
        rating: 4.3,
        category: 'Electronics',
        productCount: 300,
        tags: ['Audio', 'Wireless', 'Indian'],
        brandColor: '#FC0000',
      ),
      Store(
        id: 'store_samsung',
        name: 'Samsung',
        logo: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=800',
        description: 'Do What You Can\'t. Smartphones, TVs, appliances, and electronics.',
        rating: 4.6,
        category: 'Electronics',
        productCount: 1500,
        tags: ['Smartphones', 'TVs', 'Appliances'],
        brandColor: '#1428A0',
      ),
      Store(
        id: 'store_apple',
        name: 'Apple',
        logo: 'https://images.unsplash.com/photo-1491933382434-500287f9b54b?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1491933382434-500287f9b54b?w=800',
        description: 'Think Different. iPhone, iPad, Mac, Apple Watch, and accessories.',
        rating: 4.9,
        category: 'Electronics',
        productCount: 200,
        tags: ['Premium', 'iPhone', 'Mac'],
        brandColor: '#000000',
      ),
      Store(
        id: 'store_oneplus',
        name: 'OnePlus',
        logo: 'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=800',
        description: 'Never Settle. Premium smartphones and audio products.',
        rating: 4.5,
        category: 'Electronics',
        productCount: 100,
        tags: ['Smartphones', 'Flagship', 'Audio'],
        brandColor: '#EB0029',
      ),
      
      // Home & Kitchen
      Store(
        id: 'store_ikea',
        name: 'IKEA',
        logo: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
        description: 'Creating a better everyday life. Furniture and home accessories for everyone.',
        rating: 4.4,
        category: 'Home',
        productCount: 3000,
        tags: ['Furniture', 'Decor', 'Affordable'],
        brandColor: '#0051BA',
      ),
      Store(
        id: 'store_homecenter',
        name: 'Home Centre',
        logo: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
        description: 'Make your home beautiful. Furniture, decor, and lifestyle products.',
        rating: 4.2,
        category: 'Home',
        productCount: 2000,
        tags: ['Furniture', 'Lifestyle', 'Indian'],
        brandColor: '#ED1C24',
      ),
      
      // Watches & Accessories
      Store(
        id: 'store_titan',
        name: 'Titan',
        logo: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=800',
        description: 'Be More. India\'s leading watch brand with elegant timepieces.',
        rating: 4.6,
        category: 'Accessories',
        productCount: 500,
        tags: ['Watches', 'Premium', 'Indian'],
        brandColor: '#8B4513',
      ),
      Store(
        id: 'store_fossil',
        name: 'Fossil',
        logo: 'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e?w=200&h=200&fit=crop',
        banner: 'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e?w=800',
        description: 'Authentic vintage style watches, bags, and accessories.',
        rating: 4.5,
        category: 'Accessories',
        productCount: 400,
        tags: ['Watches', 'Bags', 'Vintage'],
        brandColor: '#000000',
      ),
    ];
  }

  /// Get stores by category
  static List<Store> getStoresByCategory(String category) {
    if (category == 'All') return getDummyStores();
    return getDummyStores().where((s) => s.category == category).toList();
  }

  /// Get store categories
  static List<String> getCategories() {
    return ['All', 'Fashion', 'Beauty', 'Sports', 'Electronics', 'Home', 'Accessories'];
  }

  /// Search stores
  static List<Store> searchStores(String query) {
    final lower = query.toLowerCase();
    return getDummyStores().where((s) => 
      s.name.toLowerCase().contains(lower) ||
      s.category.toLowerCase().contains(lower) ||
      s.tags.any((t) => t.toLowerCase().contains(lower))
    ).toList();
  }
}
