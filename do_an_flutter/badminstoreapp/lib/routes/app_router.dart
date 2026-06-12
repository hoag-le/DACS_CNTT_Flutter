import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/model/ordermodel.dart';
import '../data/model/usermodel.dart';

// Import all screens
import '../page/start.dart';
import '../page/intro.dart';
import '../page/login_register_forget/login.dart';
import '../page/login_register_forget/register.dart';
import '../page/login_register_forget/forget.dart';
import '../page/mainpage.dart';
import '../page/detail/maindetail.dart';
import '../page/cart/productcart.dart';
import '../page/category/maincategory.dart';
import '../page/search/search.dart';
import '../page/search/searchresults.dart';
import '../page/shipping/shippingaddress.dart';
import '../page/shipping/payment.dart';
import '../page/shipping/orderconfirm.dart';
import '../page/shipping/thank.dart';
import '../page/personal/mainpersonal.dart';
import '../page/personal/setting.dart';
import '../page/personal/changepassword.dart';
import '../page/personal/about.dart';
import '../page/personal/support.dart';
import '../page/order/mainorder.dart';
import '../page/order/orderdetail.dart';

const _publicRoutes = {
  '/',
  '/intro',
  '/login',
  '/register',
  '/forget',
};

const _publicPrefixes = [
  '/detail/',
  '/category/',
  '/search',
  '/search-results',
];

bool _isPublicRoute(String location) {
  if (_publicRoutes.contains(location)) return true;
  for (final prefix in _publicPrefixes) {
    if (location.startsWith(prefix)) return true;
  }
  if (location == '/search' || location == '/search-results') return true;
  return false;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final location = state.matchedLocation;

    if (_isPublicRoute(location)) {
      if (loggedIn &&
          (location == '/login' ||
              location == '/register' ||
              location == '/forget')) {
        return '/main';
      }
      return null;
    }

    if (!loggedIn) return '/login';

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const StartScreen(),
    ),
    GoRoute(
      path: '/intro',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: IntroScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forget',
      builder: (context, state) => const ForgetPasswordScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        return MainDetail(productId: int.parse(idStr));
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const ProductCart(),
    ),
    GoRoute(
      path: '/cart/empty',
      builder: (context, state) => const EmptyCartPage(),
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        return MainCategoryPage(initialCategoryId: int.parse(idStr));
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/search-results',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'] ?? '';
        return SearchResultPage(searchQuery: query);
      },
    ),
    GoRoute(
      path: '/checkout/shipping',
      builder: (context, state) {
        final user = state.extra as UserModel?;
        return ShippingAddressScreen(subtotal: 0.0, user: user);
      },
    ),
    GoRoute(
      path: '/checkout/payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentScreen(
          subtotal: extra?['subtotal'] ?? 0.0,
          user: extra?['user'],
          receiverName: extra?['receiverName'] ?? '',
          receiverPhone: extra?['receiverPhone'] ?? '',
          shippingAddress: extra?['shippingAddress'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/checkout/confirm',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OrderConfirmScreen(
          user: extra?['user'],
          receiverName: extra?['receiverName'] ?? '',
          receiverPhone: extra?['receiverPhone'] ?? '',
          shippingAddress: extra?['shippingAddress'] ?? '',
          isPayment: extra?['paymentMethod'] == 'COD' ? 0 : 1,
        );
      },
    ),
    GoRoute(
      path: '/checkout/thank',
      builder: (context, state) => const ThankYouScreen(),
    ),
    GoRoute(
      path: '/personal',
      builder: (context, state) {
        final user = state.extra as UserModel?;
        return MainPersonalPage(user: user);
      },
    ),
    GoRoute(
      path: '/personal/setting',
      builder: (context, state) => const SettingPage(),
    ),
    GoRoute(
      path: '/personal/about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/personal/support',
      builder: (context, state) => const SupportPage(),
    ),
    GoRoute(
      path: '/personal/change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: '/shipping-address',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final subtotal = extra['subtotal'] as double? ?? 0.0;
        final user = extra['user'] as UserModel?;
        return ShippingAddressScreen(subtotal: subtotal, user: user);
      },
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentScreen(
          subtotal: extra['subtotal'] as double? ?? 0.0,
          user: extra['user'] as UserModel?,
          receiverName: extra['receiverName'] as String? ?? '',
          receiverPhone: extra['receiverPhone'] as String? ?? '',
          shippingAddress: extra['shippingAddress'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/order-confirm',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OrderConfirmScreen(
          user: extra['user'] as UserModel?,
          receiverName: extra['receiverName'] as String? ?? '',
          receiverPhone: extra['receiverPhone'] as String? ?? '',
          shippingAddress: extra['shippingAddress'] as String? ?? '',
          totalAmount: extra['totalAmount'] as int? ?? 0,
          isPayment: extra['isPayment'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/personal/orders',
      builder: (context, state) {
        final user = state.extra as UserModel?;
        return MainOrder(user: user);
      },
    ),
    GoRoute(
      path: '/personal/order-detail',
      builder: (context, state) {
        final orderId = state.extra as String;
        return OrderDetail(orderId: orderId);
      },
    ),
  ],
);
