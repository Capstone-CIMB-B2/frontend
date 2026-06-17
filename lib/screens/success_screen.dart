import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import '../services/api_service.dart';

class SuccessScreen extends StatefulWidget {
  final String recipientName;
  final String recipientBank;
  final String recipientAccount;
  final double nominal;
  final String catatan;
  final String? transactionType;
  final String? transactionMethod;

  const SuccessScreen({
    super.key,
    required this.recipientName,
    required this.recipientBank,
    required this.recipientAccount,
    required this.nominal,
    required this.catatan,
    this.transactionType,
    this.transactionMethod,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  String _senderName = 'Kheyrun';
  String _sourceAccount = 'OCTO Savers (28727391854)';
  late final int _transactionId;

  // Key untuk ngukur posisi dashed line → cutout circles
  final GlobalKey _dashedLineKey = GlobalKey();
  // double _cutoutTop = 60; // fallback default

  @override
  void initState() {
    super.initState();
    _transactionId = 40 + Random().nextInt(60);
    _loadProfile();
    // Ukur posisi dashed line setelah frame pertama render
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureCutout());
  }

  void _measureCutout() {
    final ctx = _dashedLineKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    // posisi dashed line relatif terhadap Stack (card mulai di top: 35)
    final pos = box.localToGlobal(Offset.zero);
    final stackCtx = context;
    final stackBox = stackCtx.findRenderObject() as RenderBox?;
    if (stackBox == null) return;
    final stackPos = stackBox.localToGlobal(Offset.zero);
    // top cutout = posisi dashed line - posisi stack + margin card (35) - setengah circle (10)
    // if (mounted) setState(() => _cutoutTop = (pos.dy - stackPos.dy - 35 + 10).clamp(100, 400));
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _senderName = profile['full_name'] ?? 'Kheyrun';
        final acc = profile['account_number'] ?? '28727391854';
        _sourceAccount = 'OCTO Savers ($acc)';
      });
    }
  }

  String _formatRpCurrency(double amount) {
    int val = amount.toInt();
    String str = val.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  String getFormattedCurrentTime() {
    final now = DateTime.now();
    const months = {
      1: 'Januari',  2: 'Februari', 3: 'Maret',    4: 'April',
      5: 'Mei',      6: 'Juni',     7: 'Juli',      8: 'Agustus',
      9: 'September',10: 'Oktober', 11: 'November', 12: 'Desember',
    };
    final day    = now.day.toString();
    final month  = months[now.month] ?? now.month.toString();
    final year   = now.year.toString();
    final hour   = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$day $month $year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isTransfer   = widget.transactionType == 'transfer';
    final double fee   = isTransfer ? 2500.0 : 0.0;
    final double total = widget.nominal + fee;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/background/bg-screen.svg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/home-loggedin', (r) => false,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.close, color: Colors.white, size: 22),
                            SizedBox(width: 4),
                            Text('Tutup',
                              style: TextStyle(
                                color: Colors.white, fontSize: 20,
                                fontWeight: FontWeight.bold, fontFamily: 'Calibri',
                              )),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Berhasil membagikan bukti transaksi!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.share, color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text('Bagikan',
                              style: TextStyle(
                                color: Colors.white, fontSize: 20,
                                fontWeight: FontWeight.bold, fontFamily: 'Calibri',
                              )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Card area — tarik ke atas, tidak center ──────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // ── White card ───────────────────────────
                        Container(
                          margin: const EdgeInsets.only(top: 35),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 50),

                              const Text('Sukses!',
                                style: TextStyle(
                                  color: Color(0xFF84BD47), fontSize: 24,
                                  fontWeight: FontWeight.bold, fontFamily: 'Calibri',
                                )),
                              const SizedBox(height: 5),
                              Text('Transaksi Anda telah berhasil',
                                style: TextStyle(
                                  color: Colors.grey[500], fontSize: 17,
                                  fontFamily: 'Calibri',
                                )),
                              const SizedBox(height: 20),

                              // Dashed line — diberi key untuk mengukur posisinya
                              Padding(
                                key: _dashedLineKey,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: const _DashedLine(),
                              ),
                              const SizedBox(height: 20),

                              Image.asset('assets/octo/OctoMobile.png', height: 28),
                              const SizedBox(height: 20),

                              const Text('Nominal',
                                style: TextStyle(
                                  color: Colors.black, fontSize: 18,
                                  fontWeight: FontWeight.bold, fontFamily: 'Calibri',
                                )),
                              const SizedBox(height: 5),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontFamily: 'Calibri', color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Rp ',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                                    TextSpan(
                                      text: _formatRpCurrency(widget.nominal).replaceFirst('Rp ', ''),
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 35),

                              // Detail rows
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Column(
                                  children: [
                                    _buildRow(
                                      label: widget.transactionType == 'transfer'
                                          ? 'Penerima' : 'Pembayaran ke',
                                      value: widget.recipientName,
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _buildCol(
                                          label: 'Waktu Transaksi',
                                          value: getFormattedCurrentTime(),
                                        )),
                                        Expanded(child: _buildCol(
                                          label: 'ID Transaksi',
                                          value: _transactionId.toString(),
                                          alignRight: true,
                                        )),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    _buildRow(label: 'Dibayar oleh', value: _senderName),
                                    const SizedBox(height: 15),
                                    _buildRow(label: 'Rekening Sumber Dana', value: _sourceAccount),
                                    const SizedBox(height: 15),
                                    _buildRow(
                                      label: 'Total Pembayaran',
                                      value: _formatRpCurrency(total),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),

                        // ── Green check circle ───────────────────
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFF84BD47),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 36),
                          ),
                        ),

                        // // ── Cutout circles — posisi ngikutin dashed line ──
                        // Positioned(
                        //   left: -10,
                        //   top: _cutoutTop,
                        //   child: _CutoutCircle(),
                        // ),
                        // Positioned(
                        //   right: -10,
                        //   top: _cutoutTop,
                        //   child: _CutoutCircle(),
                        // ),
                      ],
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

  Widget _buildRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label,
            style: TextStyle(fontSize: 15, color: Colors.grey[500], fontFamily: 'Calibri')),
        ),
        Expanded(
          child: Text(value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: Colors.black, fontFamily: 'Calibri')),
        ),
      ],
    );
  }

  Widget _buildCol({
    required String label,
    required String value,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextStyle(fontSize: 15, color: Colors.grey[500], fontFamily: 'Calibri')),
        const SizedBox(height: 2),
        Text(value,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
            color: Colors.black, fontFamily: 'Calibri')),
      ],
    );
  }
}

// ── Dashed line ──────────────────────────────────────────────────
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth  = constraints.constrainWidth();
        const dashW     = 6.0;
        const dashH     = 1.2;
        const gap       = 4.0;
        final count     = (boxWidth / (dashW + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) => const SizedBox(
            width: dashW, height: dashH,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFFE2E2E6)),
            ),
          )),
        );
      },
    );
  }
}