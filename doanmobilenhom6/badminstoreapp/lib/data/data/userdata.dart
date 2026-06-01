import 'package:firebase_auth/firebase_auth.dart';
import '../model/usermodel.dart';
import '../../services/auth_service.dart';

class UserData {
  Future<UserModel?> getCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return await AuthService.getUserProfile(uid);
  }

  Future<List<UserModel>> loadData() async {
    return [];
  }
}