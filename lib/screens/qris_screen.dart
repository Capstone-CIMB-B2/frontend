import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import 'konfirmasi_pin_screen.dart';

class QrisScreen extends StatefulWidget {
  const QrisScreen({super.key});

  @override
  State<QrisScreen> createState() => _QrisScreenState();
}

class _QrisScreenState extends State<QrisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  final MobileScannerController _cameraController = MobileScannerController();
  bool _hasScanned = false;

  // 0: Scan Camera View, 1: Amount Payment View
  int _currentStep = 0;

  // Decoded Merchant Data
  String _merchantId = '';
  String _merchantName = '';
  String _category = '';
  String _transactionMethod = '';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  double _accountBalance = 0.0;
  String _accountNumber = '';
  bool _isLoadingProfile = true;
  bool _isPayEnabled = false;

  // Simulated QR payload strings for gallery fallback
  final List<Map<String, String>> _mockQrCodes = [
    {
      'name': 'Kopi Kenangan',
      'category': 'Food & Beverage',
      'payload': 'MRC_KOPI_KENANGAN',
    },
    {'name': 'McD', 'category': 'Food & Beverage', 'payload': 'MRC_MCD'},
    {
      'name': 'Starbucks',
      'category': 'Food & Beverage',
      'payload': 'MRC_STARBUCKS',
    },
    {
      'name': 'Janji Jiwa',
      'category': 'Food & Beverage',
      'payload': 'MRC_JANJI_JIWA',
    },
    {'name': 'Grab', 'category': 'Transport & Mobility', 'payload': 'MRC_GRAB'},
    {
      'name': 'Gojek',
      'category': 'Transport & Mobility',
      'payload': 'MRC_GOJEK',
    },
    {
      'name': 'Indomaret',
      'category': 'Retail & Convenience',
      'payload': 'MRC_INDOMARET',
    },
    {
      'name': 'Alfamart',
      'category': 'Retail & Convenience',
      'payload': 'MRC_ALFAMART',
    },
    {
      'name': 'FamilyMart',
      'category': 'Retail & Convenience',
      'payload': 'MRC_FAMILYMART',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final double val = double.tryParse(text) ?? 0.0;
      setState(() => _isPayEnabled = val > 0);
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
      setState(() => _isLoadingProfile = false);
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
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  Future<void> _decodeQrCode(String payload) async {
    if (_hasScanned) return;
    _hasScanned = true;
    _cameraController.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF8C0E1A)),
              SizedBox(height: 20),
              Text(
                'Membaca Kode QRIS...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Calibri',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final result = await ApiService.decodeQr(payload);

    if (!mounted) return;
    Navigator.pop(context);

    if (result != null) {
      setState(() {
        _merchantId = result['merchant_id'] ?? 'MRC_UNKNOWN';
        _merchantName = result['merchant_name'] ?? 'Unknown Merchant';
        _category = result['category'] ?? 'General';
        _transactionMethod = result['transaction_method'] ?? 'QRIS';
        _currentStep = 1;
      });
    } else {
      _hasScanned = false;
      _cameraController.start();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode QRIS tidak valid atau gagal dibaca oleh server!'),
          backgroundColor: Color(0xFF8C0E1A),
        ),
      );
    }
  }

  void _showGalleryPicker() {
    _cameraController.stop();

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
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Galeri Foto - Pilih Gambar QRIS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih salah satu Kode QR di bawah untuk disimulasikan pemindaiannya.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _mockQrCodes.length,
                  itemBuilder: (context, index) {
                    final item = _mockQrCodes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _decodeQrCode(item['payload']!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(90, 90),
                              painter: QrCodePainter(item['payload']!),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['name']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['category']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
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
    ).then((_) {
      if (_currentStep == 0 && !_hasScanned) _cameraController.start();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 1) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Detail Pembayaran QRIS',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _currentStep = 0;
                _hasScanned = false;
                _amountController.clear();
                _notesController.clear();
              });
              _cameraController.start();
            },
          ),
        ),
        body: _buildAmountView(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. LIVE CAMERA (full screen) ──────────────────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraController,
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                if (barcode?.rawValue != null) {
                  _decodeQrCode(barcode!.rawValue!);
                }
              },
            ),
          ),

          // ── 2. DARK OVERLAY (outside scan frame) ─────────────────────
          Positioned.fill(child: CustomPaint(painter: _ScanOverlayPainter())),

          // ── 3. ANIMATED SCAN LINE ─────────────────────────────────────
          _buildScanLine(),

          // ── 4. TOP HEADER ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const Text(
                      'QRIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Flash toggle
                    GestureDetector(
                      onTap: () => _cameraController.toggleTorch(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 5. SCAN FRAME CORNERS + HINT TEXT ────────────────────────
          _buildScanFrameArea(context),

          // ── 6. BOTTOM PANEL ───────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gallery button — floats above the red bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: _showGalleryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Pindai QR dari Galeri',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Red bar
                Container(
                  width: double.infinity,
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5232B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gunakan QRIS di berbagai negara berikut',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ],
                  ),
                ),

                // White bottom panel
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Atau, buat kode QR dengan memilih salah satu opsi berikut.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          // QRIS Tap card
                          Expanded(
                            child: Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/QRIS/QRISTap.svg',
                                    height: 40,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'QRIS Tap',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // QR Bayar card
                          Expanded(
                            child: Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/QRIS/QRBayar.svg',
                                    height: 40,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'QR Bayar',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  // ── Scan frame corners + instructional text ──────────────────────────
  Widget _buildScanFrameArea(BuildContext context) {
    const double frameSize = 260.0;
    const double cornerLen = 28.0;
    const double cornerThick = 4.0;
    const Color cornerColor = Colors.white;

    return Positioned.fill(
      child: Align(
        alignment: const Alignment(0, -0.15), // slightly above center
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: frameSize,
              height: frameSize,
              child: Stack(
                children: [
                  // Top-left
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _Corner(
                      len: cornerLen,
                      thick: cornerThick,
                      color: cornerColor,
                      top: true,
                      left: true,
                    ),
                  ),
                  // Top-right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _Corner(
                      len: cornerLen,
                      thick: cornerThick,
                      color: cornerColor,
                      top: true,
                      left: false,
                    ),
                  ),
                  // Bottom-left
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _Corner(
                      len: cornerLen,
                      thick: cornerThick,
                      color: cornerColor,
                      top: false,
                      left: true,
                    ),
                  ),
                  // Bottom-right
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _Corner(
                      len: cornerLen,
                      thick: cornerThick,
                      color: cornerColor,
                      top: false,
                      left: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Arahkan kamera ke QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Animated red laser scan line inside the frame ────────────────────
  Widget _buildScanLine() {
    const double frameSize = 260.0;
    return Positioned.fill(
      child: Align(
        alignment: const Alignment(0, -0.15),
        child: SizedBox(
          width: frameSize,
          height: frameSize,
          child: AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned(
                    top: 4 + (_scanAnimation.value * (frameSize - 8)),
                    left: 4,
                    right: 4,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5232B),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5232B).withOpacity(0.7),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Amount input screen ──────────────────────────────────────────────
  Widget _buildAmountView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Merchant card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF5E1E1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: Color(0xFF8C0E1A),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _merchantName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Metode: QRIS • $_category',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Nominal Belanja',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Rp ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontSize: 28,
                            color: Colors.black26,
                            fontWeight: FontWeight.bold,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 1, color: Colors.black26),
                const SizedBox(height: 24),

                const Text(
                  'Bayar Menggunakan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E2E6)),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Savers.svg',
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFF8C0E1A),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OCTO Savers $_accountMasked',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isLoadingProfile
                                  ? 'Memuat Saldo...'
                                  : 'Saldo: Rp ${_formatRupiah(_accountBalance)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Catatan (Opsional)',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            top: 10,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                gradient: LinearGradient(
                  colors: _isPayEnabled
                      ? [const Color(0xFFCC0000), const Color(0xFF8C0E1A)]
                      : [Colors.grey.shade400, Colors.grey.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ElevatedButton(
                onPressed: _isPayEnabled
                    ? () {
                        final double amtVal =
                            double.tryParse(_amountController.text) ?? 0.0;
                        if (amtVal > _accountBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saldo Anda tidak mencukupi.'),
                              backgroundColor: Color(0xFF8C0E1A),
                            ),
                          );
                          return;
                        }
                        final randId =
                            'QRIS-${100000 + Random().nextInt(900000)}';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KonfirmasiPinScreen(
                              recipientName: _merchantName,
                              recipientBank: _category,
                              recipientAccount: randId,
                              nominal: amtVal,
                              catatan: _notesController.text,
                              transactionType: 'qris',
                              category: _category,
                              transactionMethod: 'QRIS',
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
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Corner bracket widget ────────────────────────────────────────────────
class _Corner extends StatelessWidget {
  final double len;
  final double thick;
  final Color color;
  final bool top;
  final bool left;

  const _Corner({
    required this.len,
    required this.thick,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
        painter: _CornerPainter(
          thick: thick,
          color: color,
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double thick;
  final Color color;
  final bool top;
  final bool left;

  _CornerPainter({
    required this.thick,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;

    // Horizontal line
    final double hStartX = left ? 0 : w;
    final double hEndX = left ? w : 0;
    final double hY = top ? 0 : h;
    canvas.drawLine(Offset(hStartX, hY), Offset(hEndX, hY), paint);

    // Vertical line
    final double vX = left ? 0 : w;
    final double vStartY = top ? 0 : h;
    final double vEndY = top ? h : 0;
    canvas.drawLine(Offset(vX, vStartY), Offset(vX, vEndY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Dark overlay with transparent scan frame cutout ──────────────────────
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double frameSize = 260.0;
    const double frameRadius = 12.0;

    final cx = size.width / 2;
    // Same vertical alignment as Alignment(0, -0.15)
    final cy = size.height / 2 + (size.height * -0.15 / 2);

    final frameRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: frameSize,
      height: frameSize,
    );

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(frameRect, const Radius.circular(frameRadius)),
      );

    final finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      holePath,
    );

    canvas.drawPath(finalPath, Paint()..color = Colors.black.withOpacity(0.55));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Mock QR painter (for gallery simulation) ─────────────────────────────
class QrCodePainter extends CustomPainter {
  final String data;
  QrCodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paintBlack = Paint()..color = Colors.black;
    final paintWhite = Paint()..color = Colors.white;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      paintWhite,
    );

    const double pad = 6.0;
    final double qrW = size.width - (pad * 2);
    final double qrH = size.height - (pad * 2);

    _drawFinderPattern(canvas, pad, pad, 26, paintBlack, paintWhite);
    _drawFinderPattern(canvas, pad + qrW - 26, pad, 26, paintBlack, paintWhite);
    _drawFinderPattern(canvas, pad, pad + qrH - 26, 26, paintBlack, paintWhite);

    final random = Random(data.hashCode);
    const int gridSize = 19;
    final double stepX = qrW / gridSize;
    final double stepY = qrH / gridSize;
    const int limit = 6;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if ((r < limit && c < limit) ||
            (r < limit && c >= gridSize - limit) ||
            (r >= gridSize - limit && c < limit))
          continue;
        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(pad + (c * stepX), pad + (r * stepY), stepX, stepY),
            paintBlack,
          );
        }
      }
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    double x,
    double y,
    double sz,
    Paint paintBlack,
    Paint paintWhite,
  ) {
    canvas.drawRect(Rect.fromLTWH(x, y, sz, sz), paintBlack);
    final double innerW = sz * 5 / 7;
    final double offsetW = (sz - innerW) / 2;
    canvas.drawRect(
      Rect.fromLTWH(x + offsetW, y + offsetW, innerW, innerW),
      paintWhite,
    );
    final double dotW = sz * 3 / 7;
    final double offsetD = (sz - dotW) / 2;
    canvas.drawRect(
      Rect.fromLTWH(x + offsetD, y + offsetD, dotW, dotW),
      paintBlack,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
