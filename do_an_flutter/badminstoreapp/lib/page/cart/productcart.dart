import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../conf/const.dart';
import '../../data/model/product_viewmodel.dart';
import '../../data/model/cartitemmodel.dart';
import 'package:go_router/go_router.dart';
import '../../data/model/usermodel.dart';
import '../../widgets/app_state_widgets.dart';

class ProductCart extends ConsumerStatefulWidget {
  const ProductCart({super.key, this.user});
  final UserModel? user;
  @override
  _ProductCartState createState() => _ProductCartState();
}

class _ProductCartState extends ConsumerState<ProductCart> {
  bool _isLoadingTotal = false;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartItemsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8A87C),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8A87C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Giỏ hàng${cartItems.isNotEmpty ? ' (${ref.watch(productsProvider.notifier).cartItemsCount})' : ''}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body:
          cartItems.isEmpty
              ? _buildEmptyCart(context)
              : _buildCartWithItems(context, ref, cartItems),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return const AppEmptyWidget(
      message: 'Chưa thấy sản phẩm trong giỏ hàng của bạn',
      icon: Icons.shopping_cart_outlined,
    );
  }

  Widget _buildCartWithItems(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> cartItems,
  ) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return CartItemWidget(
                  cartItem: cartItems[index],
                  index: index,
                  onUpdateQuantity: (newQuantity) {
                    _updateQuantity(ref, index, newQuantity);
                  },
                  onDelete: () {
                    _showDeleteConfirmDialog(
                        context, ref, index, cartItems[index]);
                  },
                );
              },
            ),
          ),
        ),
        if (_isLoadingTotal)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
        _buildCartSummary(context, ref, cartItems),
      ],
    );
  }


  Widget _buildCartSummary(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> cartItems,
  ) {
    final subtotal = ref.watch(productsProvider.notifier).cartTotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng phụ:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Text(
                '${NumberFormat('###,###').format(subtotal)} đ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí shipping:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Text(
                'Tính sau khi thanh toán',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${NumberFormat('###,###').format(subtotal)} đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showCheckoutDialog(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(WidgetRef ref, int index, int newQuantity) async {
    setState(() {
      _isLoadingTotal = true;
    });
    await Future.delayed(const Duration(milliseconds: 300));

    ref
        .read(productsProvider.notifier)
        .updateCartItemQuantity(index, newQuantity);

    setState(() {
      _isLoadingTotal = false;
    });
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    CartItemModel cartItem,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content: Text(
            'Bạn có chắc chắn muốn xóa "${cartItem.product.productName}" khỏi giỏ hàng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                ref.read(productsProvider.notifier).removeFromCart(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Kiểm tra giỏ hàng trước khi thanh toán'),
          content: const Text(
            'Bạn có chắc chắn muốn tiếp tục thanh toán không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final subtotal =
                    ref.watch(productsProvider.notifier).cartTotal.toDouble();
                Navigator.of(dialogContext).pop();
                context.push(
                  '/shipping-address',
                  extra: {
                    'subtotal': subtotal,
                    'user': widget.user,
                  },
                );
              },
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    );
  }
}

class EmptyCartPage extends ProductCart {
  const EmptyCartPage({super.key, UserModel? user});
}

class CartItemWidget extends StatefulWidget {
  final CartItemModel cartItem;
  final int index;
  final Function(int) onUpdateQuantity;
  final VoidCallback onDelete;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.index,
    required this.onUpdateQuantity,
    required this.onDelete,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(
      text: widget.cartItem.quantity.toString(),
    );
    quantityController.addListener(_onQuantityChanged);
  }

  @override
  void didUpdateWidget(CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartItem.quantity != widget.cartItem.quantity) {
      if (quantityController.text != widget.cartItem.quantity.toString()) {
        quantityController.text = widget.cartItem.quantity.toString();
      }
    }
  }

  void _onQuantityChanged() {
    int? newQuantity = int.tryParse(quantityController.text);
    if (newQuantity != null &&
        newQuantity > 0 &&
        newQuantity != widget.cartItem.quantity) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && newQuantity == int.tryParse(quantityController.text)) {
          widget.onUpdateQuantity(newQuantity);
        }
      });
    }
  }

  @override
  void dispose() {
    quantityController.removeListener(_onQuantityChanged);
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItem = widget.cartItem;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  '$uri_product_img${cartItem.product.image}',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.product.productName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    if (cartItem.product.cost != null)
                      Text(
                        '${NumberFormat('###,###').format(cartItem.product.cost)} đ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),

                    Text(
                      '${NumberFormat('###,###').format(cartItem.product.priceSale)} đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),

                    if (cartItem.size != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Size: ${cartItem.size}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () {
                        if (cartItem.quantity > 1) {
                          widget.onUpdateQuantity(cartItem.quantity - 1);
                          quantityController.text =
                              (cartItem.quantity - 1).toString();
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        widget.onUpdateQuantity(cartItem.quantity + 1);
                        quantityController.text =
                            (cartItem.quantity + 1).toString();
                      },
                    ),
                  ),
                ],
              ),

              Text(
                '${NumberFormat('###,###').format(cartItem.totalPrice)} đ',
                style: const TextStyle(
                  fontSize: 16,
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
}
