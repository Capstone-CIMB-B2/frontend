import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'personalisasi_screen.dart';
import '../services/api_service.dart';
import '../services/auth_manager.dart';
import '../models/user.dart';

class UserProfile {
  final String name;
  final String? avatarUrl;

  const UserProfile({
    required this.name,
    this.avatarUrl,
  });
}

// MAIN SCREEN
// ─────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  final bool isLoggedIn;

  const SettingsScreen({
    super.key,
    this.isLoggedIn = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final data = await ApiService.getProfile();
      if (data != null && mounted) {
        setState(() => _user = UserModel.fromJson(data));
      }
    } catch (_) {
      // Gagal fetch, tetap tampil loading selesai
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar',
                style: TextStyle(
                    color: Color(0xFFD90002), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      // Hapus token dari local storage
      await AuthManager.clearToken();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OctoHomeScreen()),
          (_) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal logout. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const _SettingsHeader(),
                const SizedBox(height: 20),

                // Profile section
                widget.isLoggedIn
                    ? _ProfileLoggedIn(
                        user: _user,
                        isLoading: _isLoadingProfile,
                      )
                    : _ProfileGuest(
                        onLoginTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                      ),

                _SectionBlock(
                  iconPath: 'assets/icons/InformasiPribadi.svg',
                  label: 'Informasi Pribadi',
                  visible: widget.isLoggedIn,
                  items: [
                    _MenuItemData(
                      title: 'User ID & PIN OCTO',
                      subtitle: 'Ubah User ID & PIN OCTO Anda.',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Profil',
                      subtitle:
                          'Kelola KTP, nomor telepon, email, alamat, pendidikan, dan informasi pekerjaan.',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Personalisasi',
                      subtitle:
                          'Atur bagaimana kami menyesuaikan fitur dan promo berdasarkan kebutuhan Anda.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PersonalisasiScreen()),
                        );
                      },
                      badge: 'Baru',
                    ),
                  ],
                ),

                _SectionBlock(
                  iconPath: 'assets/icons/InformasiPribadi.svg',
                  label: 'Rekening & Transaksi',
                  visible: widget.isLoggedIn,
                  items: [
                    _MenuItemData(
                      title: 'Rekening Utama',
                      subtitle: 'Atur sumber dana utama untuk transaksi Anda.',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Transaksi Terjadwal',
                      subtitle:
                          'Jadwalkan transaksi Anda dan nikmati kemudahan pembayaran otomatis.',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Visibilitas Rekening',
                      subtitle:
                          'Pilih rekening mana yang ingin Anda tampilkan di layar beranda dan menu "Rekening Saya".',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Limit Transaksi Aplikasi OCTO',
                      subtitle: 'Atur batas harian untuk setiap jenis transaksi.',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Pengaturan Alias BI FAST',
                      subtitle:
                          'Buat atau ubah alias untuk transaksi BI FAST Anda.',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Verifikasi dengan OCTO',
                      subtitle:
                          'Verifikasi aktivitas finansial dan non-finansial dari saluran lain secara langsung melalui aplikasi OCTO.',
                      onTap: () {},
                    ),
                  ],
                ),

                _SectionBlock(
                  iconPath: 'assets/icons/InformasiPribadi.svg',
                  label: 'Notifikasi Aplikasi OCTO',
                  visible: widget.isLoggedIn,
                  items: [
                    _MenuItemData(
                      title: 'Kelola Notifikasi',
                      subtitle:
                          'Atur bagaimana Anda ingin menerima berita dan notifikasi.',
                      onTap: () {},
                    ),
                  ],
                ),

                _SectionBlock(
                  iconPath: 'assets/icons/InformasiPribadi.svg',
                  label: 'Tampilan & Lainnya',
                  visible: true,
                  items: [
                    _MenuItemData(
                      title: 'Tema',
                      subtitle: 'Default',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Tentang',
                      subtitle: 'Kebijakan privasi dan media sosial kami.',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Versi',
                      subtitle: '3.1.85',
                      onTap: () {},
                    ),
                    _MenuItemData(
                      title: 'Hapus Akses Aplikasi OCTO',
                      subtitle:
                          'Menghapus akses akun dari aplikasi di perangkat ini.',
                      onTap: () {},
                    ),
                  ],
                ),

                if (widget.isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _LogoutButton(onTap: _handleLogout),
                  ),
                ],

                const SizedBox(height: 120),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFD90002)),
              ),
            ),
        ],
      ),
    );
  }
}

// TOP BAR
// ─────────────────────────────────────────────
class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
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
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Pengaturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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

// PROFIL (SUDAH LOGIN)
// ─────────────────────────────────────────────
class _ProfileLoggedIn extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;
  final VoidCallback? onAvatarTap;

  const _ProfileLoggedIn({
    required this.user,
    this.isLoading = false,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 85,
          height: 85,
          child: Stack(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/octo/octo-profile.png',
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Nama
        isLoading || user == null
            ? Container(
                width: 140,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            : Text(
                user!.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.5,
                ),
              ),

        const SizedBox(height: 20),
      ],
    );
  }
}

// PROFIL (BELUM LOGIN)
// ─────────────────────────────────────────────
class _ProfileGuest extends StatelessWidget {
  final VoidCallback onLoginTap;
  const _ProfileGuest({required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset('assets/octo/octo-profile.png',
                fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: onLoginTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD90002), Color(0xFF9A0101)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCC0000).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Daftar atau Login',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _MenuItemData {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  const _MenuItemData({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });
}

// SECTION BLOCK
// ─────────────────────────────────────────────
class _SectionBlock extends StatelessWidget {
  final String iconPath;
  final String label;
  final List<_MenuItemData> items;
  final bool visible;

  const _SectionBlock({
    required this.iconPath,
    required this.label,
    required this.items,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(iconPath, width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF75767B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
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
            child: Column(
              children: List.generate(items.length, (i) {
                return Column(
                  children: [
                    _MenuTile(data: items[i]),
                    if (i < items.length - 1)
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF0F0F0)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// BARIS MENU
// ─────────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final _MenuItemData data;
  const _MenuTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (data.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD90002),
                                Color(0xFF9A0101)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            data.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: Color(0xFF980201), size: 22),
          ],
        ),
      ),
    );
  }
}

// TOMBOL KELUAR
// ─────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout,
                    color: Color(0xFFD90002), size: 18),
              ),
              const SizedBox(width: 14),
              const Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD90002),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}