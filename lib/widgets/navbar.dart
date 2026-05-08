import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────
class OctoBottomNavBar extends StatelessWidget {
  const OctoBottomNavBar({super.key, required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      color: Colors.white,
      elevation: 25,
      shadowColor: Colors.black87,
      clipper: const NavbarClipper(),
      child: SizedBox(
        height: 75, // Tinggi navbar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, 'Home', 'assets/icons/Home.svg', 'assets/icons/HomeActive.svg'),
                  _buildNavItem(1, 'My Account', 'assets/icons/MyAccount.svg', 'assets/icons/MyAccountActive.svg'),
                ],
              ),
            ),
            const SizedBox(width: 90), // Ruang tengah yang pas untuk tombol merah
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(2, 'Wealth','assets/icons/Wealth.svg', 'assets/icons/WealthActive.svg'),
                  _buildNavItem(3, 'Settings','assets/icons/Settings.svg', 'assets/icons/SettingsActive.svg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String inactiveIcon, String activeIcon) {
    final active = index == selected;
    final activeColor = const Color(0xFFF54A4D);
    final inactiveColor = Colors.grey.shade500;
    
    // Pilih icon berdasarkan state aktif/tidak
    final currentIcon = active ? activeIcon : inactiveIcon;

    return GestureDetector(
      onTap: () => onSelect(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Agar rapi di tengah
        children: [
          SvgPicture.asset(
            currentIcon,
            width: 22,
            height: 22,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? activeColor : inactiveColor,
              fontWeight: active ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM CLIPPER: MENCETAK BENTUK NAVBAR SECARA MANUAL (ANTI-BUG)
// ─────────────────────────────────────────────
class NavbarClipper extends CustomClipper<Path> {
  const NavbarClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final double cornerRadius = 30.0; // Lengkungan ujung kiri & kanan
    final double notchRadius = 42.0;  // Besarnya lubang tengah
    final double center = size.width / 2;

    // 1. Mulai dari ujung kiri atas (setelah lengkungan)
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0); // Lengkungan ujung kiri

    // 2. Garis lurus menuju bibir lubang
    path.lineTo(center - notchRadius - 15, 0);

    // 3. Bikin bibir lubang yang mulus menurun
    path.quadraticBezierTo(center - notchRadius, 0, center - notchRadius + 5, 10);

    // 4. Bikin mangkok setengah lingkaran (lubangnya)
    path.arcToPoint(
      Offset(center + notchRadius - 5, 10),
      radius: Radius.circular(notchRadius - 5),
      clockwise: false, // Memutar ke dalam
    );

    // 5. Bikin bibir lubang yang mulus naik kembali
    path.quadraticBezierTo(center + notchRadius, 0, center + notchRadius + 15, 0);

    // 6. Garis lurus menuju ujung kanan
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius); // Lengkungan ujung kanan

    // 7. Tutup bentuk kotaknya ke bawah
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────
// FAB QRIS (Pay)
// ─────────────────────────────────────────────
class QrisFab extends StatelessWidget {
  const QrisFab({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68, height: 68, // Ukuran FAB dibuat sedikit lebih besar
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: Colors.transparent, // Tembus pandang agar gradient container di bawahnya terlihat
        elevation: 6, // Memberi bayangan pada tombol melayang
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF980201),
            ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pay', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                SvgPicture.asset('assets/icons/QrisLogo.svg', height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
