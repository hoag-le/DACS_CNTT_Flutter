import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'productmodel.dart';
import 'cartitemmodel.dart';
import '../../services/firestore_service.dart';

class ProductsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {
    'favorite': <ProductModel>[],
    'cart': <CartItemModel>[],
  };

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void addToFavorite(ProductModel mo) {
    final favorites = List<ProductModel>.from(state['favorite']);
    if (!favorites.any((p) => p.id == mo.id)) {
      state = {
        ...state,
        'favorite': [...favorites, mo],
      };
    }
  }

  void removeFromFavorite(int index) {
    final favorites = List<ProductModel>.from(state['favorite']);
    if (index >= 0 && index < favorites.length) {
      favorites.removeAt(index);
      state = {
        ...state,
        'favorite': favorites,
      };
    }
  }

  void removeFromFavoriteByProduct(ProductModel product) {
    final favorites = List<ProductModel>.from(state['favorite']);
    favorites.removeWhere((p) => p.id == product.id);
    state = {
      ...state,
      'favorite': favorites,
    };
  }

  bool isInFavorites(dynamic productId) {
    final favorites = List<ProductModel>.from(state['favorite']);
    return favorites.any((p) => p.id == productId);
  }

  int get favoritesCount {
    final favorites = List<ProductModel>.from(state['favorite']);
    return favorites.length;
  }

  void addToCart(ProductModel product, int quantity, String? size) {
    final cart = List<CartItemModel>.from(state['cart']);

    final existingIndex = cart.indexWhere((item) =>
      item.product.id == product.id && item.size == size
    );

    if (existingIndex >= 0) {
      cart[existingIndex] = cart[existingIndex].copyWith(
        quantity: cart[existingIndex].quantity + quantity
      );
    } else {
      cart.add(CartItemModel(
        product: product,
        quantity: quantity,
        size: size,
      ));
    }

    state = {
      ...state,
      'cart': cart,
    };

    _syncCart(cart);
  }

  void removeFromCart(int index) {
    final cart = List<CartItemModel>.from(state['cart']);
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      state = {
        ...state,
        'cart': cart,
      };
      _syncCart(cart);
    }
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    final cart = List<CartItemModel>.from(state['cart']);
    if (index >= 0 && index < cart.length && newQuantity > 0) {
      cart[index] = cart[index].copyWith(quantity: newQuantity);
      state = {
        ...state,
        'cart': cart,
      };
      _syncCart(cart);
    }
  }

  void clearCart() {
    state = {
      ...state,
      'cart': <CartItemModel>[],
    };
    if (_uid != null) {
      FirestoreService.clearCart(_uid!);
    }
  }

  void setCart(List<CartItemModel> items) {
    state = {
      ...state,
      'cart': items,
    };
  }

  List<CartItemModel> get cartItems {
    return List<CartItemModel>.from(state['cart']);
  }

  int get cartItemsCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get cartTotal {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  bool get isCartEmpty => cartItems.isEmpty;

  void _syncCart(List<CartItemModel> cart) {
    final uid = _uid;
    if (uid != null) {
      FirestoreService.saveCart(uid, cart);
    }
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, Map<String, dynamic>>(
    () => ProductsNotifier());

final cartItemsProvider = Provider<List<CartItemModel>>((ref) {
  return List<CartItemModel>.from(ref.watch(productsProvider)['cart']);
});