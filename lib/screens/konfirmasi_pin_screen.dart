import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';

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
      setState(() {
        _pin += value;
      });

      if (_pin.length == 6) {
        _processTransfer();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  String _formatRupiah(double amount) {
    int val = amount.toInt();
    String str = val.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return result;
  }

  Future<void> _processTransfer() async {
    // Tampilkan loading dialog
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

    // Kirim request ke backend sesuai tipe transaksi
    final Map<String, dynamic>? result;
    if (widget.transactionType == 'qris' || widget.transactionType == 'tagihan') {
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
    // Pop loading dialog
    Navigator.pop(context);

    if (result != null && result['success'] == true) {
      // Tampilkan success dialog
      _showSuccessDialog();
    } else {
      // Tampilkan pesan error
      final errorMsg = (result != null)
          ? (result['message'] ?? 'Terjadi kesalahan')
          : 'Terjadi kesalahan jaringan';

      // Reset PIN
      setState(() {
        _pin = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: const TextStyle(fontFamily: 'Calibri', color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8C0E1A),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isTransfer = widget.transactionType == 'transfer';
        final double transactionFee = isTransfer ? 2500.0 : 0.0;
        final double totalAmount = widget.nominal + transactionFee;

        String titleText = 'Transfer Berhasil!';
        if (widget.transactionType == 'qris') {
          titleText = 'Pembayaran QRIS Berhasil!';
        } else if (widget.transactionType == 'tagihan') {
          titleText = 'Pembayaran Berhasil!';
        }

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Calibri',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Transaksi Anda telah selesai diproses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Calibri',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFEFEFEF), thickness: 1),
                  const SizedBox(height: 12),

                  // DETAIL TRANSAKSI
                  _buildDetailRow(
                    widget.transactionType == 'qris'
                        ? 'Merchant'
                        : widget.transactionType == 'tagihan'
                            ? 'Produk/Merchant'
                            : 'Penerima',
                    widget.recipientName,
                    icon: widget.transactionType == 'qris'
                        ? Icons.storefront_rounded
                        : widget.transactionType == 'tagihan'
                            ? Icons.receipt_long_rounded
                            : Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    widget.transactionType == 'qris'
                        ? 'Metode'
                        : widget.transactionType == 'tagihan'
                            ? 'Metode'
                            : 'Bank Tujuan',
                    widget.transactionType == 'qris'
                        ? 'QRIS'
                        : widget.transactionType == 'tagihan'
                            ? (widget.transactionMethod ?? 'Bayar Tagihan')
                            : widget.recipientBank,
                    icon: widget.transactionType == 'qris'
                        ? Icons.qr_code_2_rounded
                        : widget.transactionType == 'tagihan'
                            ? Icons.payment_rounded
                            : Icons.account_balance_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    widget.transactionType == 'qris'
                        ? 'ID Transaksi'
                        : widget.transactionType == 'tagihan'
                            ? 'No. Kontrak/HP'
                            : 'No. Rekening',
                    widget.recipientAccount,
                    icon: widget.transactionType == 'qris'
                        ? Icons.pin_outlined
                        : widget.transactionType == 'tagihan'
                            ? Icons.phone_android_rounded
                            : Icons.credit_card_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    'Nominal',
                    'Rp${_formatRupiah(widget.nominal)}',
                    icon: Icons.monetization_on_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    'Biaya Transaksi',
                    'Rp${_formatRupiah(transactionFee)}',
                    icon: Icons.receipt_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    'Total Transaksi',
                    'Rp${_formatRupiah(totalAmount)}',
                    isBold: true,
                    icon: Icons.calculate_outlined,
                  ),

                  if (widget.catatan.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      'Catatan',
                      widget.catatan,
                      icon: Icons.notes_rounded,
                    ),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Kembali ke dashboard utama
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home-loggedin',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C0E1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Calibri',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildDetailRow(String label, String value, {bool isBold = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF8C0E1A),
            ),
            const SizedBox(width: 12),
          ] else ...[
            const SizedBox(width: 32),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Calibri',
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Calibri',
              ),
            ),
          ),
        ],
      ),
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
                  // TITLE & SUBTITLE
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

                  // PIN INDICATORS
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

                  // KEYPAD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildKeypadButton('1'),
                            const SizedBox(width: 30),
                            _buildKeypadButton('2'),
                            const SizedBox(width: 30),
                            _buildKeypadButton('3'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildKeypadButton('4'),
                            const SizedBox(width: 30),
                            _buildKeypadButton('5'),
                            const SizedBox(width: 30),
                            _buildKeypadButton('6'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildKeypadButton('7'),
                            const SizedBox(width: 30),
                            _buildKeypadButton('8'),
                            const SizedBox(width: 30),
                            _buildKeypadButton('9'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLupaPinButton(),
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

  Widget _buildLupaPinButton() {
    return GestureDetector(
      onTap: () {
        // Tampilkan info lupa pin atau ganti pin
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan hubungi call center atau gunakan fitur Reset PIN.',
            ),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: const Text(
          'Lupa PIN',
          style: TextStyle(
            color: Color(0xFFE5232B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
