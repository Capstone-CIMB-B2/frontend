import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final ValueNotifier<bool> isPersonalizationEnabledNotifier = ValueNotifier<bool>(false);

class PersonalisasiScreen extends StatefulWidget {
  const PersonalisasiScreen({super.key});

  @override
  State<PersonalisasiScreen> createState() => _PersonalisasiScreenState();
}

class _PersonalisasiScreenState extends State<PersonalisasiScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          const _PersonalisasiHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildToggleCard(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktifkan Personalisasi?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dapatkan rekomendasi yang lebih sesuai untuk Anda',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: isPersonalizationEnabledNotifier.value,
            onChanged: (val) {
              setState(() {
                isPersonalizationEnabledNotifier.value = val;
              });
            },
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFD90002),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Untuk memberikan pengalaman mobile banking yang lebih relevan dan membantu Anda mengelola keuangan dengan lebih baik, kami menggunakan beberapa data aktivitas Anda. Kami hanya menggunakan data dengan izin Anda, dan Anda dapat mengatur atau mencabut persetujuan kapan saja.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.25,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Data yang Digunakan'),
          _buildBulletPoint('Riwayat transaksi (transfer, pembayaran, pembelian)'),
          _buildBulletPoint('Frekuensi penggunaan fitur (QRIS, top-up, dll)'),
          _buildBulletPoint('Interaksi dalam aplikasi (klik menu, fitur yang sering digunakan)'),
          _buildBulletPoint('Informasi profil dasar (usia, pekerjaan)'),
          const SizedBox(height: 20),
          _buildSectionTitle('Tujuan Penggunaan Data'),
          _buildBulletPoint('Menampilkan rekomendasi fitur yang relevan'),
          _buildBulletPoint('Memberikan insight pengeluaran dan kebiasaan finansial'),
          _buildBulletPoint('Menyusun tampilan menu yang sesuai dengan kebutuhan Anda'),
          _buildBulletPoint('Menampilkan promo dan penawaran yang lebih tepat sasaran'),
          const SizedBox(height: 20),
          _buildSectionTitle('Privasi Anda'),
          _buildBulletPoint('Data Anda tidak akan dibagikan ke pihak ketiga tanpa izin'),
          _buildBulletPoint('Anda dapat menonaktifkan personalisasi kapan saja'),
          _buildBulletPoint('Kami menjaga keamanan data sesuai standar perlindungan data'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10, left: 4),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalisasiHeader extends StatelessWidget {
  const _PersonalisasiHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100, // Slightly taller to match other headers
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
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
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Personalisasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // Balance the title centering
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
