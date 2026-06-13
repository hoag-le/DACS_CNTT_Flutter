import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/model/usermodel.dart';

class PaymentScreen extends StatefulWidget {
  final double subtotal;
  final UserModel? user;
  final String receiverName;
  final String receiverPhone;
  final String shippingAddress;

  const PaymentScreen({
    super.key,
    required this.subtotal,
    this.user,
    required this.receiverName,
    required this.receiverPhone,
    required this.shippingAddress,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'momo';

  static const double shippingFee = 20000;

  double get total => widget.subtotal + shippingFee;

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
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF8B4513),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_shopname.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressStep(1, 'Giao hàng', true),
                    _buildProgressLine(true),
                    _buildProgressStep(2, 'Thanh toán', true),
                    _buildProgressLine(false),
                    _buildProgressStep(3, 'Xác nhận', false),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PHƯƠNG THỨC VẬN CHUYỂN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Giao hàng tiêu chuẩn: ${NumberFormat('###,###').format(shippingFee)}đ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8B4513),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'PHƯƠNG THỨC THANH TOÁN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildPaymentOption(
                          'momo',
                          'assets/images/momo_icon_square_pinkbg_RGB.png',
                          'Ví Momo',
                        ),

                        const SizedBox(height: 12),

                        _buildPaymentOption(
                          'vnpay',
                          'assets/images/vnpay_icon.png',
                          'VNPAY',
                        ),

                        const SizedBox(height: 12),

                        _buildPaymentOption(
                          'cash',
                          'assets/images/cost_icon.png',
                          'Thanh toán bằng tiền mặt khi nhận hàng',
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'GIÁ TRỊ ĐƠN HÀNG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Thành tiền',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormat('###,###').format(widget.subtotal)} vnđ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Phí vận chuyển',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormat('###,###').format(shippingFee)} đ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(
                                color: Color(0xFF8B4513),
                                thickness: 1,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng số tiền',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8B4513),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormat('###,###').format(total)}vnđ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8C42), Color(0xFFFF6B1A)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_selectedPaymentMethod == 'momo' ||
                                  _selectedPaymentMethod == 'vnpay') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Thanh toán đang được phát triển, vui lòng chọn phương thức COD (tiền mặt).',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              int paymentType = 0;
                              if (_selectedPaymentMethod == 'momo') {
                                paymentType = 1;
                              }
                              if (_selectedPaymentMethod == 'vnpay') {
                                paymentType = 2;
                              }

                              context.push(
                                '/order-confirm',
                                extra: {
                                  'user': widget.user,
                                  'receiverName': widget.receiverName,
                                  'receiverPhone': widget.receiverPhone,
                                  'shippingAddress': widget.shippingAddress,
                                  'totalAmount': total.toInt(),
                                  'isPayment': paymentType,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Thanh toán',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
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
      color: isActive ? Colors.green : Colors.grey.withValues(alpha: 0.5),
    );
  }

  Widget _buildPaymentOption(String value, String iconPath, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.payment,
                  color: Color(0xFF8B4513),
                  size: 24,
                );
              },
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, color: Color(0xFF8B4513)),
        ),
        trailing: Radio<String>(
          value: value,
          groupValue: _selectedPaymentMethod,
          activeColor: Colors.red,
          onChanged: (String? newValue) {
            setState(() {
              _selectedPaymentMethod = newValue!;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
      ),
    );
  }
}
