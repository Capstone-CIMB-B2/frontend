import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart'; 
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_controller.text.length < 5) {
      _focusNode.requestFocus(); 
      return;
    }

    // Navigasi ke home logged in, hapus semua history
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OctoHomeScreenLoggedIn()),
      (route) => false,
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

              _buildUserIdForm(),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF7B0000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
        ),
        Column(
            children: [
              const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
              Text('Butuh', style: TextStyle(color: Color(0xFF7B0000), fontSize: 9, fontWeight: FontWeight.bold)),
              Text('bantuan?', style: TextStyle(color: Color(0xFF7B0000), fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserIdForm() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      onSubmitted: (_) => _handleLogin(), // ← bisa login pakai keyboard "done"
      decoration: InputDecoration(
        hintText: 'Masukkan user ID',
        helperText: (_isTyping && _controller.text.length < 5)
            ? 'User ID harus berisi minimal 5 karakter'
            : ' ',
        helperStyle: const TextStyle(color: Colors.white70, fontSize: 10),
        hintStyle: const TextStyle(color: Colors.white),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () => _controller.clear(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.cancel, color: Colors.white.withOpacity(0.8), size: 18),
                ),
              ),
            Text(
              'Lupa user ID?',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
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