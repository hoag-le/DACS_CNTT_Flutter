class OrderModel {
  String? id;
  String? userId;
  String? orderDate;
  String? receiverName;
  String? receiverPhone;
  String? shippingAddress;
  int? totalAmount;
  int? isPayment;
  int? orderStatus;

  OrderModel({
    this.id,
    this.userId,
    this.orderDate,
    this.receiverName,
    this.receiverPhone,
    this.shippingAddress,
    this.totalAmount,
    this.isPayment,
    this.orderStatus,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['userId']?.toString();
    orderDate = json['orderDate'] as String?;
    receiverName = json['receiverName'] as String?;
    receiverPhone = json['receiverPhone'] as String?;
    shippingAddress = json['shippingAddress'] as String?;
    totalAmount = (json['totalAmount'] as num?)?.toInt();
    isPayment = (json['isPayment'] as num?)?.toInt();
    orderStatus = (json['orderStatus'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderDate': orderDate,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'shippingAddress': shippingAddress,
      'totalAmount': totalAmount,
      'isPayment': isPayment,
      'orderStatus': orderStatus,
    };
  }
}
