import 'package:flutter/material.dart';

// ============================================================
// OCTO Mobile Banking - Home Screen
// ============================================================
// Struktur file ini:
//   1. OctoHomeScreen        — halaman utama (widget utama)
//   2. _TopBar               — bar atas dengan logo & ikon aksi
//   3. _LoginBanner          — banner "Login atau buat rekening"
//   4. _MenuTabs             — tab Untukmu / Transaksi / Produk / Lainnya
//   5. _MenuGrid             — grid ikon menu
//   6. _NewsSection          — section Berita & Promosi
//   7. _BottomNavBar         — navigasi bawah
//   8. OctoIcons             — placeholder icon (ganti dengan SVG eksport)
// ============================================================

void main() => runApp(const OctoApp());

class OctoApp extends StatelessWidget {
  const OctoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCTO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCC0000)),
        useMaterial3: true,
        fontFamily: 'Arial', // pastikan sudah didaftarkan di pubspec.yaml
      ),
      home: const OctoHomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// 1. HALAMAN UTAMA
// ─────────────────────────────────────────────
class OctoHomeScreen extends StatefulWidget {
  const OctoHomeScreen({super.key});

  @override
  State<OctoHomeScreen> createState() => _OctoHomeScreenState();
}

class _OctoHomeScreenState extends State<OctoHomeScreen> {
  int _selectedTab = 0;   // tab menu (Untukmu, Transaksi, dll)
  int _bottomNav  = 0;   // tab bottom nav

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background header merah
          Positioned(
            top: 0, left: 0, right: 0,
            height: 180,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCC0000), Color(0xFF990000)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                const _TopBar(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Sapaan
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Selamat siang, Apa Kabar?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Banner login — ketuk untuk ke halaman Login/Register
                        _LoginBanner(
                          onTap: () {
                            // ➡️ NAVIGASI KE HALAMAN LOGIN / REGISTER
                            // Uncomment salah satu sesuai flow aplikasi:
                            //
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (_) => const LoginPage(),
                            // ));
                            //
                            // atau dengan named route:
                            // Navigator.pushNamed(context, '/login');
                          },
                        ),

                        const SizedBox(height: 8),

                        // Card putih berisi tab + menu
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Tab bar
                              _MenuTabs(
                                selected: _selectedTab,
                                onSelect: (i) => setState(() => _selectedTab = i),
                              ),
                              const Divider(height: 1),

                              // Grid menu (konten berubah per tab)
                              _MenuGrid(tabIndex: _selectedTab),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section berita
                        const _NewsSection(),

                        // Ruang untuk FAB + bottom nav
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation (terletak di atas konten)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomNavBar(
              selected: _bottomNav,
              onSelect: (i) => setState(() => _bottomNav = i),
            ),
          ),

          // FAB Pay QRIS (tengah bottom)
          Positioned(
            bottom: 24,
            left: 0, right: 0,
            child: Center(
              child: _QrisFab(
                onTap: () {
                  // ➡️ NAVIGASI KE HALAMAN QRIS / PEMBAYARAN
                  // Navigator.pushNamed(context, '/qris');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2. TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo OCTO (icon placeholder — ganti dengan Image.asset('assets/octo_logo.svg'))
          const OctoLogo(),

          const Spacer(),

          // Ikon aksi kanan
          _IconBtn(icon: Icons.favorite_border, onTap: () {}),
          _IconBtn(icon: Icons.search,           onTap: () {}),
          _IconBtn(icon: Icons.notifications_outlined, onTap: () {}),
          _IconBtn(icon: Icons.logout,           onTap: () {}),

          const SizedBox(width: 6),

          // Avatar
          GestureDetector(
            onTap: () {
              // ➡️ NAVIGASI KE HALAMAN PROFIL
              // Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Container(
                  color: const Color(0xFFFFE4E4),
                  child: const Icon(Icons.person, color: Color(0xFFCC0000), size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 22),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ─────────────────────────────────────────────
// 3. BANNER LOGIN / REGISTER
// ─────────────────────────────────────────────
class _LoginBanner extends StatelessWidget {
  const _LoginBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ➡️ ke Login / Register
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Siap untuk menjelajah?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(text: 'Login ', style: TextStyle(color: Colors.black)),
                        TextSpan(text: 'atau ', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w400)),
                        TextSpan(text: 'buat rekening pertama', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCC0000), size: 28),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 4. TABS MENU
// ─────────────────────────────────────────────
class _MenuTabs extends StatelessWidget {
  const _MenuTabs({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  static const tabs = ['Untukmu', 'Transaksi', 'Produk', 'Lainnya'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: active
                    ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFCC0000), width: 2.5),
                        ),
                      )
                    : null,
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active ? const Color(0xFFCC0000) : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 5. GRID MENU
// ─────────────────────────────────────────────
class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.tabIndex});
  final int tabIndex;

  // Data menu per tab
  static const List<List<Map<String, dynamic>>> _menus = [
    // Tab 0: Untukmu
    [
      {'label': 'Transfer',            'icon': Icons.swap_horiz,         'route': '/transfer'},
      {'label': 'Tagihan &\nIsi Ulang', 'icon': Icons.receipt_long,       'route': '/tagihan'},
      {'label': 'Transaksi\nTanpa Kartu','icon': Icons.phone_android,     'route': '/tanpa-kartu'},
      {'label': 'Kartu\nElektronik',   'icon': Icons.credit_card,        'route': '/kartu'},
      {'label': 'Verify With\nOCTO',   'icon': Icons.verified_user,      'route': '/verify'},
      {'label': 'Jadwal Saya',         'icon': Icons.calendar_today,     'route': '/jadwal'},
      {'label': 'Investasi',           'icon': Icons.trending_up,        'route': '/investasi'},
      {'label': 'Kode Promo',          'icon': Icons.local_offer,        'route': '/promo'},
      {'label': 'Tabungan &\nDeposito','icon': Icons.savings,            'route': '/tabungan'},
    ],
    // Tab 1: Transaksi
    [
      {'label': 'Transfer',    'icon': Icons.swap_horiz,     'route': '/transfer'},
      {'label': 'Pembayaran',  'icon': Icons.payment,        'route': '/pembayaran'},
      {'label': 'Mutasi',      'icon': Icons.history,        'route': '/mutasi'},
      {'label': 'Top Up',      'icon': Icons.add_circle_outline, 'route': '/topup'},
    ],
    // Tab 2: Produk
    [
      {'label': 'Tabungan',    'icon': Icons.savings,         'route': '/tabungan'},
      {'label': 'Deposito',    'icon': Icons.account_balance, 'route': '/deposito'},
      {'label': 'Pinjaman',    'icon': Icons.attach_money,    'route': '/pinjaman'},
      {'label': 'Asuransi',    'icon': Icons.shield,          'route': '/asuransi'},
    ],
    // Tab 3: Lainnya
    [
      {'label': 'Lokasi ATM',  'icon': Icons.location_on,    'route': '/atm'},
      {'label': 'Bantuan',     'icon': Icons.help_outline,   'route': '/bantuan'},
      {'label': 'Pengaturan',  'icon': Icons.settings,       'route': '/settings'},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final items = _menus[tabIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 4,
          childAspectRatio: 0.72,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _MenuItem(
          label: items[i]['label'] as String,
          icon:  items[i]['icon']  as IconData,
          onTap: () {
            // ➡️ NAVIGASI KE HALAMAN MASING-MASING MENU
            // Setiap item memiliki 'route' yang bisa dipakai:
            // Navigator.pushNamed(context, items[i]['route'] as String);
            //
            // Contoh spesifik:
            // Transfer   → Navigator.pushNamed(context, '/transfer');
            // Tagihan    → Navigator.pushNamed(context, '/tagihan');
            // Investasi  → Navigator.pushNamed(context, '/investasi');
            // dst.
          },
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.label, required this.icon, required this.onTap});
  final String   label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFCC0000), size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 10, color: Colors.black87, height: 1.3),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 6. SECTION BERITA & PROMOSI
// ─────────────────────────────────────────────
class _NewsSection extends StatefulWidget {
  const _NewsSection();

  @override
  State<_NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<_NewsSection> {
  int _newsTab = 0;
  static const _tabs = ['Semua', 'Promosi', 'Berita'];

  // Dummy data artikel
  static const _articles = [
    {
      'title': 'SET UP SCHEDULED TRANSACTIONS\nIN OCTO APP',
      'subtitle': 'In the My Schedule menu, customers can create, edit, delete scheduled transaction details, and view them in a monthly calendar format.',
      'color': Color(0xFFCC0000),
    },
    {
      'title': 'PROMO CASHBACK 10%\nUNTUK TRANSFER',
      'subtitle': 'Nikmati cashback 10% untuk setiap transfer antar bank menggunakan OCTO Mobile.',
      'color': Color(0xFF880000),
    },
    {
      'title': 'FITUR BARU:\nKARTU VIRTUAL',
      'subtitle': 'Buat kartu virtual instan untuk transaksi online yang lebih aman dan mudah.',
      'color': Color(0xFF444444),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Berita & Promosi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),

        // Sub-tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final active = i == _newsTab;
              return GestureDetector(
                onTap: () => setState(() => _newsTab = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFCC0000) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? const Color(0xFFCC0000) : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal scroll kartu berita
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _articles.length,
            itemBuilder: (_, i) => _NewsCard(
              title:    _articles[i]['title']    as String,
              subtitle: _articles[i]['subtitle'] as String,
              color:    _articles[i]['color']    as Color,
              onTap: () {
                // ➡️ NAVIGASI KE HALAMAN DETAIL BERITA / PROMOSI
                // Navigator.pushNamed(context, '/berita/$i');
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 7. BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  static const _items = [
    {'icon': Icons.home,            'label': 'Home'},
    {'icon': Icons.account_circle,  'label': 'My Account'},
    {'icon': null,                  'label': ''},          // slot FAB tengah
    {'icon': Icons.trending_up,     'label': 'Wealth'},
    {'icon': Icons.settings,        'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          if (i == 2) return const Expanded(child: SizedBox()); // ruang FAB

          final item  = _items[i];
          final active = i == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onSelect(i);
                // ➡️ NAVIGASI BERDASARKAN TAB BOTTOM NAV
                // switch (i) {
                //   case 0: Navigator.pushNamed(context, '/home'); break;
                //   case 1: Navigator.pushNamed(context, '/account'); break;
                //   case 3: Navigator.pushNamed(context, '/wealth'); break;
                //   case 4: Navigator.pushNamed(context, '/settings'); break;
                // }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 22,
                    color: active
                        ? const Color(0xFFCC0000)
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: active
                          ? const Color(0xFFCC0000)
                          : Colors.grey.shade500,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FAB QRIS (Pay)
// ─────────────────────────────────────────────
class _QrisFab extends StatelessWidget {
  const _QrisFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64, height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF2020), Color(0xFFCC0000)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x66CC0000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Pay', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            Text('QRIS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 8. LOGO OCTO (Placeholder — ganti dengan SVG asset)
// ─────────────────────────────────────────────
// Cara mengganti:
//   1. Tambahkan file octo_logo.svg ke folder assets/
//   2. Daftarkan di pubspec.yaml:
//        flutter:
//          assets:
//            - assets/octo_logo.svg
//   3. Gunakan package flutter_svg:
//        SvgPicture.asset('assets/octo_logo.svg', height: 28)
// ─────────────────────────────────────────────
class OctoLogo extends StatelessWidget {
  const OctoLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder teks logo — ganti dengan SvgPicture.asset(...)
    return const Text(
      'OCTO',
      style: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}