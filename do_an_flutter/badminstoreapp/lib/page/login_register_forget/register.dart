import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../data/model/user_provider.dart';
import '../../utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTruth = false;
  bool _agreeToPolicy = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final fullname = _fullnameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final validationError = Validators.validateRegisterFields(
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      agreeToTruth: _agreeToTruth,
      agreeToPolicy: _agreeToPolicy,
    );

    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
        _isLoading = false;
      });
      return;
    }

    try {
      final userModel = await AuthService.register(
        email: email,
        password: password,
        username: username,
        fullname: fullname.isNotEmpty ? fullname : null,
        phonenumber: phone.isNotEmpty ? phone : null,
      );

      if (userModel == null) {
        setState(() {
          _errorMessage = 'Đăng ký thất bại, vui lòng thử lại';
          _isLoading = false;
        });
        return;
      }

      ref.read(userProvider.notifier).state = userModel;
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng ký thành công! Chào mừng ${userModel.fullname ?? userModel.username}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        context.go('/main');
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB382), Color(0xFFFF8C42)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF8B4513),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/shopname.png',
                  width: 200,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Đăng ký tài khoản',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
                const SizedBox(height: 24),

                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email *',
                  icon: Icons.email_outlined,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _usernameController,
                  hintText: 'Tên đăng nhập *',
                  icon: Icons.person_outline,
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _fullnameController,
                  hintText: 'Họ và tên',
                  icon: Icons.badge_outlined,
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  hintText: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  obscureText: false,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Mật khẩu * (ít nhất 6 ký tự)',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  isPassword: true,
                  onSuffixTap:
                      () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Nhập lại mật khẩu *',
                  icon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible,
                  isPassword: true,
                  onSuffixTap:
                      () => setState(
                        () =>
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                      ),
                ),
                const SizedBox(height: 16),

                CheckboxListTile(
                  title: const Text(
                    'Thông tin trên đúng với sự thật và tôi sẽ chịu trách nhiệm',
                    style: TextStyle(color: Color(0xFF8B4513), fontSize: 14),
                  ),
                  value: _agreeToTruth,
                  activeColor: const Color(0xFFFF8C42),
                  onChanged:
                      (bool? value) =>
                          setState(() => _agreeToTruth = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                CheckboxListTile(
                  title: const Text(
                    'Tôi đồng ý với chính sách bảo mật và điều khoản app',
                    style: TextStyle(color: Color(0xFF8B4513), fontSize: 14),
                  ),
                  value: _agreeToPolicy,
                  activeColor: const Color(0xFFFF8C42),
                  onChanged:
                      (bool? value) =>
                          setState(() => _agreeToPolicy = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          _isLoading
                              ? [Colors.grey[400]!, Colors.grey[500]!]
                              : [
                                const Color(0xFFFF8C42),
                                const Color(0xFFFF6B1A),
                              ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Đăng ký',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đã có tài khoản?  ',
                      style: TextStyle(color: Color(0xFF8B4513), fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B4513),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    bool isPassword = false,
    VoidCallback? onSuffixTap,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: !_isLoading,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFF8B4513), fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: const Color(0xFF8B4513).withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, color: const Color(0xFF8B4513)),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF8B4513),
                    ),
                    onPressed: onSuffixTap,
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
