import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usermodel.dart';
import '../../services/auth_service.dart';

final firebaseUserProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

final userProvider = StateProvider<UserModel?>((ref) => null);

final authStateProvider = Provider<AsyncValue<User?>>((ref) {
  return ref.watch(firebaseUserProvider);
});

final currentUserProfileProvider = FutureProvider<UserModel?>((ref) async {
  final userAsync = ref.watch(firebaseUserProvider);
  return userAsync.when(
    data: (firebaseUser) async {
      if (firebaseUser == null) return null;
      return AuthService.getUserProfile(firebaseUser.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
