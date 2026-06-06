import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../services/api_service.dart';
import '../services/auth_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Returning user state
  bool _isSavedUserMode = false;
  String _savedUsername = '';
  String _maskedUsername = '';

  // Carousel state
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  late Timer _carouselTimer;

  final List<String> _banners = [
    'assets/banner/promosi/os-bifast.jpg',
    'assets/banner/promosi/mastercard-rev.jpg',
    'assets/banner/promosi/goalsavers-valas.png',
    'assets/banner/promosi/octoloan-qris.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _checkSavedUser();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _pageController.dispose();
    _carouselTimer.cancel();
    super.dispose();
  }

  Future<void> _checkSavedUser() async {
    final savedUser = await AuthManager.getLastUsername();
    if (savedUser != null && savedUser.isNotEmpty) {
      setState(() {
        _isSavedUserMode = true;
        _savedUsername = savedUser;
        _maskedUsername = _maskUsername(savedUser);
      });
    }
  }

  String _maskUsername(String username) {
    if (username.length <= 3) return username;
    String firstTwo = username.substring(0, 2);
    String lastOne = username.substring(username.length - 1);
    String middle = '*' * (username.length - 3);
    return '$firstTwo$middle$lastOne';
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentBannerIndex + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleChangeAccount() async {
    await AuthManager.clearLastUsername();
    setState(() {
      _isSavedUserMode = false;
      _savedUsername = '';
      _maskedUsername = '';
      _usernameController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocusNode.requestFocus();
    });
  }

  Future<void> _handleLogin() async {
    final username = _isSavedUserMode
        ? _savedUsername
        : _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.length < 5) {
      _showErrorSnackbar('User ID harus berisi minimal 5 karakter');
      if (!_isSavedUserMode) _usernameFocusNode.requestFocus();
      return;
    }

    if (password.length < 6) {
      _showErrorSnackbar('Kata Sandi harus berisi minimal 6 karakter');
      _passwordFocusNode.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.login(username, password);
      if (!mounted) return;

      if (success) {
        await AuthManager.saveLastUsername(username);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OctoHomeScreenLoggedIn()),
          (route) => false,
        );
      } else {
        _showErrorSnackbar('User ID atau Kata Sandi salah');
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
      // Scaffold background sama dengan warna merah gelap
      // agar tidak ada flicker saat scroll
      backgroundColor: const Color(0xFF7B0000),
      body: Stack(
        children: [
          // ── 1. SVG Background (full screen) ─────────────────────────
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/background/bg-auth.svg',
              fit: BoxFit.cover,
            ),
          ),

          // ── 2. Konten utama ──────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 25),

                // ── Header: Logo kiri | Bantuan kanan ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo OCTO + "BY CIMB NIAGA"
                      SvgPicture.asset(
                        'assets/octo/octo-by-cimb.svg',
                        height: 36,
                      ),
                      // Tombol Bantuan (outlined pill)
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.4),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline_rounded,
                                color: Colors.white,
                                size: 17,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Bantuan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ── Carousel Banner ──
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentBannerIndex = index);
                    },
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            _banners[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // ── Carousel Dots ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_banners.length, (index) {
                    final bool isSelected = _currentBannerIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 25),

                // ── White Sheet (scrollable, memanjang hingga bawah) ──
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Tagline ──
                          const Text(
                            'Nikmati kemudahan transaksi kapan saja\nmelalui OCTO Mobile.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.4,
                              fontFamily: 'Calibri',
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Label User ID ──
                          const Text(
                            'User ID',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Calibri',
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── User ID Field / Saved Mode ──
                          _isSavedUserMode
                              ? _buildSavedUserField()
                              : _buildUsernameTextField(),

                          const SizedBox(height: 20),

                          // ── Label Kata Sandi ──
                          const Text(
                            'Kata Sandi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Calibri',
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── Password Field ──
                          _buildPasswordTextField(),

                          const SizedBox(height: 10),

                          // ── Lupa Kata Sandi ──
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Lupa Kata Sandi?',
                                style: TextStyle(
                                  color: Color(0xFFCC0000),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Tombol Masuk ──
                          _buildLoginButton(),

                          const SizedBox(height: 28),

                          // ── Footer Daftar ──
                          Text(
                            'Belum punya rekening atau User ID OCTO Mobile?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                              fontFamily: 'Calibri',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                  color: Color(0xFFCC0000),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget Helpers ───────────────────────────────────────────────────

  Widget _buildSavedUserField() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _maskedUsername,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontFamily: 'Calibri',
            ),
          ),
          GestureDetector(
            onTap: _handleChangeAccount,
            child: const Text(
              'Ganti Akun',
              style: TextStyle(
                color: Color(0xFFCC0000),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Calibri',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameTextField() {
    return TextField(
      controller: _usernameController,
      focusNode: _usernameFocusNode,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontFamily: 'Calibri',
      ),
      decoration: InputDecoration(
        hintText: 'Masukkan User ID',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontFamily: 'Calibri',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCC0000), width: 1.5),
        ),
      ),
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontFamily: 'Calibri',
      ),
      decoration: InputDecoration(
        hintText: 'Masukkan Kata Sandi',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontFamily: 'Calibri',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCC0000), width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade500,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFFD93232), Color(0xFF8B0000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B0000).withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Masuk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Calibri',
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
