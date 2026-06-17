import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PoinXtraScreen extends StatefulWidget {
  const PoinXtraScreen({super.key});

  @override
  State<PoinXtraScreen> createState() => _PoinXtraScreenState();
}

class _PoinXtraScreenState extends State<PoinXtraScreen> {
  int _selectedTab = 0; // 0: Terbaru, 1: Riwayat

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: Stack(
          children: [
            // 1. Red Curved Header Background (fixed)
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
                        const Expanded(
                          child: Text(
                            'Poin Xtra',
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
                              // Total Poin Anda Card
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  10,
                                  18,
                                  0,
                                ),
                                child: _buildPoinCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Total Poin Anda',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                      fontFamily: 'Calibri',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  RichText(
                                                    text: const TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: '0 Points',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Custom Giftbox & Coin Illustration
                                            SizedBox(
                                              width: 54,
                                              height: 54,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Gift box silhouette
                                                  Container(
                                                    width: 42,
                                                    height: 42,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFFFFEBEE,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.card_giftcard,
                                                      color: Color(0xFFD90002),
                                                      size: 28,
                                                    ),
                                                  ),
                                                  // Gold coin labeled 'P'
                                                  Positioned(
                                                    bottom: 2,
                                                    right: 2,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFFFD54F,
                                                        ),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 1.5,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  1,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Text(
                                                        'P',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0xFF8D6E63,
                                                          ),
                                                          fontFamily: 'Calibri',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                          ),
                                          child: Divider(
                                            color: Colors.grey.shade200,
                                            thickness: 1,
                                            height: 1,
                                          ),
                                        ),
                                        Row(
                                          children: const [
                                            Text(
                                              'Poin didapat bulan ini',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              '0 Points',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Remaining contents padded horizontally
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Menu Utama Section Title
                                    const Text(
                                      'Menu Utama',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Calibri',
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Horizontal Menu Row (3 Items)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        _buildMenuButton(
                                          label: 'Transfer\nPoin Xtra',
                                          icon: 'assets/icons/Transfer.svg',
                                        ),
                                        const SizedBox(width: 12),
                                        _buildMenuButton(
                                          label: 'Tagihan &\nIsi Ulang',
                                          icon: 'assets/icons/Tagihan.svg',
                                        ),
                                        const SizedBox(width: 12),
                                        _buildMenuButton(
                                          label: 'Penukaran\nLainnya',
                                          icon: 'assets/icons/Voucher.svg',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),

                                    // Segment / Tab Buttons (Terbaru & Riwayat)
                                    Container(
                                      height: 46,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F1F3),
                                        borderRadius: BorderRadius.circular(23),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildTabButton(
                                            label: 'Terbaru',
                                            isActive: _selectedTab == 0,
                                            onTap: () => setState(
                                              () => _selectedTab = 0,
                                            ),
                                          ),
                                          _buildTabButton(
                                            label: 'Riwayat',
                                            isActive: _selectedTab == 1,
                                            onTap: () => setState(
                                              () => _selectedTab = 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Transaction / Empty State Content Card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 32,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFF0F0F2),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.03),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/icons/Kosong.png',
                                            width: 130,
                                            height: 130,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _selectedTab == 0
                                                ? 'Belum ada aktivitas'
                                                : 'Belum ada transaksi',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontFamily: 'Calibri',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _selectedTab == 0
                                                ? 'Aktivitas terbaru Anda akan muncul di sini.'
                                                : 'Kumpulkan poin dan lakukan transaksi\nuntuk melihat riwayat di sini.',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                              fontFamily: 'Calibri',
                                              height: 1.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
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

  Widget _buildMenuButton({required String label, required String icon}) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: SvgPicture.asset(icon, width: 42, height: 42),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.2,
                fontFamily: 'Calibri',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFCC0000), Color(0xFF8C0E1A)],
                  )
                : null,
            color: isActive ? null : const Color(0xFFF3F3F3),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              fontFamily: 'Calibri',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoinCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
