class Validators {
  static String? validateLoginEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Email không được để trống';
    }
    return null;
  }

  static String? validateLoginPassword(String password) {
    if (password.trim().isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    return null;
  }

  static String? validateRegisterFields({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required bool agreeToTruth,
    required bool agreeToPolicy,
  }) {
    if (email.trim().isEmpty || username.trim().isEmpty || password.trim().isEmpty) {
      return 'Vui lòng điền đầy đủ thông tin bắt buộc';
    }

    if (!email.contains('@')) {
      return 'Địa chỉ email không hợp lệ';
    }

    if (password.trim().length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    if (password.trim() != confirmPassword.trim()) {
      return 'Mật khẩu xác nhận không khớp';
    }

    if (!agreeToTruth || !agreeToPolicy) {
      return 'Vui lòng đồng ý với các điều khoản';
    }

    return null;
  }
}
