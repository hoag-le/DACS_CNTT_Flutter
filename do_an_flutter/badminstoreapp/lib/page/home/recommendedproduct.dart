import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/home_providers.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';
import '../../widgets/app_state_widgets.dart';

class RecommendedProductWidget extends ConsumerStatefulWidget {
  @override
  _RecommendedProductWidgetState createState() => _RecommendedProductWidgetState();
}

class _RecommendedProductWidgetState extends ConsumerState<RecommendedProductWidget> {
  PageController _pageController = PageController();
  Timer? _timer;
  int currentPage = 0;
  bool _timerStarted = false;
  List<ProductModel>? _randomProducts;

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
      children: products
          .map((product) => Expanded(child: itemGridView(product, ref)))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProviderData);

    return productsAsyncValue.when(
      data: (allProducts) {
        if (_randomProducts == null) {
          List<ProductModel> filteredProducts = allProducts
              .where((product) => product.id != null && product.id! >= 1 && product.id! <= 80)
              .toList();

          Random random = Random();
          filteredProducts.shuffle(random);
          _randomProducts = filteredProducts.take(8).toList();
        }

        if (_randomProducts!.isEmpty) {
          return const AppEmptyWidget(
            message: 'Không có sản phẩm được đề xuất',
            icon: Icons.recommend_outlined,
            height: 300,
          );
        }

        startAutoScroll(_randomProducts!.length);

        List<List<ProductModel>> productPairs = [];
        for (int i = 0; i < _randomProducts!.length; i += 2) {
          List<ProductModel> pair = [_randomProducts![i]];
          if (i + 1 < _randomProducts!.length) {
            pair.add(_randomProducts![i + 1]);
          }
          productPairs.add(pair);
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sản phẩm đề xuất',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _randomProducts = null;
                        currentPage = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.refresh, color: Colors.orange, size: 20),
                    ),
                  ),
                ],
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
                        color: currentPage == index ? Colors.orange : Colors.grey[400],
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
      loading: () => const AppLoadingWidget(height: 300),
      error: (error, stack) => const AppErrorWidget(height: 300),
    );
  }
}
