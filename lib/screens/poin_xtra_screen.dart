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
                                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                                child: _buildPoinCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
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
                                                children: const [
                                                  Text(
                                                    'Total Poin Anda',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                      fontFamily: 'Calibri',
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '0 Points',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontFamily: 'Calibri',
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
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFFEBEE,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
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
                                                fontSize: 13,
                                                color: Colors.grey,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              '0 Points',
                                              style: TextStyle(
                                                fontSize: 13,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Calibri',
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Horizontal Menu Row (3 Items)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildMenuButton(
                                          label: 'Transfer\nPoin Xtra',
                                          icon: 'assets/icons/Transfer.svg',
                                        ),
                                        _buildMenuButton(
                                          label: 'Tagihan &\nIsi Ulang',
                                          icon: 'assets/icons/Tagihan.svg',
                                        ),
                                        _buildMenuButton(
                                          label: 'Penukaran\nLainnya',
                                          icon: 'assets/icons/Voucher.svg',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),

                                    // Segment / Tab Buttons (Terbaru & Riwayat)
                                    Container(
                                      height: 56,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F1F3),
                                        borderRadius: BorderRadius.circular(28),
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
                                    _buildPoinCard(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 40,
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons.folder_open_outlined,
                                              size: 120,
                                              color: Color(0xFFE5E5E5),
                                            ),
                                            const SizedBox(height: 24),
                                            const Text(
                                              'Belum ada transaksi',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Kumpulkan poin dan lakukan transaksi\nuntuk melihat riwayat disini.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                height: 1.5,
                                              ),
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
        width: 90,
        child: Column(
          children: [
            SvgPicture.asset(icon, width: 50, height: 50),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3C3C3C),
                height: 1.3,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFD90002), Color(0xFFAE0016)],
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
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
        borderRadius: BorderRadius.circular(24),
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
