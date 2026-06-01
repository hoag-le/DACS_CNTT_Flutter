import 'package:firebase_auth/firebase_auth.dart';
import '../model/usermodel.dart';
import '../../services/auth_service.dart';

/// UserData - tương thích ngược, nay dùng Firebase Auth + Firestore
class UserData {
  /// Lấy UserModel của user hiện tại từ Firestore
  Future<UserModel?> getCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return await AuthService.getUserProfile(uid);
  }

  /// Giữ lại method loadData() nhưng không còn dùng JSON
  Future<List<UserModel>> loadData() async {
    // Không còn đọc từ JSON — authentication do Firebase Auth xử lý
    return [];
  }
}
