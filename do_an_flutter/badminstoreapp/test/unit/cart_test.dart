import 'package:flutter_test/flutter_test.dart';
import 'package:badminstoreapp/data/model/cartitemmodel.dart';
import 'package:badminstoreapp/data/model/productmodel.dart';
import 'package:badminstoreapp/data/model/products_state.dart';

void main() {
  group('CartItemModel Tests', () {
    test('calculate totalPrice correctly', () {
      final product = ProductModel(
        id: 1,
        productName: 'Test Product',
        priceSale: 50000,
      );

      final cartItem = CartItemModel(
        product: product,
        quantity: 2,
      );

      expect(cartItem.totalPrice, 100000);
    });

    test('totalPrice is 0 when priceSale is null', () {
      final product = ProductModel(
        id: 1,
        productName: 'Test Product',
        priceSale: null,
      );

      final cartItem = CartItemModel(
        product: product,
        quantity: 2,
      );

      expect(cartItem.totalPrice, 0);
    });

    test('copyWith updates fields correctly', () {
      final product = ProductModel(id: 1, priceSale: 50000);
      final item = CartItemModel(product: product, quantity: 1, size: 'M');

      final newItem = item.copyWith(quantity: 3, size: 'L');

      expect(newItem.quantity, 3);
      expect(newItem.size, 'L');
      expect(newItem.product.id, 1);
    });

    test('toJson and fromJson work correctly', () {
      final product = ProductModel(id: 1, productName: 'Test', priceSale: 50000);
      final item = CartItemModel(product: product, quantity: 2, size: 'XL');

      final json = item.toJson();
      final newItem = CartItemModel.fromJson(json);

      expect(newItem.quantity, 2);
      expect(newItem.size, 'XL');
      expect(newItem.product.id, 1);
      expect(newItem.product.productName, 'Test');
    });
  });

  group('ProductsState Tests', () {
    test('initial state is empty', () {
      final state = ProductsState();
      
      expect(state.favorites, isEmpty);
      expect(state.cartItems, isEmpty);
    });

    test('copyWith updates fields correctly', () {
      final state = ProductsState();
      
      final product = ProductModel(id: 1, productName: 'Test');
      final cartItem = CartItemModel(product: product, quantity: 1);

      final newState = state.copyWith(
        favorites: [product],
        cartItems: [cartItem],
      );

      expect(newState.favorites.length, 1);
      expect(newState.favorites.first.id, 1);
      expect(newState.cartItems.length, 1);
      expect(newState.cartItems.first.quantity, 1);
    });
  });
}
