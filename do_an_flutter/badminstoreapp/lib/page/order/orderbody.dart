import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/model/ordermodel.dart';
import '../../data/model/orderdetailmodel.dart';
import '../../data/model/productmodel.dart';
import '../../page/order/orderdetail.dart';
import 'package:go_router/go_router.dart';
Widget itemOrderView(
  OrderModel orderModel,
  List<OrderDetailModelWithName> orderDetails,
  List<ProductModel> products,
  WidgetRef ref,
) {
  String formatCurrency(int? price) {
    if (price == null) return '0 đ';
    return NumberFormat('#,###').format(price) + ' đ';
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
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

  IconData getStatusIcon(int? status) {
    switch (status) {
      case 0:
        return Icons.cancel;
      case 1:
        return Icons.hourglass_empty;
      case 2:
        return Icons.local_shipping;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  List<OrderDetailModelWithName> getOrderDetailItems() {
    return orderDetails;
  }

  int getTotalProductCount() {
    return orderDetails.fold(0, (sum, detail) => sum + (detail.quantity ?? 0));
  }

  int totalProducts = getTotalProductCount();

  return GestureDetector(
    onTap: () {
      ref.context.push('/personal/order-detail', extra: orderModel.id ?? '');
    },
    child: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Đơn hàng #${orderModel.id ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              formatDate(orderModel.orderDate),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            getStatusIcon(orderModel.orderStatus),
                            size: 16,
                            color: getStatusColor(orderModel.orderStatus),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              getOrderStatus(orderModel.orderStatus),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: getStatusColor(orderModel.orderStatus),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sản phẩm',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalProducts Sản phẩm',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tổng tiền',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(orderModel.totalAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
