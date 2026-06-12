import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data/productdata.dart';
import '../../data/model/productmodel.dart';
import '../../data/data/productsizedata.dart';
import '../../data/model/productsizemodel.dart';
import '../../data/data/racketdata.dart';
import '../../data/model/racketinfomodel.dart';
import '../../data/data/shoedata.dart';
import '../../data/model/shoeinfomodel.dart';
import '../../data/data/clothingdata.dart';
import '../../data/model/clothinginfomodel.dart';
import '../../data/data/bagaccessorydata.dart';
import '../../data/model/bagaccessorymodel.dart';
import '../../conf/const.dart';
import '../../data/model/product_viewmodel.dart';
import '../product/productbody.dart';
import '../../data/data/branddata.dart';
import '../../data/model/brandmodel.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class MainDetail extends ConsumerStatefulWidget {
  final int productId;

  const MainDetail({super.key, required this.productId});

  @override
  ConsumerState<MainDetail> createState() => _MainDetailState();
}

class _MainDetailState extends ConsumerState<MainDetail> {
  ProductModel? product;
  List<ProductSizeModel> productSizes = [];
  List<RacketInfoModel> racketInfos = [];
  List<ShoeInfoModel> shoeInfos = [];
  List<ClothingInfoModel> clothingInfos = [];
  List<BagAccessoryModel> bagAccessoryInfos = [];
  List<ProductModel> allProducts = [];
  bool isLoading = true;
  String? selectedSize;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    loadProductData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  Future<void> _showQuantityInputDialog() async {
    final TextEditingController tempQuantityController = TextEditingController(
      text: _quantity.toString(),
    );

    final newQuantity = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Nhập số lượng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: tempQuantityController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Số lượng',
                  ),
                  onSubmitted: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      Navigator.pop(context, parsed);
                    } else {
                      Navigator.pop(context, _quantity);
                    }
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final parsed = int.tryParse(
                          tempQuantityController.text,
                        );
                        if (parsed != null && parsed > 0) {
                          Navigator.pop(context, parsed);
                        } else {
                          Navigator.pop(context, _quantity);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (newQuantity != null) {
      setState(() {
        _quantity = newQuantity;
      });
    }
  }

  Future<void> loadProductData() async {
    try {
      final products = await ReadData().loadData();
      final sizes = await ProductSizeData().loadData();
      final rackets = await RacketData().loadData();
      final shoes = await ShoeData().loadData();
      final clothing = await ClothingData().loadData();
      final bagAccessory = await BagAccessoryData().loadData();

      setState(() {
        allProducts = products;
        product = products.firstWhere((p) => p.id == widget.productId);
        productSizes =
            sizes.where((s) => s.productId == widget.productId).toList();
        racketInfos =
            rackets.where((r) => r.productId == widget.productId).toList();
        shoeInfos =
            shoes.where((s) => s.productId == widget.productId).toList();
        clothingInfos =
            clothing.where((c) => c.productId == widget.productId).toList();
        bagAccessoryInfos =
            bagAccessory.where((b) => b.productId == widget.productId).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int getProductType() {
    if (product?.categoryId == null) return 0;

    int categoryId = product!.categoryId!;

    if (categoryId == 1) return 2;
    if (categoryId == 2) return 1;
    if (categoryId >= 3 && categoryId <= 5) return 3;
    if (categoryId >= 6 && categoryId <= 8) return 4;

    return 0;
  }

  bool isProductInFavorites() {
    final favorites = ref.watch(productsProvider).favorites;
    return favorites.any((p) => p.id == product?.id);
  }

  void _addToCart() {
    if (productSizes.isNotEmpty && selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn size trước khi thêm vào giỏ hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (product != null) {
      ref
          .read(productsProvider.notifier)
          .addToCart(product!, _quantity, selectedSize);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm $_quantity sản phẩm vào giỏ hàng'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _buyNow() {
    if (productSizes.isNotEmpty && selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn size trước khi mua'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (product != null) {
      ref
          .read(productsProvider.notifier)
          .addToCart(product!, _quantity, selectedSize);

      context.push('/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      return Scaffold(body: Center(child: Text('Product not found')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.brown),
            onPressed: () {
              context.push('/cart/empty');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderProduct(product: product!),
            if (productSizes.isNotEmpty)
              SizeSelector(
                sizes: productSizes,
                selectedSize: selectedSize,
                onSizeSelected: (size) {
                  setState(() {
                    selectedSize = size;
                  });
                },
              ),
            ProductInfo(
              product: product!,
              productType: getProductType(),
              racketInfo: racketInfos.isNotEmpty ? racketInfos.first : null,
              shoeInfo: shoeInfos.isNotEmpty ? shoeInfos.first : null,
              clothingInfo:
                  clothingInfos.isNotEmpty ? clothingInfos.first : null,
              bagAccessoryInfo:
                  bagAccessoryInfos.isNotEmpty ? bagAccessoryInfos.first : null,
            ),
            RecommendedProducts(
              currentProductId: widget.productId,
              allProducts: allProducts,
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.remove, size: 20),
                onPressed: _decrementQuantity,
              ),
            ),
            GestureDetector(
              onTap: _showQuantityInputDialog,
              child: Container(
                width: 60,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _quantity.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.add, size: 20),
                onPressed: _incrementQuantity,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[200],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _addToCart();
                },
                child: Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _buyNow();
                },
                child: Text(
                  'Mua ngay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderProduct extends ConsumerWidget {
  final ProductModel product;

  const HeaderProduct({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(productsProvider).favorites;
    final isInFavorites = favorites.any((p) => p.id == product.id);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Image.asset(
              '$uri_product_img${product.image}',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),

          Text(
            product.productName ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã: ${product.code ?? ''}',
                style: TextStyle(fontSize: 14, color: Colors.orange),
              ),
              IconButton(
                icon: Icon(
                  isInFavorites ? Icons.favorite : Icons.favorite_border,
                  color: isInFavorites ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  if (isInFavorites) {
                    final index = favorites.indexWhere(
                      (p) => p.id == product.id,
                    );
                    if (index != -1) {
                      ref
                          .read(productsProvider.notifier)
                          .removeFromFavorite(index);
                    }
                  } else {
                    ref.read(productsProvider.notifier).addToFavorite(product);
                  }
                },
              ),
            ],
          ),

          Row(
            children: [
              Text(
                'Thương hiệu: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              FutureBuilder<List<BrandModel>>(
                future: BrandData().loadData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Đang tải...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Lỗi tải thương hiệu',
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    );
                  } else {
                    final brandList = snapshot.data!;
                    final brand = brandList.firstWhere(
                      (b) => b.id == product.brandId,
                      orElse: () => BrandModel(brandName: 'Không rõ'),
                    );
                    return Text(
                      brand.brandName ?? 'Không rõ',
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    );
                  }
                },
              ),

              Text(
                ' | Tình trạng: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                product.status == 1 ? 'Còn hàng' : 'Hết hàng',
                style: TextStyle(
                  fontSize: 14,
                  color: product.status == 1 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          Text(
            '${product.cost?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            '${product.priceSale?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class SizeSelector extends StatelessWidget {
  final List<ProductSizeModel> sizes;
  final String? selectedSize;
  final Function(String) onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn Size:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                sizes.map((size) {
                  bool isAvailable = size.status == 1;
                  bool isSelected = selectedSize == size.size;

                  return GestureDetector(
                    onTap:
                        isAvailable ? () => onSizeSelected(size.size!) : null,
                    child: Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isAvailable
                                ? (isSelected ? Colors.orange : Colors.white)
                                : Colors.grey[300],
                        border: Border.all(
                          color:
                              isAvailable
                                  ? (isSelected ? Colors.orange : Colors.grey)
                                  : Colors.grey[400]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        size.size ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              isAvailable
                                  ? (isSelected ? Colors.white : Colors.black)
                                  : Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class ProductInfo extends StatelessWidget {
  final ProductModel product;
  final int productType;
  final RacketInfoModel? racketInfo;
  final ShoeInfoModel? shoeInfo;
  final ClothingInfoModel? clothingInfo;
  final BagAccessoryModel? bagAccessoryInfo;

  const ProductInfo({
    super.key,
    required this.product,
    required this.productType,
    this.racketInfo,
    this.shoeInfo,
    this.clothingInfo,
    this.bagAccessoryInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin sản phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 12),

          if (productType == 1) _buildShoeInfo(),
          if (productType == 2) _buildRacketInfo(),
          if (productType == 3) _buildClothingInfo(),
          if (productType == 4) _buildBagAccessoryInfo(),
        ],
      ),
    );
  }

  Widget _buildShoeInfo() {
    if (shoeInfo == null) {
      return Text('Không có thông tin chi tiết cho sản phẩm này');
    }

    return Column(
      children: [
        _buildInfoRow('Size', shoeInfo!.size ?? 'N/A'),
        _buildInfoRow('Thân giày/ Upper', shoeInfo!.thanGiay ?? 'N/A'),
        _buildInfoRow('Đế giữa/ Midsole', shoeInfo!.deGiua ?? 'N/A'),
        _buildInfoRow('Đế ngoài/ Outsole', shoeInfo!.deNgoai ?? 'N/A'),
        _buildInfoRow(
          'Bên trong/ Inner materials',
          shoeInfo!.benTrong ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildRacketInfo() {
    if (racketInfo == null) {
      return Text('Không có thông tin chi tiết cho sản phẩm này');
    }

    return Column(
      children: [
        _buildInfoRow('Chất liệu', racketInfo!.chatLieu ?? 'N/A'),
        _buildInfoRow('Trọng lượng', racketInfo!.trongLuong ?? 'N/A'),
        _buildInfoRow('Chu vi cán vợt', racketInfo!.chuViCan ?? 'N/A'),
        _buildInfoRow('Chiều dài vợt', racketInfo!.chieuDaiVot ?? 'N/A'),
        _buildInfoRow('Chiều dài cán vợt', racketInfo!.chieuDaiCan ?? 'N/A'),
      ],
    );
  }

  Widget _buildClothingInfo() {
    if (clothingInfo == null) {
      return Text('Không có thông tin chi tiết cho sản phẩm này');
    }

    return Column(
      children: [
        _buildInfoRow('Size', clothingInfo!.size ?? 'N/A'),
        _buildInfoRow('Chất liệu', clothingInfo!.chatLieu ?? 'N/A'),
        _buildInfoRow('Thiết kế', clothingInfo!.thietKe ?? 'N/A'),
        _buildInfoRow('Kiểu loại', clothingInfo!.kieuLoai ?? 'N/A'),
        _buildInfoRow('Tính năng', clothingInfo!.tinhNang ?? 'N/A'),
      ],
    );
  }

  Widget _buildBagAccessoryInfo() {
    if (bagAccessoryInfo == null) {
      return Text('Không có thông tin chi tiết cho sản phẩm này');
    }

    return Column(
      children: [
        _buildInfoRow('Thương hiệu', bagAccessoryInfo!.thuongHieu ?? 'N/A'),
        _buildInfoRow('Màu sắc', bagAccessoryInfo!.mauSac ?? 'N/A'),
        _buildInfoRow('Kích thước', bagAccessoryInfo!.kichThuoc ?? 'N/A'),
        _buildInfoRow('Chất liệu', bagAccessoryInfo!.chatLieu ?? 'N/A'),
        _buildInfoRow('Tính năng', bagAccessoryInfo!.tinhNang ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendedProducts extends ConsumerStatefulWidget {
  final int currentProductId;
  final List<ProductModel> allProducts;

  const RecommendedProducts({
    super.key,
    required this.currentProductId,
    required this.allProducts,
  });

  @override
  ConsumerState<RecommendedProducts> createState() =>
      _RecommendedProductsState();
}

class _RecommendedProductsState extends ConsumerState<RecommendedProducts> {
  List<ProductModel> _displayedRecommendedProducts = [];

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    final eligibleProducts =
        widget.allProducts
            .where((product) => product.id != widget.currentProductId)
            .toList();

    eligibleProducts.shuffle(Random());

    setState(() {
      _displayedRecommendedProducts = eligibleProducts.take(6).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedRecommendedProducts.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gợi ý cho bạn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.orange),
                onPressed: _refreshProducts,
              ),
            ],
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.56,
            ),
            itemCount: _displayedRecommendedProducts.length,
            itemBuilder: (context, index) {
              return itemGridView(_displayedRecommendedProducts[index], ref);
            },
          ),
        ],
      ),
    );
  }
}
