import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isUsernameTyping = false;
  bool _isPasswordTyping = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _usernameFocusNode.addListener(() {
      setState(() => _isUsernameTyping = _usernameFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordTyping = _passwordFocusNode.hasFocus);
    });

    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validasi username
    if (_usernameController.text.length < 5) {
      _usernameFocusNode.requestFocus();
      return;
    }
    // Validasi password
    if (_passwordController.text.length < 6) {
      _passwordFocusNode.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OctoHomeScreenLoggedIn()),
          (route) => false,
        );
      } else {
        _showErrorSnackbar('Username atau password salah');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Gagal terhubung ke server. Periksa koneksi Anda.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4A0000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B0000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),

              const SizedBox(height: 60),

              _buildUsernameField(),

              const SizedBox(height: 24),

              _buildPasswordField(),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF7B0000),
                  disabledBackgroundColor: Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF7B0000),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  'Saya punya rekening tapi belum punya User ID',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Daftar Aplikasi OCTO',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  'Saya belum punya rekening',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Center(
                  child: Text(
                    'Buka rekening sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: SvgPicture.asset(
                  'assets/octo/octo-logo.svg',
                  width: 80,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        Column(
          children: [
            const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(width: 50, height: 2, color: Colors.white),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF39C12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Butuh',
                style: TextStyle(
                  color: Color(0xFF7B0000),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'bantuan?',
                style: TextStyle(
                  color: Color(0xFF7B0000),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      focusNode: _usernameFocusNode,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
      decoration: InputDecoration(
        hintText: 'Masukkan username',
        helperText: (_isUsernameTyping &&
                _usernameController.text.isNotEmpty &&
                _usernameController.text.length < 5)
            ? 'Username harus berisi minimal 5 karakter'
            : ' ',
        helperStyle: const TextStyle(color: Colors.white70, fontSize: 10),
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: 'Username',
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_usernameController.text.isNotEmpty)
              GestureDetector(
                onTap: () => _usernameController.clear(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.cancel,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                ),
              ),
            Text(
              'Lupa username?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        hintText: 'Masukkan password',
        helperText: (_isPasswordTyping &&
                _passwordController.text.isNotEmpty &&
                _passwordController.text.length < 6)
            ? 'Password harus berisi minimal 6 karakter'
            : ' ',
        helperStyle: const TextStyle(color: Colors.white70, fontSize: 10),
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ),
            Text(
              'Lupa password?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}