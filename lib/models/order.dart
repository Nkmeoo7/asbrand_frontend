/// Order model matching backend Order schema
class Order {
  final String id;
  final String? userId;
  final DateTime orderDate;
  final String orderStatus;
  final List<OrderItem> items;
  final double totalPrice;
  final ShippingAddress? shippingAddress;
  final String? paymentMethod;
  final String? couponCode;
  final OrderTotal? orderTotal;
  final String? trackingUrl;

  Order({
    required this.id,
    this.userId,
    required this.orderDate,
    required this.orderStatus,
    required this.items,
    required this.totalPrice,
    this.shippingAddress,
    this.paymentMethod,
    this.couponCode,
    this.orderTotal,
    this.trackingUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userID'] is Map ? json['userID']['_id'] : json['userID'],
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : DateTime.now(),
      orderStatus: json['orderStatus'] ?? 'pending',
      items: (json['items'] as List?)?.map((e) => OrderItem.fromJson(e)).toList() ?? [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      shippingAddress: json['shippingAddress'] != null ? ShippingAddress.fromJson(json['shippingAddress']) : null,
      paymentMethod: json['paymentMethod'],
      couponCode: json['couponCode']?.toString(),
      orderTotal: json['orderTotal'] != null ? OrderTotal.fromJson(json['orderTotal']) : null,
      trackingUrl: json['trackingUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'shippingAddress': shippingAddress?.toJson(),
      'paymentMethod': paymentMethod,
      'couponCode': couponCode,
      'orderTotal': orderTotal?.toJson(),
    };
  }
}

class OrderItem {
  final String? productId;
  final String productName;
  final int quantity;
  final double price;
  final String? variant;

  OrderItem({
    this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.variant,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productID'] is Map ? json['productID']['_id'] : json['productID'],
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      variant: json['variant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'variant': variant,
    };
  }
}

class ShippingAddress {
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  ShippingAddress({
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      phone: json['phone'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

class OrderTotal {
  final double subtotal;
  final double discount;
  final double total;

  OrderTotal({
    required this.subtotal,
    this.discount = 0,
    required this.total,
  });

  factory OrderTotal.fromJson(Map<String, dynamic> json) {
    return OrderTotal(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
    };
  }
}
