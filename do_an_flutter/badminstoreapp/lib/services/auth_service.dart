import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/model/usermodel.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  static Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      return await getUserProfile(uid);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  static Future<UserModel?> register({
    required String email,
    required String password,
    required String username,
    String? fullname,
    String? phonenumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final userModel = UserModel(
        uid: uid,
        username: username,
        email: email,
        fullname: fullname,
        phonenumber: phonenumber,
        role: 0,
        status: 1,
        loginType: 'local',
      );

      await _db.collection('users').doc(uid).set(userModel.toJson());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['uid'] = uid;
        return UserModel.fromJson(data);
      }
      final authUser = _auth.currentUser;
      if (authUser != null) {
        final userModel = UserModel(
          uid: uid,
          email: authUser.email,
          username: authUser.displayName ?? authUser.email?.split('@').first,
          fullname: authUser.displayName,
          role: 0,
          status: 1,
          loginType: 'local',
        );
        await _db.collection('users').doc(uid).set(userModel.toJson());
        return userModel;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(uid).update(data);
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw 'Lỗi không xác định: $e';
    }
  }

  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'Người dùng chưa đăng nhập';

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Lỗi không xác định: $e';
    }
  }

  static String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị khóa';
      case 'too-many-requests':
        return 'Quá nhiều lần thử, vui lòng thử lại sau';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại trước khi thay đổi mật khẩu';
      default:
        return e.message ?? 'Có lỗi xảy ra, vui lòng thử lại';
    }
  }
}
