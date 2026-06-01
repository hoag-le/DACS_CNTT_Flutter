import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../providers/home_providers.dart';
import '../../data/model/productmodel.dart';
import 'package:go_router/go_router.dart';
import '../product/productbody.dart';
import '../../widgets/app_state_widgets.dart';
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late TextEditingController _searchController;
  List<ProductModel>? _suggestedProducts;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.push('/search-results?query=${query.trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProviderData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: _onSearchSubmitted,
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm tên sản phẩm và nhãn hiệu',
              hintStyle: TextStyle(color: Colors.orange),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: Icon(Icons.search, color: Colors.black),
            ),
          ),
        ),
      ),
      body: productsAsyncValue.when(
        data: (allProducts) {
          if (_suggestedProducts == null) {
            List<ProductModel> productsInRange =
                allProducts
                    .where(
                      (product) =>
                          product.id != null &&
                          product.id! >= 1 &&
                          product.id! <= 80,
                    )
                    .toList();

            if (productsInRange.isNotEmpty) {
              final random = Random();
              final List<ProductModel> shuffledProducts = List.from(
                productsInRange,
              )..shuffle(random);
              _suggestedProducts = shuffledProducts.take(16).toList();
            } else {
              _suggestedProducts = [];
            }
          }

          if (_suggestedProducts!.isEmpty) {
            return const AppEmptyWidget(
              message: 'Không có sản phẩm gợi ý',
              icon: Icons.search_off,
            );
          }

          return SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Text(
                      'Gợi ý sản phẩm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: _suggestedProducts!.length,
                      itemBuilder: (context, index) {
                        return itemGridView(_suggestedProducts![index], ref);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (e, s) => const AppErrorWidget(),
      ),
    );
  }
}
