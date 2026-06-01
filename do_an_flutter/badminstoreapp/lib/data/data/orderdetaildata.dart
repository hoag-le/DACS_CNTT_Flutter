import '../model/orderdetailmodel.dart';
import '../../services/firestore_service.dart';

class OrderDetailData {
  Future<List<OrderDetailModelWithName>> loadDataByOrder(String orderId) async {
    return await FirestoreService.getOrderDetails(orderId);
  }

  Future<List<OrderDetailModel>> loadData() async {
    return [];
  }
}
