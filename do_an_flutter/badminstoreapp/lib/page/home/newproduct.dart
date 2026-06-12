import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_providers.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';
import '../../widgets/app_state_widgets.dart';

class NewProductWidget extends ConsumerWidget {
  const NewProductWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProviderData);

    return productsAsyncValue.when(
      data: (allProducts) {
        List<ProductModel> newProducts = allProducts
            .where((product) => product.id != null && product.id! >= 1 && product.id! <= 12)
            .toList();

        newProducts.sort((a, b) => a.id!.compareTo(b.id!));

        if (newProducts.isEmpty) {
          return const AppEmptyWidget(
            message: 'Không có sản phẩm mới',
            icon: Icons.new_releases_outlined,
            height: 200,
          );
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sản phẩm mới',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),

              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.62,
                ),
                itemCount: newProducts.length,
                itemBuilder: (context, index) {
                  return itemGridView(newProducts[index], ref);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const AppLoadingWidget(height: 200),
      error: (error, stack) => const AppErrorWidget(height: 200),
    );
  }
}
