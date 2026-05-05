import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

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

  void _nextStep() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else {
      // Selesai registrasi
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Akun berhasil dibuat!')));
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep == 2) {
      setState(() => _currentStep = 1);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
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

          // Konten utama
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
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  child: _currentStep == 1
                                      ? _buildStep1()
                                      : _buildStep2(),
                                ),
                              ),
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
                                    onPressed: _nextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      _currentStep == 1
                                          ? 'Lanjut ke Data Diri'
                                          : 'Buat Akun',
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

              // Judul
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah $_currentStep/2',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentStep == 1 ? 'Buat Akun' : 'Data Diri',
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

          // Progress Bar
          Padding(
            padding: const EdgeInsets.only(left: 56.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Row(
                children: [
                  Expanded(
                    child: Container(height: 4, color: const Color(0xFF8CC63F)),
                  ),
                  Expanded(
                    child: Container(
                      height: 4,
                      color: _currentStep == 2
                          ? const Color(0xFF8CC63F)
                          : Colors.black.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        _buildTextField(label: 'Email Aktif', hintText: 'Masukkan Email Aktif'),
        _buildTextField(label: 'Username', hintText: 'Buat Username'),
        _buildTextField(
          label: 'Kata Sandi',
          hintText: 'Buat Kata Sandi',
          isPassword: true,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF7B0000),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
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
            'Lengkapi data diri dan buat User ID OCTO untuk transaksi yang lebih mudah melalui Aplikasi OCTO.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Nama Lengkap',
          hintText: 'Masukkan Nama Lengkap',
        ),
        _buildTextField(label: 'NIK', hintText: 'Masukkan NIK sesuai KTP'),

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
                    suffixIcon: const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF7B0000),
                      size: 22,
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
              value: _selectedPekerjaan,
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
          label: 'Alamat',
          hintText: 'Masukkan Alamat sesuai KTP',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    bool isPassword = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
          obscureText: isPassword,
          keyboardType: keyboardType, // ← tambah ini
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
