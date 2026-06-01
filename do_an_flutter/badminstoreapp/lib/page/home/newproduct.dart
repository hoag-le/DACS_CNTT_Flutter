import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_providers.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';

class NewProductWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProviderData);

    return productsAsyncValue.when(
      data: (allProducts) {
        List<ProductModel> newProducts =
            allProducts
                .where(
                  (product) =>
                      product.id != null &&
                      product.id! >= 1 &&
                      product.id! <= 12,
                )
                .toList();

        newProducts.sort((a, b) => a.id!.compareTo(b.id!));

        if (newProducts.isEmpty) {
          return Container(
            height: 200,
            child: Center(child: Text('Không có sản phẩm mới')),
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
      loading:
          () => Container(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Container(
            height: 200,
            child: Center(child: Text('Lỗi tải dữ liệu')),
          ),
    );
  }
}
