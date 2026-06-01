import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/home_providers.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';

class BestSellerWidget extends ConsumerStatefulWidget {
  @override
  _BestSellerWidgetState createState() => _BestSellerWidgetState();
}

class _BestSellerWidgetState extends ConsumerState<BestSellerWidget> {
  PageController _pageController = PageController();
  Timer? _timer;
  int currentPage = 0;
  bool _timerStarted = false;

  void startAutoScroll(int length) {
    if (length <= 2 || _timerStarted) return;
    _timerStarted = true;

    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int maxPages = (length / 2).ceil();
        setState(() {
          currentPage = (currentPage + 1) % maxPages;
        });

        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildProductPair(List<ProductModel> products) {
    return Row(
      children:
          products
              .map((product) => Expanded(child: itemGridView(product, ref)))
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProviderData);

    return productsAsyncValue.when(
      data: (allProducts) {
        List<ProductModel> bestSellerProducts =
            allProducts
                .where(
                  (product) =>
                      product.id != null &&
                      product.id! >= 1 &&
                      product.id! <= 8,
                )
                .toList();

        bestSellerProducts.sort((a, b) => a.id!.compareTo(b.id!));

        if (bestSellerProducts.isEmpty) {
          return Container(
            height: 300,
            child: Center(child: Text('Không có sản phẩm bán chạy')),
          );
        }

        startAutoScroll(bestSellerProducts.length);

        List<List<ProductModel>> productPairs = [];
        for (int i = 0; i < bestSellerProducts.length; i += 2) {
          List<ProductModel> pair = [bestSellerProducts[i]];
          if (i + 1 < bestSellerProducts.length) {
            pair.add(bestSellerProducts[i + 1]);
          }
          productPairs.add(pair);
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sản phẩm bán chạy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              Container(
                height: 300,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: productPairs.length,
                  itemBuilder: (context, index) {
                    return buildProductPair(productPairs[index]);
                  },
                ),
              ),

              SizedBox(height: 12),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    productPairs.length,
                    (index) => Container(
                      width: currentPage == index ? 12 : 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color:
                            currentPage == index
                                ? Colors.orange
                                : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => Container(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Container(
            height: 300,
            child: Center(child: Text('Lỗi tải dữ liệu')),
          ),
    );
  }
}
