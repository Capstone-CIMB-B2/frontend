import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import 'success_screen.dart';

class KonfirmasiPinScreen extends StatefulWidget {
  final String recipientName;
  final String recipientBank;
  final String recipientAccount;
  final double nominal;
  final String catatan;
  final String? transactionType; // 'transfer', 'qris', 'tagihan'
  final String? category;
  final String? transactionMethod;

  const KonfirmasiPinScreen({
    super.key,
    required this.recipientName,
    required this.recipientBank,
    required this.recipientAccount,
    required this.nominal,
    required this.catatan,
    this.transactionType = 'transfer',
    this.category,
    this.transactionMethod,
  });

  @override
  State<KonfirmasiPinScreen> createState() => _KonfirmasiPinScreenState();
}

class _KonfirmasiPinScreenState extends State<KonfirmasiPinScreen> {
  String _pin = '';

  void _onKeyPress(String value) {
    if (_pin.length < 6) {
      setState(() => _pin += value);
      if (_pin.length == 6) {
        _processTransfer();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _processTransfer() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String loadingText = 'Memproses Transfer...';
        if (widget.transactionType == 'qris') {
          loadingText = 'Memproses Pembayaran QRIS...';
        } else if (widget.transactionType == 'tagihan') {
          loadingText = 'Memproses Pembayaran...';
        }
        return Dialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF8C0E1A)),
                const SizedBox(height: 20),
                Text(
                  loadingText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Calibri',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    final Map<String, dynamic>? result;
    if (widget.transactionType == 'qris' ||
        widget.transactionType == 'tagihan') {
      result = await ApiService.createTransaction(
        category: widget.category ?? 'General',
        merchantName: widget.recipientName,
        transactionMethod: widget.transactionMethod ?? 'Bayar Tagihan',
        amount: widget.nominal,
        notes: widget.catatan,
        pin: _pin,
        recipientBank: widget.recipientBank,
        recipientAccount: widget.recipientAccount,
      );
    } else {
      result = await ApiService.transfer(
        recipientName: widget.recipientName,
        recipientBank: widget.recipientBank,
        recipientAccount: widget.recipientAccount,
        amount: widget.nominal,
        notes: widget.catatan,
        pin: _pin,
      );
    }

    if (!mounted) return;
    Navigator.pop(context); // pop loading

    if (result != null && result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            recipientName: widget.recipientName,
            recipientBank: widget.recipientBank,
            recipientAccount: widget.recipientAccount,
            nominal: widget.nominal,
            catatan: widget.catatan,
            transactionType: widget.transactionType,
            transactionMethod: widget.transactionMethod,
          ),
        ),
      );
    } else {
      final errorMsg = (result != null)
          ? (result['message'] ?? 'Terjadi kesalahan')
          : 'Terjadi kesalahan jaringan';
      setState(() => _pin = '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style:
                const TextStyle(fontFamily: 'Calibri', color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8C0E1A),
        ),
      );
    }
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
              title: 'Konfirmasi PIN',
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
                  const SizedBox(height: 70),
                  const Text(
                    'Masukin PIN OCTO',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PIN OCTO 6 digit kamu',
                    style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 60),

                  // PIN indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isFilled = index < _pin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? const Color(0xFFE5232B)
                              : Colors.transparent,
                          border: Border.all(
                            color: const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 60),

                  // Keypad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        _buildRow(['1', '2', '3']),
                        const SizedBox(height: 30),
                        _buildRow(['4', '5', '6']),
                        const SizedBox(height: 30),
                        _buildRow(['7', '8', '9']),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPlaceholder(), // simetris, kosong
                            const SizedBox(width: 30),
                            _buildKeypadButton('0'),
                            const SizedBox(width: 30),
                            _buildBackspaceButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys
          .expand(
            (k) => [
              _buildKeypadButton(k),
              if (k != keys.last) const SizedBox(width: 30),
            ],
          )
          .toList(),
    );
  }

  Widget _buildKeypadButton(String val) {
    return GestureDetector(
      onTap: () => _onKeyPress(val),
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F1F3),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          val,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  /// Placeholder kosong simetris (menggantikan tombol "Lupa PIN")
  Widget _buildPlaceholder() {
    return const SizedBox(width: 70, height: 70);
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F1F3),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.backspace, color: Colors.black87, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIMPLE HEADER
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
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
    );
  }
}