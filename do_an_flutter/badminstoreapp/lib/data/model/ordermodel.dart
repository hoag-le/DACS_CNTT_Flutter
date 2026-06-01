class OrderModel {
  String? id;         // Firestore document ID
  String? userId;     // Firebase Auth UID
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
    // Hỗ trợ cả id dạng String (Firestore) và int (JSON cũ)
    id = json['id']?.toString();
    userId = json['userId'] ?? json['user_id']?.toString();
    orderDate = json['orderDate'] ?? json['order_date'];
    receiverName = json['receiverName'] ?? json['receiver_name'];
    receiverPhone = json['receiverPhone'] ?? json['receiver_phone'];
    shippingAddress = json['shippingAddress'] ?? json['shipping_address'];
    totalAmount = json['totalAmount'] ?? json['total_amount'];
    isPayment = json['isPayment'] ?? json['is_payment'];
    orderStatus = json['orderStatus'] ?? json['order_status'];
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