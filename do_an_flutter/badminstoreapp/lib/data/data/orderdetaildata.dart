import '../model/orderdetailmodel.dart';
import '../../services/firestore_service.dart';

class OrderDetailData {
  /// Lấy chi tiết đơn hàng từ Firestore sub-collection
  Future<List<OrderDetailModelWithName>> loadDataByOrder(String orderId) async {
    return await FirestoreService.getOrderDetails(orderId);
  }

  /// Compatibility: load tất cả (không còn dùng JSON)
  Future<List<OrderDetailModel>> loadData() async {
    // Không còn load từ JSON — trả về rỗng
    // Dùng loadDataByOrder(orderId) thay thế
    return [];
  }
}
