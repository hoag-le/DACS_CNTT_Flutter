import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usermodel.dart';
import '../../services/auth_service.dart';

// Provider cho Firebase Auth user (raw)
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

// Provider cho UserModel đã đọc từ Firestore
final userProvider = StateProvider<UserModel?>((ref) => null);

// Provider này watch firebaseUserProvider và tự động cập nhật userProvider
final authStateProvider = Provider<AsyncValue<User?>>((ref) {
  return ref.watch(firebaseUserProvider);
});