import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'productmodel.dart';
import 'cartitemmodel.dart';
import 'products_state.dart';
import '../../services/firestore_service.dart';

class ProductsNotifier extends Notifier<ProductsState> {
  @override
  ProductsState build() => const ProductsState();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void addToFavorite(ProductModel mo) {
    final favorites = List<ProductModel>.from(state.favorites);
    if (!favorites.any((p) => p.id == mo.id)) {
      state = state.copyWith(favorites: [...favorites, mo]);
    }
  }

  void removeFromFavorite(int index) {
    final favorites = List<ProductModel>.from(state.favorites);
    if (index >= 0 && index < favorites.length) {
      favorites.removeAt(index);
      state = state.copyWith(favorites: favorites);
    }
  }

  void removeFromFavoriteByProduct(ProductModel product) {
    final favorites = List<ProductModel>.from(state.favorites);
    favorites.removeWhere((p) => p.id == product.id);
    state = state.copyWith(favorites: favorites);
  }

  bool isInFavorites(dynamic productId) {
    return state.favorites.any((p) => p.id == productId);
  }

  int get favoritesCount {
    return state.favorites.length;
  }

  void addToCart(ProductModel product, int quantity, String? size) {
    final cart = List<CartItemModel>.from(state.cartItems);

    final existingIndex = cart.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );

    if (existingIndex >= 0) {
      cart[existingIndex] = cart[existingIndex].copyWith(
        quantity: cart[existingIndex].quantity + quantity,
      );
    } else {
      cart.add(CartItemModel(product: product, quantity: quantity, size: size));
    }

    state = state.copyWith(cartItems: cart);

    _syncCart(cart);
  }

  void removeFromCart(int index) {
    final cart = List<CartItemModel>.from(state.cartItems);
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      state = state.copyWith(cartItems: cart);
      _syncCart(cart);
    }
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    final cart = List<CartItemModel>.from(state.cartItems);
    if (index >= 0 && index < cart.length && newQuantity > 0) {
      cart[index] = cart[index].copyWith(quantity: newQuantity);
      state = state.copyWith(cartItems: cart);
      _syncCart(cart);
    }
  }

  void clearCart() {
    state = state.copyWith(cartItems: const []);

    if (_uid != null) {
      FirestoreService.clearCart(_uid!);
    }
  }

  void setCart(List<CartItemModel> items) {
    state = state.copyWith(cartItems: items);
  }

  List<CartItemModel> get cartItems {
    return state.cartItems;
  }

  int get cartItemsCount {
    return state.cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get cartTotal {
    return state.cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  bool get isCartEmpty => state.cartItems.isEmpty;

  bool _cartLoaded = false;

  void _syncCart(List<CartItemModel> cart) {
    final uid = _uid;
    if (uid != null) {
      FirestoreService.saveCart(uid, cart);
    }
  }

  Future<void> loadCartFromFirestore({bool force = false}) async {
    final uid = _uid;
    if (uid == null) return;
    if (_cartLoaded && !force) return;

    try {
      final rawItems = await FirestoreService.getCart(uid);
      final cartItems =
          rawItems.map((data) {
            final product = ProductModel(
              id: data['productId'],
              code: data['productCode'] as String?,
              productName: data['productName'] as String?,
              categoryId: (data['categoryId'] as num?)?.toInt(),
              brandId: (data['brandId'] as num?)?.toInt(),
              cost: (data['cost'] as num?)?.toInt(),
              priceSale: (data['priceSale'] as num?)?.toInt(),
              image: data['image'] as String?,
              status: 1,
              visible: 1,
            );
            return CartItemModel(
              product: product,
              quantity: (data['quantity'] as num?)?.toInt() ?? 1,
              size:
                  (data['size'] as String?)?.isEmpty ?? true
                      ? null
                      : data['size'] as String?,
            );
          }).toList();

      state = state.copyWith(cartItems: cartItems);
      _cartLoaded = true;
    } catch (e, st) {
      debugPrint('[ProductsNotifier.loadCartFromFirestore] Error: $e');
      debugPrintStack(
        stackTrace: st,
        label: 'ProductsNotifier.loadCartFromFirestore',
      );
    }
  }

  void resetCartLoadedFlag() => _cartLoaded = false;
}

final productsProvider = NotifierProvider<ProductsNotifier, ProductsState>(
  () => ProductsNotifier(),
);

final cartItemsProvider = Provider<List<CartItemModel>>((ref) {
  return ref.watch(productsProvider).cartItems;
});
