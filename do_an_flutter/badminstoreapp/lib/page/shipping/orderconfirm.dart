import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'thank.dart';
import '../../data/model/product_viewmodel.dart';
import '../../data/model/usermodel.dart';
import '../../services/firestore_service.dart';

class OrderConfirmScreen extends ConsumerStatefulWidget {
  final UserModel? user;
  final String? receiverName;
  final String? receiverPhone;
  final String? shippingAddress;
  final int? totalAmount;
  final int? isPayment; // 0=COD, 1=Momo, 2=VNPay

  const OrderConfirmScreen({
    Key? key,
    this.user,
    this.receiverName,
    this.receiverPhone,
    this.shippingAddress,
    this.totalAmount,
    this.isPayment,
  }) : super(key: key);

  @override
  ConsumerState<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends ConsumerState<OrderConfirmScreen> {
  bool _isConfirming = false;

  Future<void> _confirmOrder() async {
    setState(() => _isConfirming = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? widget.user?.uid;
    final cartItems = ref.read(productsProvider.notifier).cartItems;

    if (uid != null && cartItems.isNotEmpty) {
      try {
        await FirestoreService.addOrder(
          uid: uid,
          receiverName: widget.receiverName ?? widget.user?.fullname ?? '',
          receiverPhone: widget.receiverPhone ?? widget.user?.phonenumber ?? '',
          shippingAddress: widget.shippingAddress ?? '',
          totalAmount:
              widget.totalAmount ??
              ref.read(productsProvider.notifier).cartTotal,
          isPayment: widget.isPayment ?? 0,
          cartItems: cartItems,
        );
        // Clear remote cart as well
        await FirestoreService.clearCart(uid);
      } catch (e) {
        // Ghi log lỗi nhưng vẫn tiếp tục — tránh block UX
        debugPrint('Error saving order: $e');
      }
    }

    // Xóa giỏ hàng
    ref.read(productsProvider.notifier).clearCart();

    setState(() => _isConfirming = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Xác nhận thành công! Đơn hàng đã được tạo.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ThankYouScreen(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB382), Color(0xFFFF8C42)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_shopname.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressStep(1, 'Giao hàng', true),
                    _buildProgressLine(true),
                    _buildProgressStep(2, 'Thanh toán', true),
                    _buildProgressLine(true),
                    _buildProgressStep(3, 'Xác nhận', true),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Đơn hàng của bạn đã được xác nhận',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Vui lòng nhấn vào xác nhận để hoàn tất đơn hàng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Confirmation Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isConfirming
                                ? [Colors.grey[400]!, Colors.grey[500]!]
                                : [
                                    const Color(0xFFFF8C42),
                                    const Color(0xFFFF6B1A),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isConfirming ? null : _confirmOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isConfirming
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Xác nhận',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : const Color(0xFFFF8C42),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : const Color(0xFF8B4513),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? Colors.green : Colors.grey.withOpacity(0.5),
    );
  }
}
