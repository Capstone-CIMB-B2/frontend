import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../main.dart';

enum Pekerjaan {
  pelajar_mahasiswa("Pelajar / Mahasiswa"),
  fresh_graduate("Fresh Graduate"),
  karyawan_swasta("Karyawan Swasta"),
  pns("PNS"),
  pengusaha("Pengusaha / Wirausaha"),
  profesional("Profesional"),
  freelancer("Freelancer");

  final String label;
  const Pekerjaan(this.label);
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1;
  bool _obscurePassword = true;
  DateTime? _selectedDate;
  Pekerjaan? _selectedPekerjaan;

  // Phase PIN: 1 = input PIN, 2 = konfirmasi PIN
  int _pinPhase = 1;
  bool _pinError = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _provinsiController = TextEditingController();
  final TextEditingController _pendapatanController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();

  bool _isLoading = false;

  bool get _hasValidEmail =>
      RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(_emailController.text);

  bool get _hasValidUsernameLength =>
      _usernameController.text.length >= 5 &&
      _usernameController.text.length <= 20;

  bool get _hasValidPasswordLength =>
      _passwordController.text.length >= 6 &&
      _passwordController.text.length <= 12;

  bool get _hasLetter => RegExp(r'[A-Za-z]').hasMatch(_passwordController.text);

  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordController.text);

  bool get _hasSymbol =>
      RegExp(r'[@$!%*#?&.,_\\-]').hasMatch(_passwordController.text);

  bool get _hasValidNik => _nikController.text.length == 16;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _nikController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _namaController.dispose();
    _nikController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _provinsiController.dispose();
    _tempatLahirController.dispose();
    _pendapatanController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  @override
  Future<List<Map<String, String>>> _getAddressSuggestions(String query) async {
    if (query.length < 3) return [];
    try {
      final url =
          'https://nominatim.openstreetmap.org/search'
          '?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5&countrycodes=id';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'OctoApp/1.0', 'Accept-Language': 'id'},
      );
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as List;
      if (data.isEmpty) return [];
      return data.map((item) {
        final address = item['address'] as Map<String, dynamic>? ?? {};
        return {
          'display': item['display_name'] as String,
          'city':
              (address['city'] ??
                      address['town'] ??
                      address['regency'] ??
                      address['county'] ??
                      '')
                  as String,
          'province': (address['state'] ?? '') as String,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  void _onNumpadTap(String val) {
    final controller = _pinPhase == 1 ? _pinController : _pinConfirmController;

    if (controller.text.length >= 6) return;

    setState(() {
      _pinError = false;
      controller.text += val;
    });

    // Setelah 6 digit
    if (controller.text.length == 6) {
      if (_pinPhase == 1) {
        // Otomatis pindah ke phase 2
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _pinPhase = 2);
        });
      } else {
        // Phase 2: cek kecocokan
        if (_pinController.text != _pinConfirmController.text) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _pinError = true;
                _pinConfirmController.clear();
              });
            }
          });
        }
      }
    }
  }

  void _onNumpadDelete() {
    final controller = _pinPhase == 1 ? _pinController : _pinConfirmController;
    if (controller.text.isNotEmpty) {
      setState(() {
        _pinError = false;
        controller.text = controller.text.substring(
          0,
          controller.text.length - 1,
        );
      });
    }
  }

  Future<void> _nextStep() async {
    if (_currentStep == 1) {
      if (_emailController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        _showSnackBar('Harap lengkapi semua data');
        return;
      }
      if (!_hasValidEmail) {
        _showSnackBar('Format email tidak valid');
        return;
      }
      if (!_hasValidUsernameLength) {
        _showSnackBar('Username harus 5–20 karakter');
        return;
      }
      if (!_hasValidPasswordLength) {
        _showSnackBar('Password harus 6–12 karakter');
        return;
      }
      if (!_hasLetter || !_hasNumber || !_hasSymbol) {
        _showSnackBar('Password harus mengandung huruf, angka, dan simbol');
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_namaController.text.isEmpty ||
          _nikController.text.isEmpty ||
          _tempatLahirController.text.isEmpty ||
          _selectedDate == null ||
          _teleponController.text.isEmpty ||
          _selectedPekerjaan == null ||
          _alamatController.text.isEmpty ||
          _kotaController.text.isEmpty ||
          _provinsiController.text.isEmpty) {
        _showSnackBar('Harap lengkapi semua data diri');
        return;
      }
      if (!_hasValidNik) {
        _showSnackBar('NIK harus 16 digit');
        return;
      }
      setState(() => _currentStep = 3);
    } else {
      // Step 3 - Submit
      if (_pinController.text.length != 6) {
        _showSnackBar('PIN harus 6 digit angka');
        return;
      }
      if (_pinPhase < 2) {
        _showSnackBar('Harap konfirmasi PIN terlebih dahulu');
        return;
      }
      if (_pinController.text != _pinConfirmController.text) {
        _showSnackBar('Konfirmasi PIN tidak cocok');
        return;
      }

      setState(() => _isLoading = true);

      try {
        bool isRegistered = await ApiService.register(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
        );
        if (!isRegistered) {
          throw Exception(
            'Registrasi gagal. Username/email mungkin sudah terpakai.',
          );
        }

        bool isLoggedIn = await ApiService.login(
          _usernameController.text,
          _passwordController.text,
        );
        if (!isLoggedIn) {
          throw Exception('Gagal login setelah registrasi.');
        }

        Map<String, dynamic> profileData = {
          'full_name': _namaController.text,
          'national_id': _nikController.text,
          'birth_place': _tempatLahirController.text,
          'birth_date':
              '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
          'phone_number': _teleponController.text,
          'occupation': _selectedPekerjaan!.label,
          'monthly_income': double.tryParse(_pendapatanController.text) ?? 0.0,
          'street_address': _alamatController.text,
          'city': _kotaController.text,
          'province': _provinsiController.text,
          'consent_personalization': false,
          'pin': _pinController.text,
        };

        bool isProfileCreated = await ApiService.createProfile(profileData);
        if (!isProfileCreated) {
          throw Exception('Gagal menyimpan profil.');
        }

        if (mounted) {
          _showSnackBar('Akun berhasil dibuat!');
          AuthState.isLoggedIn = true;
          Navigator.pushReplacementNamed(context, '/home-loggedin');
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(e.toString().replaceAll('Exception: ', ''));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _prevStep() {
    if (_currentStep == 3 && _pinPhase == 2) {
      // Balik ke phase 1
      setState(() {
        _pinPhase = 1;
        _pinConfirmController.clear();
        _pinError = false;
      });
      return;
    }
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        if (_currentStep < 3) {
          _pinPhase = 1;
          _pinController.clear();
          _pinConfirmController.clear();
          _pinError = false;
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 1:
        return 'Buat Akun';
      case 2:
        return 'Data Diri';
      case 3:
        return _pinPhase == 1 ? 'Buat PIN' : 'Konfirmasi PIN';
      default:
        return '';
    }
  }

  String get _buttonLabel {
    switch (_currentStep) {
      case 1:
        return 'Lanjut ke Data Diri';
      case 2:
        return 'Lanjut ke Buat PIN';
      case 3:
        return 'Buat Akun';
      default:
        return '';
    }
  }

  bool get _isStep3Ready =>
      _currentStep == 3 &&
      _pinPhase == 2 &&
      _pinConfirmController.text.length == 6 &&
      !_pinError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(
                  height: 280,
                  child: Image.asset(
                    'assets/background/bg-beranda.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                const Expanded(child: ColoredBox(color: Colors.white)),
              ],
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        top: 95,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              Expanded(
                                child: _currentStep == 3
                                    ? _buildStep3()
                                    : SingleChildScrollView(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 8,
                                        ),
                                        child: _currentStep == 1
                                            ? _buildStep1()
                                            : _buildStep2(),
                                      ),
                              ),

                              // Tombol bawah — step 3 hanya tampil kalau PIN siap
                              if (_currentStep != 3 ||
                                  (_currentStep == 3 && _isStep3Ready))
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.fromLTRB(
                                    24,
                                    16,
                                    24,
                                    MediaQuery.of(context).padding.bottom + 24,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE84142),
                                          Color(0xFF7B0000),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _nextStep,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              _buttonLabel,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/octo/octo-regist.svg',
                            height: 125,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _prevStep,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah ${_currentStep == 3 ? "3" : _currentStep}/3',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stepTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 56.0),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: (index + 1) <= _currentStep
                          ? const Color(0xFF8CC63F)
                          : Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRule(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.check_circle_outline,
          size: 18,
          color: isValid ? const Color(0xFF8CC63F) : Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isValid ? const Color(0xFF8CC63F) : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Buat akun Anda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Lengkapi data diri dan buat User ID OCTO untuk transaksi yang lebih mudah melalui Aplikasi OCTO.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Email Aktif',
          hintText: 'Masukkan Email Aktif',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_emailController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildRule('Format email valid', _hasValidEmail),
          ),
        _buildTextField(
          label: 'Username',
          hintText: 'Buat Username',
          controller: _usernameController,
        ),
        if (_usernameController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                _buildRule('Minimal 5-20 karakter', _hasValidUsernameLength),
                const SizedBox(height: 6),
              ],
            ),
          ),
        _buildTextField(
          label: 'Kata Sandi',
          hintText: 'Buat Kata Sandi',
          obscureText: _obscurePassword,
          controller: _passwordController,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF7B0000),
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),

        if (_passwordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                _buildRule('Minimal 6–12 karakter', _hasValidPasswordLength),
                const SizedBox(height: 6),
                _buildRule(
                  'Minimal 1 huruf, angka, dan simbol',
                  _hasLetter && _hasNumber && _hasSymbol,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Lengkapi Data Diri',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Isi data diri kamu sesuai KTP yang berlaku.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Nama Lengkap',
          hintText: 'Masukkan Nama Lengkap',
          controller: _namaController,
        ),
        _buildTextField(
          label: 'NIK',
          hintText: 'Masukkan 16 digit NIK sesuai KTP',
          controller: _nikController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
        ),
        if (_nikController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildRule('NIK harus 16 digit', _hasValidNik),
          ),
        _buildTextField(
          label: 'Tempat Lahir',
          hintText: 'Masukkan Tempat Lahir',
          controller: _tempatLahirController,
        ),

        // Tanggal Lahir
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanggal Lahir',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : '',
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Tanggal Lahir',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                      fontSize: 14,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        'assets/icons/calendar.svg',
                        width: 22,
                        height: 22,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF7B0000),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),

        _buildTextField(
          label: 'Nomor Telepon',
          hintText: 'Masukkan Nomor Telepon Aktif',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: _teleponController,
        ),

        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 16),
          child: Text(
            'Informasi Tambahan',
            style: TextStyle(
              color: Colors.black45,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Pekerjaan
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pekerjaan',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Pekerjaan>(
              initialValue: _selectedPekerjaan,
              hint: const Text(
                'Masukkan Pekerjaan',
                style: TextStyle(color: Colors.black26, fontSize: 14),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF7B0000),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF7B0000),
                    width: 1.5,
                  ),
                ),
              ),
              items: Pekerjaan.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p.label,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedPekerjaan = val),
            ),
            const SizedBox(height: 20),
          ],
        ),

        _buildTextField(
          label: 'Pendapatan Bulanan',
          hintText: 'Masukkan Pendapatan Bulanan (Rp)',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: _pendapatanController,
        ),

        // Alamat dengan autocomplete
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TypeAheadField<Map<String, String>>(
              builder: (context, controller, focusNode) {
                controller.text = _alamatController.text;
                controller.addListener(
                  () => _alamatController.text = controller.text,
                );
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Alamat sesuai KTP',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF7B0000),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
              suggestionsCallback: (pattern) => _getAddressSuggestions(pattern),
              itemBuilder: (context, suggestion) {
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF7B0000),
                    size: 20,
                  ),
                  title: Text(
                    suggestion['display']!,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              },
              onSelected: (suggestion) {
                setState(() {
                  _alamatController.text = suggestion['display']!;
                  if (suggestion['city']!.isNotEmpty) {
                    _kotaController.text = suggestion['city']!;
                  }
                  if (suggestion['province']!.isNotEmpty) {
                    _provinsiController.text = suggestion['province']!;
                  }
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),

        _buildTextField(
          label: 'Kota',
          hintText: 'Masukkan Kota',
          controller: _kotaController,
        ),
        _buildTextField(
          label: 'Provinsi',
          hintText: 'Masukkan Provinsi',
          controller: _provinsiController,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final currentController = _pinPhase == 1
        ? _pinController
        : _pinConfirmController;
    final filledCount = currentController.text.length;

    return Column(
      children: [
        // Title & subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _pinPhase == 1 ? 'Buat PIN OCTO' : 'Konfirmasi PIN OCTO',
                  key: ValueKey(_pinPhase),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _pinPhase == 1
                      ? 'Buat 6 angka PIN OCTO yang tidak mudah ditebak untuk keperluan konfirmasi transaksi.'
                      : 'Masukkan kembali PIN yang sudah kamu buat untuk konfirmasi.',
                  key: ValueKey(_pinPhase),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final filled = index < filledCount;
            final isError = _pinError && _pinPhase == 2;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError
                    ? Colors.red
                    : filled
                    ? const Color(0xFF7B0000)
                    : Colors.grey[300],
              ),
            );
          }),
        ),

        if (_pinError) ...[
          const SizedBox(height: 12),
          const Text(
            'PIN tidak cocok, coba lagi',
            style: TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],

        const Spacer(),

        // Numpad
        Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          child: _buildNumpad(),
        ),
      ],
    );
  }

  Widget _buildNumpad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox();
        if (key == 'del') {
          return GestureDetector(
            onTap: _onNumpadDelete,
            child: Container(
              alignment: Alignment.center,
              child: const Icon(
                Icons.backspace_outlined,
                size: 24,
                color: Colors.black87,
              ),
            ),
          );
        }
        return GestureDetector(
          onTap: () => _onNumpadTap(key),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF7B0000),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
