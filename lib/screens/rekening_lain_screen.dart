import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'detail_transfer_screen.dart';
import '../services/api_service.dart';

// SCREEN REKENING LAIN
// ─────────────────────────────────────────────
class RekeningLainScreen extends StatefulWidget {
  const RekeningLainScreen({super.key});

  @override
  State<RekeningLainScreen> createState() => _RekeningLainScreenState();
}

class _RekeningLainScreenState extends State<RekeningLainScreen> {
  String _selectedBank = 'BANK CIMB NIAGA';
  final TextEditingController _accountNumberController =
      TextEditingController();
  bool _saveToFavorites = false;
  bool _isButtonEnabled = false;

  final List<String> _bankOptions = [
    'BANK CIMB NIAGA',
    'BANK CENTRAL ASIA (BCA)',
    'BANK NEGARA INDONESIA (BNI)',
    'BANK RAKYAT INDONESIA (BRI)',
    'BANK MANDIRI',
  ];

  @override
  void initState() {
    super.initState();
    _accountNumberController.addListener(() {
      setState(() {
        _isButtonEnabled = _accountNumberController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  void _showBankSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.70,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: Text(
                    'Pilih Bank Tujuan',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Calibri',
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _bankOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bank = _bankOptions[index];
                    final isSelected = bank == _selectedBank;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBank = bank;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF8C0E1A)
                                : const Color(0xFFE2E2E6),
                            width: isSelected ? 1.5 : 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F3F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                size: 18,
                                color: Color(0xFF8C0E1A),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                bank,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: Colors.black87,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: Color(0xFF8C0E1A),
                                size: 22,
                              )
                            else
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Header Widget
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SimpleHeader(
              title: 'Rekening Lain',
              height: headerHeight,
              onBack: () => Navigator.pop(context),
            ),
          ),

          // 2. Konten Utama
          Positioned(
            top: headerHeight - 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 24.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bank Tujuan
                              const Text(
                                'Bank Tujuan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _showBankSelectionSheet,
                                child: Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E2E6),
                                      width: 1.2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedBank,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontFamily: 'Calibri',
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF8C0E1A),
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Nomor Rekening
                              const Text(
                                'Nomor Rekening',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _accountNumberController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'Calibri',
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E2E6),
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E2E6),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8C0E1A),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Simpan ke Favorit Row
                              Container(
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE2E2E6),
                                    width: 1.2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Tambahkan ke Daftar Tersimpan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontFamily: 'Calibri',
                                      ),
                                    ),
                                    Switch(
                                      value: _saveToFavorites,
                                      onChanged: (val) {
                                        setState(() {
                                          _saveToFavorites = val;
                                        });
                                      },

                                      activeThumbColor: Colors.white,
                                      activeTrackColor: const Color(0xFF8C0E1A),

                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: Colors.grey.shade300,

                                      trackOutlineColor:
                                          WidgetStateProperty.all(
                                            Colors.transparent,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tombol Selanjutnya
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).padding.bottom + 20,
                        top: 10,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: _isButtonEnabled
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFCC0000),
                                      Color(0xFF8C0E1A),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : null,
                            color: _isButtonEnabled
                                ? null
                                : const Color(0xFFE2E2E6),
                          ),
                          child: ElevatedButton(
                            onPressed: _isButtonEnabled
                                ? () async {
                                    final navigator = Navigator.of(context);
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF8C0E1A),
                                        ),
                                      ),
                                    );

                                    final cleanBank = _selectedBank.replaceAll(
                                      'BANK ',
                                      '',
                                    );

                                    final result =
                                        await ApiService.validateAccount(
                                          bankName: cleanBank,
                                          accountNumber:
                                              _accountNumberController.text
                                                  .trim(),
                                        );

                                    if (!mounted) return;

                                    navigator.pop();

                                    if (result != null &&
                                        result['success'] == true) {
                                      navigator.push(
                                        MaterialPageRoute(
                                          builder: (_) => DetailTransferScreen(
                                            recipientName:
                                                result['account_name'] ??
                                                'SHAZFA ADESYA',
                                            recipientBank: cleanBank,
                                            recipientAccount:
                                                _accountNumberController.text
                                                    .trim(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      final errorMsg = result != null
                                          ? result['message']
                                          : 'Nomor rekening tidak ditemukan!';

                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            errorMsg,
                                            style: const TextStyle(
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFF8C0E1A,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              disabledForegroundColor: Colors.white70,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: const Text(
                              'Selanjutnya',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Calibri',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HEADER
// ─────────────────────────────────────────────
class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({
    required this.title,
    required this.height,
    required this.onBack,
  });

  final String title;
  final double height;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/background/bg-header.svg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Calibri',
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
