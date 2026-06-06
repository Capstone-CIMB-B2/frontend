import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'ringkasan_transfer_screen.dart';
import '../services/api_service.dart';

class DetailTransferScreen extends StatefulWidget {
  final String recipientName;
  final String recipientBank;
  final String recipientAccount;

  const DetailTransferScreen({
    super.key,
    required this.recipientName,
    required this.recipientBank,
    required this.recipientAccount,
  });

  @override
  State<DetailTransferScreen> createState() => _DetailTransferScreenState();
}

class _DetailTransferScreenState extends State<DetailTransferScreen> {
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  bool _isButtonEnabled = false;
  String _accountNumber = '••••1854';
  double _accountBalance = 0.0;
  bool _balanceVisible = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();

    _nominalController.addListener(() {
      setState(() {
        _isButtonEnabled =
            _nominalController.text.trim().isNotEmpty &&
            (double.tryParse(
                      _nominalController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    0) >
                0;
      });
    });
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _accountNumber = profile['account_number'] ?? '';
        _accountBalance = (profile['account_balance'] ?? 0.0).toDouble();
        _isLoadingProfile = false;
      });
    } else {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  String get _accountMasked {
    if (_accountNumber.length >= 4) {
      return '(••••${_accountNumber.substring(_accountNumber.length - 4)})';
    }
    return '(••••)';
  }

  String _formatRupiah(double amount) {
    int val = amount.toInt();
    String str = val.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return result;
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'SA';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SimpleHeader(
              title: 'Detail Transfer',
              height: headerHeight,
              onBack: () => Navigator.pop(context),
            ),
          ),

          // CONTENT
          Positioned(
            top: headerHeight - 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CARD PENERIMA
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3F3F3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getInitials(widget.recipientName),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8C0E1A),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.recipientName.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 0),
                                      Text(
                                        '${widget.recipientBank} • ${widget.recipientAccount}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // NOMINAL
                          const Text(
                            'Nominal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Calibri',
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Rp ',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _nominalController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(thickness: 1, color: Colors.black26),

                          const SizedBox(height: 20),

                          // TRANSFER DARI
                          const Text(
                            'Transfer dari',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Calibri',
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE2E2E6),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  child: SvgPicture.asset(
                                    'assets/icons/Savers.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'OCTO Savers $_accountMasked',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _balanceVisible = !_balanceVisible;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              _balanceVisible
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons
                                                        .remove_red_eye_outlined,
                                              size: 15,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _isLoadingProfile
                                                  ? 'Memuat...'
                                                  : (_balanceVisible
                                                        ? 'IDR ${_formatRupiah(_accountBalance)}'
                                                        : 'IDR •••'),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black54,
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
                          ),

                          const SizedBox(height: 25),

                          // CATATAN
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAEAEA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextField(
                              controller: _catatanController,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Catatan (Opsional)',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BUTTON
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                      top: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCC0000), Color(0xFF8C0E1A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled
                              ? () {
                                  final cleanNominalText = _nominalController
                                      .text
                                      .replaceAll(RegExp(r'[^0-9]'), '');

                                  final double nominalVal =
                                      double.tryParse(cleanNominalText) ?? 0.0;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RingkasanTransferScreen(
                                        recipientName: widget.recipientName,
                                        recipientBank: widget.recipientBank,
                                        recipientAccount:
                                            widget.recipientAccount,
                                        nominal: nominalVal,
                                        catatan: _catatanController.text,
                                        senderAccount: _accountMasked,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Selanjutnya',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}

// HEADER
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
