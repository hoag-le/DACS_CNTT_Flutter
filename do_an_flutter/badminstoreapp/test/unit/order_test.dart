import 'package:flutter_test/flutter_test.dart';
import 'package:badminstoreapp/data/model/ordermodel.dart';
import 'package:badminstoreapp/data/model/orderdetailmodel.dart';

void main() {
  group('OrderModel Tests', () {
    test('fromJson and toJson map correctly', () {
      final json = {
        'id': 'order_1',
        'userId': 'user_1',
        'orderDate': '2023-01-01',
        'receiverName': 'John Doe',
        'receiverPhone': '1234567890',
        'shippingAddress': '123 Main St',
        'totalAmount': 500000,
        'isPayment': 1,
        'orderStatus': 0,
      };

      final order = OrderModel.fromJson(json);

      expect(order.id, 'order_1');
      expect(order.userId, 'user_1');
      expect(order.totalAmount, 500000);

      final exportedJson = order.toJson();
      expect(exportedJson['userId'], 'user_1');
      expect(exportedJson['totalAmount'], 500000);
    });

    test('fromJson handles snake_case keys', () {
      final json = {
        'user_id': 'user_1',
        'order_date': '2023-01-01',
        'receiver_name': 'John Doe',
        'receiver_phone': '1234567890',
        'shipping_address': '123 Main St',
        'total_amount': 500000,
        'is_payment': 1,
        'order_status': 0,
      };

      final order = OrderModel.fromJson(json);

      expect(order.userId, 'user_1');
      expect(order.totalAmount, 500000);
      expect(order.receiverName, 'John Doe');
    });
  });

  group('OrderDetailModel Tests', () {
    test('fromJson and toJson map correctly', () {
      final json = {
        'id': 'detail_1',
        'orderId': 'order_1',
        'productId': 'prod_1',
        'quantity': 2,
        'unitPrice': 50000,
        'totalPrice': 100000,
      };

      final detail = OrderDetailModel.fromJson(json);

      expect(detail.id, 'detail_1');
      expect(detail.orderId, 'order_1');
      expect(detail.quantity, 2);
      expect(detail.price, 50000);
      expect(detail.totalPrice, 100000);
    });
    
    test('OrderDetailModelWithName fromFirestore works correctly', () {
      final json = {
        'id': 'detail_1',
        'orderId': 'order_1',
        'productId': 'prod_1',
        'quantity': 2,
        'unitPrice': 50000,
        'totalPrice': 100000,
        'productName': 'Test Product',
        'size': 'L',
        'image': 'test.png',
      };

      final detail = OrderDetailModelWithName.fromFirestore(json);

      expect(detail.productName, 'Test Product');
      expect(detail.size, 'L');
      expect(detail.image, 'test.png');
      expect(detail.totalPrice, 100000);
    });
  });
}
