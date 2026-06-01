import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminstoreapp/page/cart/productcart.dart';
import 'package:badminstoreapp/widgets/app_state_widgets.dart';
import 'package:badminstoreapp/data/model/product_viewmodel.dart';
import 'package:badminstoreapp/data/model/products_state.dart';

// Mock notifier for empty cart
class MockEmptyProductsNotifier extends ProductsNotifier {
  @override
  ProductsState build() => const ProductsState(cartItems: []);
}

void main() {
  testWidgets('ProductCart shows empty state when cart is empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsProvider.overrideWith(() => MockEmptyProductsNotifier()),
        ],
        child: const MaterialApp(
          home: ProductCart(),
        ),
      ),
    );

    // Should find the empty widget
    expect(find.byType(AppEmptyWidget), findsOneWidget);
    expect(find.text('Chưa thấy sản phẩm trong giỏ hàng của bạn'), findsOneWidget);
    
    // Should NOT find cart items or checkout bottom bar
    expect(find.text('Thanh toán'), findsNothing);
  });
}
