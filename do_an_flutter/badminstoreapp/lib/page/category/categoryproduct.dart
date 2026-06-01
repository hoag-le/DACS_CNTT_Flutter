import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_providers.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';
import '../../widgets/app_state_widgets.dart';

class CategoryProductWidget extends ConsumerWidget {
  final int categoryId;

  const CategoryProductWidget({Key? key, required this.categoryId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProviderData);

    return productsAsyncValue.when(
      data: (allProducts) {
        List<ProductModel> categoryProducts =
            allProducts
                .where((product) => product.categoryId == categoryId)
                .toList();

        if (categoryProducts.isEmpty) {
          return const AppEmptyWidget(
            message: 'Không có sản phẩm nào trong danh mục này',
            icon: Icons.shopping_bag_outlined,
            height: 200,
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sản phẩm nổi bật',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.62,
                ),
                itemCount: categoryProducts.length,
                itemBuilder: (context, index) {
                  return itemGridView(categoryProducts[index], ref);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const AppLoadingWidget(height: 200),
      error: (e, s) => const AppErrorWidget(height: 200),
    );
  }
}
