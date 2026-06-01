import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/model/productmodel.dart';
import '../data/model/ordermodel.dart';
import '../data/model/orderdetailmodel.dart';
import '../data/model/cartitemmodel.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot =
          await _db
              .collection('products')
              .where('status', isEqualTo: 1)
              .where('visible', isEqualTo: 1)
              .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Stream<List<ProductModel>> productsStream() {
    return _db
        .collection('products')
        .where('status', isEqualTo: 1)
        .where('visible', isEqualTo: 1)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map(
                    (doc) =>
                        ProductModel.fromJson({...doc.data(), 'id': doc.id}),
                  )
                  .toList(),
        );
  }

  static Future<List<OrderModel>> getOrdersByUser(String uid) async {
    try {
      final snapshot =
          await _db
              .collection('orders')
              .where('userId', isEqualTo: uid)
              .orderBy('orderDate', descending: true)
              .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Stream<List<OrderModel>> ordersStream(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map(
                    (doc) => OrderModel.fromJson({...doc.data(), 'id': doc.id}),
                  )
                  .toList(),
        );
  }

  static Future<List<OrderDetailModelWithName>> getOrderDetails(
    String orderId,
  ) async {
    try {
      final snapshot =
          await _db
              .collection('orders')
              .doc(orderId)
              .collection('order_details')
              .get();
      return snapshot.docs
          .map(
            (doc) => OrderDetailModelWithName.fromFirestore({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String?> addOrder({
    required String uid,
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required int totalAmount,
    required int isPayment,
    required List<CartItemModel> cartItems,
  }) async {
    try {
      final orderRef = _db.collection('orders').doc();
      final now = DateTime.now().toIso8601String();

      final orderData = {
        'userId': uid,
        'orderDate': now,
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'shippingAddress': shippingAddress,
        'totalAmount': totalAmount,
        'isPayment': isPayment,
        'orderStatus': 1,
      };

      final batch = _db.batch();
      batch.set(orderRef, orderData);

      for (final item in cartItems) {
        final detailRef = orderRef.collection('order_details').doc();
        batch.set(detailRef, {
          'productId': item.product.id?.toString() ?? '',
          'productName': item.product.productName ?? '',
          'size': item.size ?? '',
          'quantity': item.quantity,
          'unitPrice': item.product.priceSale ?? 0,
          'totalPrice': item.totalPrice,
          'image': item.product.image ?? '',
        });
      }

      await batch.commit();
      return orderRef.id;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getCart(String uid) async {
    try {
      final snapshot =
          await _db.collection('users').doc(uid).collection('cart').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCart(
    String uid,
    List<CartItemModel> cartItems,
  ) async {
    try {
      final cartRef = _db.collection('users').doc(uid).collection('cart');

      final existing = await cartRef.get();
      final batch = _db.batch();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final item in cartItems) {
        final key = '${item.product.id}_${item.size ?? 'nosize'}';
        batch.set(cartRef.doc(key), {
          'productId': item.product.id?.toString() ?? '',
          'productName': item.product.productName ?? '',
          'productCode': item.product.code ?? '',
          'categoryId': item.product.categoryId,
          'brandId': item.product.brandId,
          'cost': item.product.cost,
          'priceSale': item.product.priceSale,
          'image': item.product.image ?? '',
          'size': item.size ?? '',
          'quantity': item.quantity,
        });
      }

      await batch.commit();
    } catch (e) {}
  }

  static Future<void> clearCart(String uid) async {
    try {
      final cartRef = _db.collection('users').doc(uid).collection('cart');
      final existing = await cartRef.get();
      final batch = _db.batch();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {}
  }
}
