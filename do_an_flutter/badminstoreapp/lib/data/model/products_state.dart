import 'productmodel.dart';
import 'cartitemmodel.dart';

class ProductsState {
  final List<ProductModel> favorites;
  final List<CartItemModel> cartItems;

  const ProductsState({this.favorites = const [], this.cartItems = const []});

  ProductsState copyWith({
    List<ProductModel>? favorites,
    List<CartItemModel>? cartItems,
  }) {
    return ProductsState(
      favorites: favorites ?? this.favorites,
      cartItems: cartItems ?? this.cartItems,
    );
  }
}
