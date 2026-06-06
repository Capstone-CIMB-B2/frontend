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

  final List<double> _presetAmounts = [10000, 25000, 50000, 100000, 200000, 500000];

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
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  String get _fieldLabel {
    if (widget.transactionMethod == 'Top Up') {
      return 'Nomor Handphone E-Wallet';
    } else if (widget.transactionMethod == 'Pembelian Pulsa') {
      return 'Nomor Handphone Tujuan';
    } else {
      return 'Nomor Pelanggan / Nomor Kontrak';
    }
  }

  String get _fieldHint {
    if (widget.transactionMethod == 'Top Up' || widget.transactionMethod == 'Pembelian Pulsa') {
      return 'Contoh: 081234567890';
    } else {
      return 'Contoh: 1234567890';
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    _catatanController.dispose();
    super.dispose();
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
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    ),
                  ],
                ),
              ),
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
                          // Merchant Details Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3F3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF0F0F2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.transactionMethod == 'Top Up'
                                        ? Icons.account_balance_wallet_outlined
                                        : widget.transactionMethod == 'Pembelian Pulsa'
                                            ? Icons.phone_android_outlined
                                            : Icons.receipt_long_outlined,
                                    color: const Color(0xFF8C0E1A),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.merchantName,
                                        style: const TextStyle(
                                          fontSize: 18,
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
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Customer Number Field
                          Text(
                            _fieldLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _numberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              hintText: _fieldHint,
                              filled: true,
                              fillColor: const Color(0xFFF5F5F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Amount field
                          const Text(
                            'Pilih atau Masukkan Nominal (Rp)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                              hintText: '0',
                              filled: true,
                              fillColor: const Color(0xFFF5F5F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Quick Preset select chips
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _presetAmounts.map((amt) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _amountController.text = amt.toInt().toString();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _amountController.text == amt.toInt().toString()
                                          ? const Color(0xFF8C0E1A)
                                          : const Color(0xFFE2E2E6),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'Rp ${_formatRupiah(amt)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _amountController.text == amt.toInt().toString()
                                          ? const Color(0xFF8C0E1A)
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Source Account (Dari Rekening)
                          const Text(
                            'Bayar Menggunakan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
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
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isLoadingProfile
                                            ? 'Memuat Saldo...'
                                            : 'Saldo: Rp ${_formatRupiah(_accountBalance)}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Notes
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _catatanController,
                              decoration: const InputDecoration(
                                hintText: 'Catatan (Opsional)',
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // SUBMIT BUTTON
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
                            colors: _isButtonEnabled
                                ? [const Color(0xFFCC0000), const Color(0xFF8C0E1A)]
                                : [Colors.grey.shade400, Colors.grey.shade500],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled
                              ? () {
                                  final double amtVal = double.tryParse(_amountController.text) ?? 0.0;
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
                                        catatan: _catatanController.text,
                                        transactionType: 'tagihan',
                                        category: widget.category,
                                        transactionMethod: widget.transactionMethod,
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                          ),
                          child: const Text(
                            'Lanjut ke Konfirmasi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
