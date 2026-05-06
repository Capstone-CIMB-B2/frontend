import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/navbar.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../widgets/personalization_banner.dart';
import 'personalisasi_screen.dart';
import '../services/api_service.dart';

// DUMMY DATA
// ─────────────────────────────────────────────
class DummyUser {
  static const String name = 'Lee Sangwon';
  static const String userId = 'sangwon99';
  static const String accountNumber = '••••1854';
  static const double ewalletBalance = 2_450_000;
  static const double savingsBalance = 18_750_500;
  static const String profileImage = 'assets/octo/octo-profile.png';
}

// HELPER
// ─────────────────────────────────────────────
String formatCurrency(double amount) {
  return 'IDR ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

// HOME SCREEN (BELUM LOGIN)
// ─────────────────────────────────────────────

class OctoHomeScreen extends StatefulWidget {
  const OctoHomeScreen({super.key});

  @override
  State<OctoHomeScreen> createState() => _OctoHomeScreenState();
}

class _OctoHomeScreenState extends State<OctoHomeScreen> {
  int _bottomNav = 0;

  void changeTab(int index) => setState(() => _bottomNav = index);

  final List<Widget> _pages = const [
    _HomeContent(),
    Center(child: Text('Halaman My Account')),
    Center(child: Text('Halaman Wealth')),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: QrisFab(onTap: () {}),
      bottomNavigationBar: OctoBottomNavBar(
        selected: _bottomNav,
        onSelect: (i) {
          if (i == 1 || i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          } else {
            setState(() => _bottomNav = i);
          }
        },
      ),
      body: IndexedStack(index: _bottomNav, children: _pages),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              SizedBox(
                height: 280,
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
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Selamat siang, ',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: 'Apa Kabar?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Positioned(
                            top: 50,
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
                          Column(
                            children: [
                              _LoginBanner(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _MenuTabs(
                                selected: _selectedTab,
                                onSelect: (i) =>
                                    setState(() => _selectedTab = i),
                              ),
                              _MenuGrid(
                                tabIndex: _selectedTab,
                                isLoggedIn: false,
                              ),
                              const SizedBox(height: 24),
                              const _NewsSection(),
                              const SizedBox(height: 100),
                            ],
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
    );
  }
}

// HEADER (BELUM LOGIN)
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const OctoLogo(),
          const Spacer(),
          _IconBtn(svgPath: 'assets/icon-search.svg', onTap: () {}),
          _IconBtn(svgPath: 'assets/icon-notification.svg', onTap: () {}),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => context
                .findAncestorStateOfType<_OctoHomeScreenState>()
                ?.changeTab(3),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage('assets/octo/octo-profile.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BANNER (BELUM LOGIN)
// ─────────────────────────────────────────────
class _LoginBanner extends StatelessWidget {
  const _LoginBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 80,
                right: 16,
                top: 25,
                bottom: 25,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFEFFFF), Color(0xFFFFCECF)],
                ),
                borderRadius: BorderRadius.circular(16),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siap untuk menjelajah?',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Login atau buat rekening pertama',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFCC0000),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Image.asset(
                'assets/octo/octo-homepage.png',
                height: 85,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HOME SCREEN (SUDAH LOGIN)
// ─────────────────────────────────────────────
class OctoHomeScreenLoggedIn extends StatefulWidget {
  const OctoHomeScreenLoggedIn({super.key});

  @override
  State<OctoHomeScreenLoggedIn> createState() => _OctoHomeScreenLoggedInState();
}

class _OctoHomeScreenLoggedInState extends State<OctoHomeScreenLoggedIn> {
  int _bottomNav = 0;

  void changeTab(int index) => setState(() => _bottomNav = index);

  final List<Widget> _pages = const [
    _HomeContentLoggedIn(),
    Center(child: Text('Halaman My Account')),
    Center(child: Text('Halaman Wealth')),
    SettingsScreen(
      isLoggedIn: true,
      profile: UserProfile(
        name: DummyUser.name,
        userId: DummyUser.userId,
        avatarUrl: null,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: QrisFab(onTap: () {}),
      bottomNavigationBar: OctoBottomNavBar(
        selected: _bottomNav,
        onSelect: (i) => setState(() => _bottomNav = i),
      ),
      body: IndexedStack(index: _bottomNav, children: _pages),
    );
  }
}

class _HomeContentLoggedIn extends StatefulWidget {
  const _HomeContentLoggedIn();

  @override
  State<_HomeContentLoggedIn> createState() => _HomeContentLoggedInState();
}

class _HomeContentLoggedInState extends State<_HomeContentLoggedIn> {
  int _selectedTab = 0;
  bool _balanceVisible = false;

    String _userName = '...';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isPersonalizationEnabledNotifier.value) {
        _showPersonalizationDialog();
      }
    });
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (profile != null && mounted) {
      setState(() => _userName = profile['full_name'] ?? '-');
    }
  }


  void _showPersonalizationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/octo/octo-profile.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Personalisasi Pengalaman Anda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kami ingin memberikan layanan yang lebih relevan untuk Anda. Dengan menyetujui pembagian data, kami dapat menampilkan promo dan insight yang disesuaikan dengan kebutuhan Anda. Anda dapat mengubah pilihan ini kapan saja di pengaturan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    isPersonalizationEnabledNotifier.value = true;
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD90002), Color(0xFF9A0101)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Ya, Saya Setuju',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Nanti Saja',
                    style: TextStyle(
                      color: Color(0xFFD90002),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
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
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBarLoggedIn(
                onAvatarTap: () => context
                    .findAncestorStateOfType<_OctoHomeScreenLoggedInState>()
                    ?.changeTab(3),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Selamat siang, ',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: '${_userName.toUpperCase()}!',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
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
                          Column(
                            children: [
                              _AccountCard(
                                balanceVisible: _balanceVisible,
                                onToggleBalance: () => setState(
                                  () => _balanceVisible = !_balanceVisible,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _NotifBanner(),
                              const SizedBox(height: 8),
                              const PersonalizationBanner(),
                              const SizedBox(height: 8),
                              _MenuTabs(
                                selected: _selectedTab,
                                onSelect: (i) =>
                                    setState(() => _selectedTab = i),
                              ),
                              _MenuGrid(
                                tabIndex: _selectedTab,
                                isLoggedIn: true,
                              ),
                              const SizedBox(height: 24),
                              _EWalletSection(balanceVisible: _balanceVisible),
                              const SizedBox(height: 24),
                              const _NewsSection(),
                              const SizedBox(height: 100),
                            ],
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
    );
  }
}

// TOP BAR (SUDAH LOGIN)
// ─────────────────────────────────────────────
class _TopBarLoggedIn extends StatelessWidget {
  const _TopBarLoggedIn({required this.onAvatarTap});
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const OctoLogo(),
          const Spacer(),
          _IconBtn(svgPath: 'assets/icon-wishlist.svg', onTap: () {}),
          _IconBtn(svgPath: 'assets/icon-search.svg', onTap: () {}),
          _IconBtn(svgPath: 'assets/icon-notification.svg', onTap: () {}),
          _IconBtn(
            svgPath: 'assets/icon-logout.svg',
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Keluar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    'Apakah Anda yakin ingin keluar dari aplikasi?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: Color(0xFFD90002),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const OctoHomeScreen()),
                  (_) => false,
                );
              }
            },
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage(DummyUser.profileImage),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ACCOUNT CARD (SUDAH LOGIN)
// ─────────────────────────────────────────────
class _AccountCard extends StatefulWidget {
  const _AccountCard({
    required this.balanceVisible,
    required this.onToggleBalance,
  });
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _cards = [
    {
      'type': 'E-Wallet',
      'badgeColor': Color(0xFF1A5C4A),
      'name': 'OCTO Pay',
      'accountMasked': '(••••1854)',
      'accountFull': '(5271 8321 0012 1854)',
      'balance': DummyUser.ewalletBalance,
    },
    {
      'type': 'Tabungan',
      'badgeColor': Color(0xFF4A0000),
      'name': 'TabunganKu',
      'accountMasked': '(••••9201)',
      'accountFull': '(800 234 5678 9201)',
      'balance': DummyUser.savingsBalance,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final card = _cards[index];
              final accountDisplay = widget.balanceVisible
                  ? card['accountFull'] as String
                  : card['accountMasked'] as String;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: card['badgeColor'] as Color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              card['type'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Nama & No Rek
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${card['name']} $accountDisplay',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.copy_outlined,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Saldo
                          Row(
                            children: [
                              GestureDetector(
                                onTap: widget.onToggleBalance,
                                child: Icon(
                                  widget.balanceVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.balanceVisible
                                    ? formatCurrency(card['balance'] as double)
                                    : 'IDR •••',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Tombol Top Up
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B0000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Top Up',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Dot indicator
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_cards.length, (i) {
            return Container(
              width: _currentPage == i ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? const Color(0xFF7B0000)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// NOTIF BANNER
// ─────────────────────────────────────────────
class _NotifBanner extends StatefulWidget {
  const _NotifBanner();

  @override
  State<_NotifBanner> createState() => _NotifBannerState();
}

class _NotifBannerState extends State<_NotifBanner> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3F3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.info_outline,
                color: Color(0xFF7B0000),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIMB Niaga Introducing, OCTO! 🥳',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'OCTO Mobile and OCTO Cliks are now OCTO, enjoy an even easier transaction experience',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _visible = false),
            child: const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.close, size: 18, color: Color(0xFF7B0000)),
            ),
          ),
        ],
      ),
    );
  }
}

// E-WALLET SECTION
// ─────────────────────────────────────────────
class _EWalletSection extends StatelessWidget {
  const _EWalletSection({required this.balanceVisible});
  final bool balanceVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'e-Wallet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Octopay
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/octo/octopay-logo.svg',
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'OCTO Pay',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white, // solid putih
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // ← lebih besar biar keliatan rounded
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 20,
                                color: Color(0xFF7B0000),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye_outlined,
                              size: 18,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              balanceVisible
                                  ? 'IDR ${formatCurrency(DummyUser.ewalletBalance)}'
                                  : 'IDR •••',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Card Gopay
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFFFFFFF), Color(0xFFDDDBDE)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GoPay row
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/gopay-logo.svg',
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'gopay',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Connect button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B0000),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(0, 28),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                            ),
                            child: const Text(
                              'Connect',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
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
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SHARED WIDGETS
// ================================================================

// ─────────────────────────────────────────────
// LOGO
// ─────────────────────────────────────────────
class OctoLogo extends StatelessWidget {
  const OctoLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/octo/octo-logo.svg',
      height: 20,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }
}

// ICON BUTTON
// ─────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.svgPath, required this.onTap});
  final String svgPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: SvgPicture.asset(
          svgPath,
          width: 30,
          height: 30,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}

// TABS MENU
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
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: active
                    ? BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(25),
                      )
                    : null,
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: active
                        ? const Color(0xFF800000)
                        : const Color(0xFFB0B0B0),
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

// GRID MENU
// ─────────────────────────────────────────────
class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.tabIndex, required this.isLoggedIn});
  final int tabIndex;
  final bool isLoggedIn;

  static const List<List<Map<String, dynamic>>> _menus = [
    // Section 1: Untukmu
    [
      {'label': 'Transfer', 'icon': 'assets/icons/Transfer.svg'},
      {'label': 'Tagihan &\nIsi Ulang', 'icon': 'assets/icons/Tagihan.svg'},
      {
        'label': 'Transaksi\nTanpa Kartu',
        'icon': 'assets/icons/TransaksiTanpaKartu.svg',
      },
      {
        'label': 'Kartu\nElektronik',
        'icon': 'assets/icons/KartuElektronik.svg',
      },
      {'label': 'Verify With\nOCTO', 'icon': 'assets/icons/VerifyWithOcto.svg'},
      {'label': 'Jadwal Saya', 'icon': 'assets/icons/JadwalSaya.svg'},
      {'label': 'Investasi', 'icon': 'assets/icons/investasi.svg'},
      {'label': 'Kode Promo', 'icon': 'assets/icons/KodePromo.svg'},
      {
        'label': 'Tabungan &\nDeposito',
        'icon': 'assets/icons/TabunganDeposito.svg',
      },
    ],
    // Section 2: Transaksi
    [
      {'label': 'Transfer', 'icon': 'assets/icons/Transfer.svg'},
      {'label': 'Tagihan &\nIsi Ulang', 'icon': 'assets/icons/Tagihan.svg'},
      {
        'label': 'Transaksi\nTanpa Kartu',
        'icon': 'assets/icons/TransaksiTanpaKartu.svg',
      },
      {'label': 'QRIS Tap', 'icon': 'assets/icons/QrisTap.svg'},
      {'label': 'Poin Xtra', 'icon': 'assets/icons/PoinXtra.svg'},
      {'label': 'Jadwal Saya', 'icon': 'assets/icons/JadwalSaya.svg'},
      {
        'label': 'Kartu\nElektronik',
        'icon': 'assets/icons/KartuElektronik.svg',
      },
      {'label': 'Voucher', 'icon': 'assets/icons/Voucher.svg'},
      {
        'label': 'Ringkasan Cicilan',
        'icon': 'assets/icons/RingkasanCicilan.svg',
      },
      {'label': 'Pembayaran\nNFC', 'icon': 'assets/icons/PembayaranNFC.svg'},
    ],
    // Section 3: Produk
    [
      {'label': 'Investasi', 'icon': 'assets/icons/investasi.svg'},
      {
        'label': 'Tabungan &\nDeposito',
        'icon': 'assets/icons/TabunganDeposito.svg',
      },
      {
        'label': 'Pinjaman &\nKartu Kredit',
        'icon': 'assets/icons/PinjamanKredit.svg',
      },
    ],
    // Section 4: Lainnya
    [
      {
        'label': 'Pengaturan\nKartu',
        'icon': 'assets/icons/PengaturanKartu.svg',
      },
      {'label': 'Lokasi', 'icon': 'assets/icons/Lokasi.svg'},
      {'label': 'Promosi', 'icon': 'assets/icons/Promosi.svg'},
      {'label': 'Nilai Tukar', 'icon': 'assets/icons/NilaiTukar.svg'},
      {'label': 'Travel Concierge', 'icon': 'assets/icons/TravelConcierge.svg'},
      {'label': 'Pesanan Saya', 'icon': 'assets/icons/PesananSaya.svg'},
      {'label': 'Preferensi', 'icon': 'assets/icons/Preverensi.svg'},
      {'label': 'Kode Promo', 'icon': 'assets/icons/KodePromo.svg'},
      {'label': 'Verify With\nOCTO', 'icon': 'assets/icons/VerifyWithOcto.svg'},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(_menus[tabIndex]);

    if (isLoggedIn && tabIndex == 0) {
      items.add({'label': 'Adjust\nFavorite', 'icon': null, 'isAdjust': true});
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 5;
          return Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 195),
            child: Wrap(
              alignment: WrapAlignment.start,
              runSpacing: 16,
              children: items.map((item) {
                return SizedBox(
                  width: itemWidth,
                  child: item['isAdjust'] == true
                      ? _AdjustFavoriteItem(onTap: () {})
                      : _MenuItem(
                          label: item['label'] as String,
                          icon: item['icon'] as String,
                          onTap: () {},
                        ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Center(child: SvgPicture.asset(icon, width: 42, height: 42)),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjustFavoriteItem extends StatelessWidget {
  const _AdjustFavoriteItem({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE0E0),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.tune_rounded,
                color: Color(0xFF7B0000),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjust\nFavorite',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7B0000),
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// BERITA & PROMOSI
// ─────────────────────────────────────────────
class _NewsSection extends StatefulWidget {
  const _NewsSection();

  @override
  State<_NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<_NewsSection> {
  int _newsTab = 0;
  static const _tabs = ['Semua', 'Promosi', 'Berita'];
  static const _articles = [
    {'image': 'assets/banner/Berita1.png', 'type': 'Berita'},
    {'image': 'assets/banner/Berita2.png', 'type': 'Berita'},
    {'image': 'assets/banner/Berita3.png', 'type': 'Berita'},
    {'image': 'assets/banner/Promosi1.png', 'type': 'Promosi'},
  ];

  @override
  Widget build(BuildContext context) {
    final activeTabName = _tabs[_newsTab];
    final filtered = _articles
        .where((a) => activeTabName == 'Semua' || a['type'] == activeTabName)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Berita & Promosi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final active = i == _newsTab;
              return GestureDetector(
                onTap: () => setState(() => _newsTab = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: active
                      ? BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(25),
                        )
                      : null,
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                      color: active
                          ? const Color(0xFF800000)
                          : const Color(0xFFB0B0B0),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: ListView.builder(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () {},
              child: Container(
                width: 348,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    filtered[i]['image'] as String,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
