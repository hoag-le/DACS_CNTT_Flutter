import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/ordermodel.dart';
import '../../services/firestore_service.dart';

class OrderData {
  /// Đọc đơn hàng từ Firestore theo uid của user đang đăng nhập.
  /// Nếu chưa đăng nhập hoặc lỗi → trả về list rỗng.
  Future<List<OrderModel>> loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    return await FirestoreService.getOrdersByUser(uid);
  }

  /// Load toàn bộ đơn hàng theo uid cụ thể
  Future<List<OrderModel>> loadDataByUser(String uid) async {
    return await FirestoreService.getOrdersByUser(uid);
  }
}
