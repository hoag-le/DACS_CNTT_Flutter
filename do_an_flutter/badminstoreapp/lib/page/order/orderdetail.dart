import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/model/ordermodel.dart';
import '../../data/model/orderdetailmodel.dart';
import '../../services/firestore_service.dart';

class OrderDetail extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetail({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends ConsumerState<OrderDetail> {
  OrderModel? orderModel;
  List<OrderDetailModelWithName> orderDetails = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadOrderData();
  }

  Future<void> loadOrderData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        FirestoreService.getOrderById(widget.orderId),
        FirestoreService.getOrderDetails(widget.orderId),
      ]);

      setState(() {
        orderModel = results[0] as OrderModel?;
        orderDetails = results[1] as List<OrderDetailModelWithName>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Không thể tải dữ liệu đơn hàng: ${e.toString()}';
      });
    }
  }

  String formatCurrency(int? price) {
    if (price == null) return '0 đ';
    return '${NumberFormat('#,###').format(price)} đ';
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String getPaymentStatus(int? isPayment) {
    switch (isPayment) {
      case 0:
        return 'COD – Thanh toán khi nhận hàng';
      case 1:
        return 'Đã thanh toán (Momo)';
      case 2:
        return 'Đã thanh toán (VNPay)';
      default:
        return 'Chưa xác định';
    }
  }

  String getOrderStatus(int? status) {
    switch (status) {
      case 0:
        return 'Đã hủy';
      case 1:
        return 'Đang xử lý';
      case 2:
        return 'Đang giao hàng';
      case 3:
        return 'Hoàn tất';
      default:
        return 'Không xác định';
    }
  }

  Color getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  int calculateSubtotal() {
    return orderDetails.fold(0, (sum, item) => sum + (item.totalPrice ?? 0));
  }

  Future<void> _cancelOrder() async {
    // Chỉ cho phép hủy khi đang xử lý (status = 1)
    if (orderModel?.orderStatus != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ có thể hủy đơn hàng đang ở trạng thái "Đang xử lý".'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hủy đơn', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await FirestoreService.cancelOrder(widget.orderId);
    if (!mounted) return;

    if (success) {
      setState(() {
        orderModel = OrderModel(
          id: orderModel!.id,
          userId: orderModel!.userId,
          orderDate: orderModel!.orderDate,
          receiverName: orderModel!.receiverName,
          receiverPhone: orderModel!.receiverPhone,
          shippingAddress: orderModel!.shippingAddress,
          totalAmount: orderModel!.totalAmount,
          isPayment: orderModel!.isPayment,
          orderStatus: 0,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy đơn hàng thành công.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hủy đơn thất bại. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn hàng #${widget.orderId.length > 8 ? widget.orderId.substring(0, 8) : widget.orderId}',
        ),
        backgroundColor: const Color(0xFFFDF1E8),
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadOrderData),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget()
              : orderDetails.isEmpty
                  ? _buildNoDataWidget()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (orderModel != null) _buildOrderInfoSection(),
                          const SizedBox(height: 16),
                          _buildSummarySection(),
                          const SizedBox(height: 16),
                          _buildProductListSection(),
                          const SizedBox(height: 16),
                          if (orderModel?.orderStatus == 1)
                            _buildCancelButton(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(orderModel!.orderStatus)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: getStatusColor(orderModel!.orderStatus),
                  ),
                ),
                child: Text(
                  getOrderStatus(orderModel!.orderStatus),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: getStatusColor(orderModel!.orderStatus),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Ngày đặt', formatDate(orderModel!.orderDate)),
          const SizedBox(height: 6),
          _buildInfoRow(
              'Người nhận', orderModel!.receiverName ?? 'Chưa cập nhật'),
          const SizedBox(height: 6),
          _buildInfoRow(
              'Điện thoại', orderModel!.receiverPhone ?? 'Chưa cập nhật'),
          const SizedBox(height: 6),
          _buildInfoRow(
              'Địa chỉ', orderModel!.shippingAddress ?? 'Chưa cập nhật'),
          const SizedBox(height: 6),
          _buildInfoRow(
              'Thanh toán', getPaymentStatus(orderModel!.isPayment)),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final subtotal = calculateSubtotal();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Tổng sản phẩm', formatCurrency(subtotal)),
          const SizedBox(height: 8),
          _buildPriceRow('Phí vận chuyển', formatCurrency(20000)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                formatCurrency(
                    orderModel?.totalAmount ?? (subtotal + 20000)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _cancelOrder,
        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
        label: const Text(
          'Hủy đơn hàng',
          style: TextStyle(color: Colors.red, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadOrderData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy chi tiết đơn hàng',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductListSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sản phẩm đã đặt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${orderDetails.length} sản phẩm',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderDetails.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) =>
                _buildProductItem(orderDetails[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderDetailModelWithName orderDetail) {
    final imageUrl = orderDetail.image ?? '';
    final isNetworkImage = imageUrl.startsWith('http');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? (isNetworkImage
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          size: 30,
                          color: Colors.grey,
                        ),
                      )
                    : Image.asset(
                        'assets/images/products/$imageUrl',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ))
                : const Icon(
                    Icons.shopping_bag_outlined,
                    size: 30,
                    color: Colors.grey,
                  ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderDetail.productName ?? 'Sản phẩm không xác định',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              if (orderDetail.size != null && orderDetail.size!.isNotEmpty)
                Text(
                  'Size: ${orderDetail.size}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatCurrency(orderDetail.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'x${orderDetail.quantity ?? 0}',
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tổng: ${formatCurrency(orderDetail.totalPrice)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
