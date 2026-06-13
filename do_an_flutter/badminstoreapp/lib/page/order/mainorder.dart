import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/model/ordermodel.dart';
import '../../data/model/orderdetailmodel.dart';
import '../../data/model/usermodel.dart';
import '../../data/model/user_provider.dart';
import '../../services/firestore_service.dart';
import '../order/orderbody.dart';
import 'package:go_router/go_router.dart';

class MainOrder extends ConsumerStatefulWidget {
  final UserModel? user;

  const MainOrder({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<MainOrder> createState() => _MainOrderState();
}

class _MainOrderState extends ConsumerState<MainOrder>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> userOrders = [];
  bool isLoading = true;
  String selectedFilter = 'all';
  String? errorMessage;

  final Map<String, List<OrderDetailModelWithName>> _orderDetailsCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? widget.user?.uid;
      if (uid == null) {
        setState(() {
          userOrders = [];
          isLoading = false;
        });
        return;
      }

      final orders = await FirestoreService.getOrdersByUser(uid);

      setState(() {
        userOrders = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<List<OrderDetailModelWithName>> getOrderDetails(String orderId) async {
    if (_orderDetailsCache.containsKey(orderId)) {
      return _orderDetailsCache[orderId]!;
    }
    final details = await FirestoreService.getOrderDetails(orderId);
    _orderDetailsCache[orderId] = details;
    return details;
  }

  List<OrderModel> getFilteredOrders() {
    if (selectedFilter == 'all') return userOrders;
    int statusFilter = int.parse(selectedFilter);
    return userOrders
        .where((order) => order.orderStatus == statusFilter)
        .toList();
  }

  int getOrderCountByStatus(String status) {
    if (status == 'all') return userOrders.length;
    int statusValue = int.parse(status);
    return userOrders.where((order) => order.orderStatus == statusValue).length;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUser =
        widget.user ?? ref.watch(currentUserProfileProvider).value;

    if (resolvedUser == null && FirebaseAuth.instance.currentUser == null) {
      return _buildNotLoggedInState();
    }

    final filteredOrders = getFilteredOrders();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Đơn hàng của bạn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            if (resolvedUser?.fullname != null)
              Text(
                resolvedUser!.fullname!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.brown,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFDF1E8),
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.brown),
            onPressed: loadData,
            tooltip: 'Làm mới',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.brown,
          indicatorColor: Colors.orange,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  selectedFilter = 'all';
                  break;
                case 1:
                  selectedFilter = '1';
                  break;
                case 2:
                  selectedFilter = '2';
                  break;
                case 3:
                  selectedFilter = '3';
                  break;
                case 4:
                  selectedFilter = '0';
                  break;
              }
            });
          },
          tabs: [
            Tab(text: 'Tất cả (${getOrderCountByStatus('all')})'),
            Tab(text: 'Đang xử lý (${getOrderCountByStatus('1')})'),
            Tab(text: 'Đang giao (${getOrderCountByStatus('2')})'),
            Tab(text: 'Hoàn tất (${getOrderCountByStatus('3')})'),
            Tab(text: 'Đã hủy (${getOrderCountByStatus('0')})'),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Đang tải đơn hàng...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                onRefresh: loadData,
                child:
                    filteredOrders.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return FutureBuilder<
                              List<OrderDetailModelWithName>
                            >(
                              future: getOrderDetails(order.id ?? ''),
                              builder: (context, snapshot) {
                                final details = snapshot.data ?? [];
                                return itemOrderView(
                                  order,
                                  details,
                                  ref,
                                );
                              },
                            );
                          },
                        ),
              ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Đơn hàng của bạn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFDF1E8),
        elevation: 2,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn cần đăng nhập',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng đăng nhập để xem đơn hàng của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'Bạn chưa có đơn hàng nào';
    IconData icon = Icons.shopping_bag_outlined;

    switch (selectedFilter) {
      case '0':
        message = 'Không có đơn hàng bị hủy';
        icon = Icons.cancel_outlined;
        break;
      case '1':
        message = 'Không có đơn hàng đang xử lý';
        icon = Icons.hourglass_empty_outlined;
        break;
      case '2':
        message = 'Không có đơn hàng đang giao';
        icon = Icons.local_shipping_outlined;
        break;
      case '3':
        message = 'Không có đơn hàng đã hoàn tất';
        icon = Icons.check_circle_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kéo xuống để làm mới',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (selectedFilter == 'all') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Mua sắm ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
