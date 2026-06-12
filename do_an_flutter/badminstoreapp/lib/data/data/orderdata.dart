import 'package:firebase_auth/firebase_auth.dart';
import '../model/ordermodel.dart';
import '../../services/firestore_service.dart';

class OrderData {
  Future<List<OrderModel>> loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    return await FirestoreService.getOrdersByUser(uid);
  }

  Future<List<OrderModel>> loadDataByUser(String uid) async {
    return await FirestoreService.getOrdersByUser(uid);
  }
}
