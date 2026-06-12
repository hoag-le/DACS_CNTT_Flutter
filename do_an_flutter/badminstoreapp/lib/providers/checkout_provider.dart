import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../data/model/cartitemmodel.dart';
import '../data/model/usermodel.dart';

class CheckoutController extends StateNotifier<AsyncValue<void>> {
  CheckoutController() : super(const AsyncData(null));

  Future<bool> placeOrder({
    required UserModel? user,
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required int totalAmount,
    required int isPayment,
    required List<CartItemModel> cartItems,
  }) async {
    state = const AsyncLoading();

    final uid = FirebaseAuth.instance.currentUser?.uid ?? user?.uid;

    if (uid != null && cartItems.isNotEmpty) {
      try {
        final orderId = await FirestoreService.addOrder(
          uid: uid,
          receiverName: receiverName,
          receiverPhone: receiverPhone,
          shippingAddress: shippingAddress,
          totalAmount: totalAmount,
          isPayment: isPayment,
          cartItems: cartItems,
        );

        if (orderId == null) {
          throw Exception('Không thể tạo đơn hàng');
        }
        
        await FirestoreService.clearCart(uid);
        state = const AsyncData(null);
        return true;
      } catch (e, st) {
        state = AsyncError(e, st);
        return false;
      }
    }

    state = AsyncError(
      Exception("User is null or cart is empty"),
      StackTrace.current,
    );
    return false;
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutController, AsyncValue<void>>((ref) {
      return CheckoutController();
    });
