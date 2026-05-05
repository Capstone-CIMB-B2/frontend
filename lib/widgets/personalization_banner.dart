import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/personalisasi_screen.dart';

class _PromoData {
  final String text;
  final String actionText;
  const _PromoData(this.text, this.actionText);
}

const _dummyPromos = [
  _PromoData('Kamu sering bayar tagihan Shopee akhir akhir ini. Tahu nggak kalau poin yang kamu kumpulkan bisa dipakai buat bayar tagihan berikutnya?', 'Cek sisa Poin Xtra '),
  _PromoData('Dapatkan cashback 50% untuk pembelian tiket nonton bioskop menggunakan OCTO Pay di akhir pekan!', 'Lihat Promo '),
  _PromoData('Reksa dana pasar uang sedang naik daun. Yuk mulai investasi pertamamu mulai dari Rp 10.000!', 'Mulai Investasi '),
];

class PersonalizationBanner extends StatefulWidget {
  const PersonalizationBanner({super.key});

  @override
  State<PersonalizationBanner> createState() => _PersonalizationBannerState();
}

class _PersonalizationBannerState extends State<PersonalizationBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPersonalizationEnabledNotifier,
      builder: (context, isEnabled, child) {
        if (!isEnabled) {
          // Tampilan awal (belum aktif)
          return Column(
            children: [
              _buildCard(
                text: 'Nikmati pengalaman lebih personal. Bagikan preferensi mu biar rekomendasi makin sesuai! ✨',
                actionText: 'Atur Sekarang ',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PersonalisasiScreen()),
                  );
                },
              ),
            ],
          );
        }

        // Tampilan sudah aktif (carousel)
        return Column(
          children: [
            SizedBox(
              height: 130,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _dummyPromos.length,
                itemBuilder: (context, index) {
                  final promo = _dummyPromos[index];
                  return _buildCard(
                    text: promo.text,
                    actionText: promo.actionText,
                    onTap: () {
                      // TODO: Navigate to specific feature
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_dummyPromos.length, (i) {
                return Container(
                  width: _currentPage == i ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Colors.grey[400] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String text,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: const Color(0xFFFFF9EC), // Soft yellow/cream background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3E5D8)), // Soft pinkish border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, right: 14),
            child: SvgPicture.asset(
              'assets/icons/PersonalizationBanner.svg',
              width: 30,
              height: 30,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    children: [
                      Text(
                        actionText.trim(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD90002),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Color(0xFFD90002),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
