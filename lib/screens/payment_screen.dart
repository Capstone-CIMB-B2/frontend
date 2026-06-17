import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import 'konfirmasi_pin_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String category;
  final String merchantName;
  final String transactionMethod;

  const PaymentScreen({
    super.key,
    required this.category,
    required this.merchantName,
    required this.transactionMethod,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  bool _isButtonEnabled = false;
  double _accountBalance = 0.0;
  String _accountNumber = '';
  bool _isLoadingProfile = true;
  bool _balanceVisible = false;

  // Pulsa: selected preset index
  int? _selectedPresetIndex;

  // Pulsa preset amounts
  final List<double> _pulsaPresets = [
    15000,
    25000,
    30000,
    40000,
    50000,
    75000,
    100000,
    150000,
  ];

  bool get _isPulsa => widget.transactionMethod == 'Pembelian Pulsa';
  bool get _isTopUp => widget.transactionMethod == 'Top Up';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _numberController.addListener(_validateInputs);
    _amountController.addListener(_validateInputs);
  }

  void _validateInputs() {
    final numText = _numberController.text.trim();
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final double amountVal = double.tryParse(amountText) ?? 0.0;
    setState(() {
      _isButtonEnabled = numText.length >= 5 && amountVal > 0;
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

  String get _numberFieldLabel {
    if (_isTopUp) return 'Nomor E-Wallet';
    if (_isPulsa) return 'Nomor Telepon';
    return 'Nomor Pelanggan';
  }

  String get _numberFieldHint {
    if (_isTopUp) return 'Masukkan Nomor E-Wallet';
    if (_isPulsa) return 'Masukkan Nomor Telepon';
    return 'Masukkan Nomor Pelanggan';
  }

  String get _nominalLabel {
    if (_isTopUp) return 'Nominal Top Up';
    if (_isPulsa) return 'Nominal Pulsa';
    return 'Nominal Pembayaran';
  }

  IconData get _merchantIcon {
    if (_isTopUp) return Icons.account_balance_wallet_outlined;
    if (_isPulsa) return Icons.phone_android_outlined;
    return Icons.receipt_long_outlined;
  }

  /// Key merchant — capitalize huruf pertama tiap kata, spasi dihapus.
  /// Contoh: 'kopi kenangan' → 'KopiKenangan', 'gopay' → 'Gopay'
  /// Sesuai konvensi nama file: Gopay.svg, IndiHome.svg, dst.
  String get _merchantKey {
    return widget.merchantName
        .trim()
        .split(RegExp(r'\s+'))
        .map(
          (w) => w.isEmpty
              ? ''
              : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join();
  }

  /// Merchant yang punya asset SVG.
  static const _svgMerchants = {
    'Biznet',
    'Dana',
    'Gopay',
    'Indihome',
    'Indosat',
    'Netflix',
    'Pln',
    'Shopeepay',
    'Spotify',
    'Telkomsel',
    'Xl',
  };

  /// Merchant yang punya asset PNG.
  static const _pngMerchants = {'Ovo', 'Telkom', 'Youtube', 'Pdam'};

  /// Tipe asset: 'svg', 'png', atau null jika tidak ada.
  String? get _merchantAssetType {
    if (_svgMerchants.contains(_merchantKey)) return 'svg';
    if (_pngMerchants.contains(_merchantKey)) return 'png';
    return null;
  }

  String? get _merchantAssetPath {
    final type = _merchantAssetType;
    if (type == null) return null;
    return 'assets/logo/$_merchantKey.$type';
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final double amtVal =
        double.tryParse(
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0.0;
    if (amtVal > _accountBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo Anda tidak mencukupi untuk pembayaran ini.'),
          backgroundColor: Color(0xFF8C0E1A),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KonfirmasiPinScreen(
          recipientName: widget.merchantName,
          recipientBank: widget.category,
          recipientAccount: _numberController.text.trim(),
          nominal: amtVal,
          catatan: _isTopUp ? _catatanController.text : '',
          transactionType: 'tagihan',
          category: widget.category,
          transactionMethod: widget.transactionMethod,
        ),
      ),
    );
  }

  Widget get _fallbackIcon => Center(
    child: Icon(_merchantIcon, color: const Color(0xFF8C0E1A), size: 26),
  );

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── HEADER ────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: headerHeight,
              child: ClipRRect(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SvgPicture.asset(
                        'assets/background/bg-header.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
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
                                widget.transactionMethod,
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
                  ],
                ),
              ),
            ),
          ),

          // ── CONTENT ───────────────────────────────────────────────────
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
                          // ── MERCHANT CARD ──────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E2E6),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3F3F3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: _merchantAssetPath != null
                                        ? (_merchantAssetType == 'svg'
                                              ? SvgPicture.asset(
                                                  _merchantAssetPath!,
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) =>
                                                      _fallbackIcon,
                                                )
                                              : Image.asset(
                                                  _merchantAssetPath!,
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) =>
                                                      _fallbackIcon,
                                                ))
                                        : _fallbackIcon,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.merchantName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.category,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── NOMOR FIELD ────────────────────────────────
                          Text(
                            _numberFieldLabel,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Calibri',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _numberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: _numberFieldHint,
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── NOMINAL ────────────────────────────────────
                          Text(
                            _nominalLabel,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Calibri',
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Pulsa: grid card 2 kolom
                          if (_isPulsa) ...[
                            _buildPulsaGrid(),
                          ]
                          // Top Up & Tagihan: input teks bebas + chip preset (Top Up saja)
                          else ...[
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
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black26,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(thickness: 1, color: Colors.black26),
                          ],

                          const SizedBox(height: 24),

                          // ── TRANSFER DARI ──────────────────────────────
                          const Text(
                            'Transfer dari',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Calibri',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E2E6),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/Savers.svg',
                                  width: 34,
                                  height: 34,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.account_balance_wallet,
                                    color: Color(0xFF8C0E1A),
                                  ),
                                ),
                                const SizedBox(width: 14),
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
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _balanceVisible =
                                              !_balanceVisible,
                                        ),
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
                                                fontSize: 14,
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

                          // ── CATATAN (hanya Top Up) ─────────────────────
                          if (_isTopUp) ...[
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _catatanController,
                                decoration: const InputDecoration(
                                  hintText: 'Catatan (Opsional)',
                                  hintStyle: TextStyle(color: Colors.black45),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // ── BUTTON ─────────────────────────────────────────────
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
                          gradient: LinearGradient(
                            colors: _isButtonEnabled
                                ? [
                                    const Color(0xFFCC0000),
                                    const Color(0xFF8C0E1A),
                                  ]
                                : [Color(0xFFE2E2E6), Color(0xFFE2E2E6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled ? _onSubmit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            disabledForegroundColor: Colors.white,
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

  // ── Grid 2 kolom untuk pilihan nominal pulsa ──────────────────────────
  Widget _buildPulsaGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.7,
      ),
      itemCount: _pulsaPresets.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedPresetIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPresetIndex = index;
              _amountController.text = _pulsaPresets[index].toInt().toString();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFFF0F0)
                  : const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8C0E1A)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _formatRupiah(_pulsaPresets[index]),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF8C0E1A) : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}
