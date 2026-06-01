class OrderDetailModel {
  String? id;
  String? orderId;
  String? productId;
  int? quantity;
  int? price;
  int? totalPrice;

  OrderDetailModel({
    this.id,
    this.orderId,
    this.productId,
    this.quantity,
    this.price,
    this.totalPrice,
  });

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    orderId = json['order_id']?.toString() ?? json['orderId']?.toString();
    productId = json['product_id']?.toString() ?? json['productId']?.toString();
    quantity = json['quantity'];
    price = json['price'] ?? json['unit_price'] ?? json['unitPrice'];
    totalPrice = json['total_price'] ?? json['totalPrice'];
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': price,
      'totalPrice': totalPrice,
    };
  }
}

class OrderDetailModelWithName extends OrderDetailModel {
  String? productName;
  String? size;
  String? image;

  OrderDetailModelWithName({
    super.id,
    super.orderId,
    super.productId,
    this.size,
    super.quantity,
    super.price,
    super.totalPrice,
    this.productName,
    this.image,
  });

  factory OrderDetailModelWithName.fromFirestore(Map<String, dynamic> json) {
    return OrderDetailModelWithName(
      id: json['id']?.toString(),
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      size: json['size'],
      quantity: json['quantity'],
      price: json['unitPrice'] ?? json['unit_price'],
      totalPrice: json['totalPrice'] ?? json['total_price'],
      productName: json['productName'] ?? json['product_name'],
      image: json['image'],
    );
  }

  factory OrderDetailModelWithName.fromJson(Map<String, dynamic> json) {
    return OrderDetailModelWithName(
      id: json['id']?.toString(),
      orderId: json['order_id']?.toString(),
      productId: json['product_id']?.toString(),
      size: json['size'],
      quantity: json['quantity'],
      price: json['unit_price'] ?? json['price'],
      totalPrice: json['total_price'],
      productName: json['product_name'],
      image: json['image'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['productName'] = productName;
    data['size'] = size;
    data['image'] = image;
    return data;
  }
}