import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InvestasiScreen extends StatefulWidget {
  const InvestasiScreen({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<InvestasiScreen> createState() => _InvestasiScreenState();
}

class _InvestasiScreenState extends State<InvestasiScreen> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. Fixed Background Image
            Positioned.fill(
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
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
            // 2. Safe Area Content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Navigation Bar (Fixed at top)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.onBack != null) {
                              widget.onBack!();
                            } else if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
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
                        const Expanded(
                          child: Text(
                            'Investasi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Stack(
                        children: [
                          // White background sheet that scrolls
                          Positioned(
                            top: 80,
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
                            ),
                          ),
                          // Content Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Total Nilai Investasi Card (Floating) ──
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                                child: _buildInvestasiCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Total Nilai Investasi',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () => setState(
                                                () => _balanceVisible =
                                                    !_balanceVisible,
                                              ),
                                              child: Icon(
                                                _balanceVisible
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                color: Colors.grey.shade600,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _balanceVisible ? 'Rp 0' : 'Rp ••••••',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                              child: const Text(
                                                '+ 0.00%',
                                                style: TextStyle(
                                                  color: Color(0xFF2E7D32),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'vs bulan lalu',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // ── Content inside the White Sheet ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Market Insight ──────────────────────────────
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Market Insight',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: const Text(
                                            'Lihat semua',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFCC0000),
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // News Banner Card
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          'assets/banner/getwealthsoon.jpg',
                                          fit: BoxFit.cover,
                                          height: 135,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // ── Produk Investasi ────────────────────────────
                                    const Text(
                                      'Produk Investasi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Calibri',
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Mulai berinvestasi dengan salah satu produk kami.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontFamily: 'Calibri',
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // 2x2 Grid of Product Cards
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildProductCard(
                                                title: 'Reksa Dana',
                                                desc:
                                                    'Investasi dana yang dikelola profesional.',
                                                icon: 'assets/icons/Statement.svg',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildProductCard(
                                                title: 'SBN Ritel',
                                                desc:
                                                    'Obligasi pemerintah dengan imbal hasil stabil.',
                                                icon: 'assets/icons/Statement.svg',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildProductCard(
                                                title: 'Obligasi Sekunder',
                                                desc:
                                                    'Obligasi pemerintah di pasar sekunder.',
                                                icon: 'assets/icons/Statement.svg',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildProductCard(
                                                title: 'Tabungan Emas',
                                                desc: 'Menabung emas dengan mudah.',
                                                icon: 'assets/icons/Statement.svg',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // ── Rekomendasi Untuk Anda ──────────────────────
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Rekomendasi Untuk Anda',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: const Text(
                                            'Lihat semua',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFCC0000),
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Recommendation Card
                                    _buildInvestasiCard(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ── Row 1: Icon + Title ─────────────────
                                            Row(
                                              children: [
                                                Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFD90002),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: const EdgeInsets.all(8),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/Wealth.svg',
                                                    colorFilter: const ColorFilter.mode(
                                                      Colors.white,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Expanded(
                                                  child: Text(
                                                    'Reksa Dana Pendapatan Tetap',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                      fontFamily: 'Calibri',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 14),

                                            // ── Row 2: Badge + Return + Sparkline + Button ──
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Risk Badge
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE8F5E9),
                                                    borderRadius: BorderRadius.circular(
                                                      6,
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Rendah - Menengah',
                                                    style: TextStyle(
                                                      color: Color(0xFF2E7D32),
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Calibri',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),

                                                // Return info
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Text(
                                                      'Return 1Y',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                        fontFamily: 'Calibri',
                                                      ),
                                                    ),
                                                    SizedBox(height: 1),
                                                    Text(
                                                      '+4.25%',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF2E7D32),
                                                        fontFamily: 'Calibri',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),

                                                // Sparkline
                                                SizedBox(
                                                  width: 55,
                                                  height: 28,
                                                  child: CustomPaint(
                                                    painter: SparklinePainter(),
                                                  ),
                                                ),

                                                const Spacer(),

                                                // Invest Button
                                                Container(
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(
                                                      18,
                                                    ),
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Color(0xFFCC0000),
                                                        Color(0xFF8C0E1A),
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ),
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () {},
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.transparent,
                                                      shadowColor: Colors.transparent,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(18),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Invest',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                        fontFamily: 'Calibri',
                                                        ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String desc,
    required String icon,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(icon, width: 22, height: 26),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Calibri',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Calibri',
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvestasiCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: child,
    );
  }
}

class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.80);
    path.quadraticBezierTo(
      size.width * 0.20,
      size.height * 0.85,
      size.width * 0.40,
      size.height * 0.50,
    );
    path.quadraticBezierTo(
      size.width * 0.60,
      size.height * 0.15,
      size.width * 0.80,
      size.height * 0.20,
    );
    path.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.18,
      size.width,
      size.height * 0.10,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
