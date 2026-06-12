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
    orderId = json['orderId']?.toString();
    productId = json['productId']?.toString();
    quantity = (json['quantity'] as num?)?.toInt();
    price = (json['unitPrice'] as num?)?.toInt();
    totalPrice = (json['totalPrice'] as num?)?.toInt();
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
      orderId: json['orderId']?.toString(),
      productId: json['productId']?.toString(),
      size: json['size'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      price: (json['unitPrice'] as num?)?.toInt(),
      totalPrice: (json['totalPrice'] as num?)?.toInt(),
      productName: json['productName'] as String?,
      image: json['image'] as String?,
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
