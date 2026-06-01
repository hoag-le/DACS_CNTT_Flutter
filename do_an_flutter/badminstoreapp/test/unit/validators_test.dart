import 'package:flutter_test/flutter_test.dart';
import 'package:badminstoreapp/utils/validators.dart';

void main() {
  group('Login Validation Tests', () {
    test('validateLoginEmail returns error on empty string', () {
      expect(Validators.validateLoginEmail(''), 'Email không được để trống');
      expect(Validators.validateLoginEmail('   '), 'Email không được để trống');
    });

    test('validateLoginEmail returns null on valid string', () {
      expect(Validators.validateLoginEmail('test@test.com'), isNull);
    });

    test('validateLoginPassword returns error on empty string', () {
      expect(Validators.validateLoginPassword(''), 'Mật khẩu không được để trống');
    });

    test('validateLoginPassword returns null on valid string', () {
      expect(Validators.validateLoginPassword('password123'), isNull);
    });
  });

  group('Register Validation Tests', () {
    test('returns error when required fields are empty', () {
      final error = Validators.validateRegisterFields(
        email: '',
        username: 'user',
        password: 'password',
        confirmPassword: 'password',
        agreeToTruth: true,
        agreeToPolicy: true,
      );
      expect(error, 'Vui lòng điền đầy đủ thông tin bắt buộc');
    });

    test('returns error when email is invalid', () {
      final error = Validators.validateRegisterFields(
        email: 'invalid_email',
        username: 'user',
        password: 'password',
        confirmPassword: 'password',
        agreeToTruth: true,
        agreeToPolicy: true,
      );
      expect(error, 'Địa chỉ email không hợp lệ');
    });

    test('returns error when password is too short', () {
      final error = Validators.validateRegisterFields(
        email: 'test@test.com',
        username: 'user',
        password: '12345',
        confirmPassword: '12345',
        agreeToTruth: true,
        agreeToPolicy: true,
      );
      expect(error, 'Mật khẩu phải có ít nhất 6 ký tự');
    });

    test('returns error when passwords do not match', () {
      final error = Validators.validateRegisterFields(
        email: 'test@test.com',
        username: 'user',
        password: 'password123',
        confirmPassword: 'password456',
        agreeToTruth: true,
        agreeToPolicy: true,
      );
      expect(error, 'Mật khẩu xác nhận không khớp');
    });

    test('returns error when terms are not agreed', () {
      final error1 = Validators.validateRegisterFields(
        email: 'test@test.com',
        username: 'user',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTruth: false,
        agreeToPolicy: true,
      );
      expect(error1, 'Vui lòng đồng ý với các điều khoản');

      final error2 = Validators.validateRegisterFields(
        email: 'test@test.com',
        username: 'user',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTruth: true,
        agreeToPolicy: false,
      );
      expect(error2, 'Vui lòng đồng ý với các điều khoản');
    });

    test('returns null when all fields are valid', () {
      final error = Validators.validateRegisterFields(
        email: 'test@test.com',
        username: 'user',
        password: 'password123',
        confirmPassword: 'password123',
        agreeToTruth: true,
        agreeToPolicy: true,
      );
      expect(error, isNull);
    });
  });
}
