import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/navbar.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../widgets/personalization_banner.dart';
import 'personalisasi_screen.dart';
import '../services/api_service.dart';
import '../models/transaction_response.dart';
import 'riwayat_transaksi_screen.dart';

String formatCurrency(double amount) {
  return 'IDR ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

String formatRpCurrency(double amount) {
  int val = amount.toInt();
  String str = val.toString();
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return 'Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
}

String formatTrxDateTime(String timestamp) {
  try {
    final cleanTs = timestamp.replaceAll('T', ' ');
    final parts = cleanTs.split(' ');
    final datePart = parts[0];
    final timePart = parts.length > 1 ? parts[1] : '';

    final dateSplit = datePart.split('-');
    if (dateSplit.length == 3) {
      final year = dateSplit[0];
      final monthNum = dateSplit[1];
      final day = int.parse(dateSplit[2]).toString();

      const months = {
        '01': 'Jun', '02': 'Feb', '03': 'Mar', '04': 'Apr',
        '05': 'Mei', '06': 'Jun', '07': 'Jul', '08': 'Agu',
        '09': 'Sep', '10': 'Okt', '11': 'Nov', '12': 'Des'
      };
      final monthName = months[monthNum] ?? monthNum;

      String formattedTime = '';
      if (timePart.isNotEmpty) {
        final timeSplit = timePart.split(':');
        if (timeSplit.length >= 2) {
          formattedTime = ', ${timeSplit[0]}:${timeSplit[1]}';
        }
      }
      return '$day $monthName $year$formattedTime';
    }
  } catch (_) {}
  return timestamp;
}

String getTransactionDisplayTitle(TransactionResponse trx) {
  final method = trx.transactionMethod.toLowerCase();
  final cat = trx.category.toLowerCase();
  if (method == 'qris' || cat == 'qris') {
    return 'Pembayaran QRIS';
  } else if (method == 'top up' || method == 'topup' || cat == 'e-wallet' || cat == 'wallet') {
    return 'Top Up E-Wallet';
  } else if (method == 'transfer') {
    return 'Transfer';
  } else if (method == 'pembelian pulsa') {
    return 'Pembelian Pulsa';
  } else if (method == 'bayar tagihan') {
    return 'Pembayaran Tagihan';
  }
  return trx.transactionMethod.isNotEmpty ? trx.transactionMethod : 'Transaksi';
}

String getTransactionDisplaySubtitle(TransactionResponse trx) {
  final method = trx.transactionMethod.toLowerCase();
  final cat = trx.category.toLowerCase();
  if (method == 'transfer') {
    final bank = trx.recipientBank ?? 'CIMB NIAGA';
    final acc = trx.recipientAccount ?? '';
    return acc.isNotEmpty ? '$bank • $acc' : bank;
  } else if (method == 'top up' || method == 'topup' || cat == 'e-wallet' || cat == 'wallet') {
    final merchant = trx.merchantName;
    final acc = trx.recipientAccount ?? '';
    return acc.isNotEmpty ? '$merchant - $acc' : merchant;
  }
  return trx.merchantName;
}

IconData getTransactionIcon(TransactionResponse trx) {
  final method = trx.transactionMethod.toLowerCase();
  final cat = trx.category.toLowerCase();
  if (method == 'qris' || cat == 'qris') {
    return Icons.qr_code_scanner;
  } else if (method == 'top up' || method == 'topup' || cat == 'e-wallet' || cat == 'wallet') {
    return Icons.account_balance_wallet;
  } else if (method == 'transfer') {
    return Icons.swap_horiz;
  } else if (method == 'pembelian pulsa') {
    return Icons.phone_android;
  } else if (method == 'bayar tagihan') {
    return Icons.receipt_long;
  }
  return Icons.payment;
}

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
    SettingsScreen(isLoggedIn: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: QrisFab(
        onTap: () {
          ApiService.trackInteraction(
            featureAccessed: 'QRIS',
            action: 'click',
            interactionType: 'feature_click',
          );
          Navigator.pushNamed(context, '/qris');
        },
      ),

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
  String _accountNumber = '';
  double _accountBalance = 0.0;
  bool _isLoadingProfile = true;

  List<TransactionResponse> _transactions = [];
  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    final trxs = await ApiService.getRecentTransactions(limit: 3);
    if (mounted) {
      setState(() {
        if (trxs != null) {
          _transactions = trxs;
        }
        _isLoadingTransactions = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (profile != null && mounted) {
      final bool consent = profile['consent_personalization'] ?? false;

      // Update nilai notifier global dengan status dari backend
      isPersonalizationEnabledNotifier.value = consent;

      setState(() {
        _userName = profile['full_name'] ?? '-';
        _accountNumber = profile['account_number'] ?? '';
        _accountBalance = (profile['account_balance'] ?? 0.0).toDouble();
        _isLoadingProfile = false;
      });

      // Hanya tampilkan popup jika pengguna belum menyetujui personalisasi
      if (!consent) {
        _showPersonalizationDialog();
      }
    } else {
      setState(() => _isLoadingProfile = false);
    }
  }

  // Masking nomor rekening: tampilkan 4 digit terakhir saja
  String get _accountMasked {
    if (_accountNumber.length >= 4) {
      return '(••••${_accountNumber.substring(_accountNumber.length - 4)})';
    }
    return '(••••)';
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return 'Selamat pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }

  void _showPersonalizationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
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
                  onTap: () async {
                    await ApiService.updateConsent(true);
                    if (ctx.mounted) Navigator.pop(ctx);
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
                  onPressed: () => Navigator.pop(ctx),
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
                              TextSpan(
                                text: '${getGreeting()}, ',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: _isLoadingProfile
                                    ? '...'
                                    : '${_userName.toUpperCase()}!',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                                isLoading: _isLoadingProfile,
                                accountName: _userName,
                                accountNumber: _accountNumber,
                                accountMasked: _accountMasked,
                                balance: _accountBalance,
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
                              const _NewsSection(),
                              if (_isLoadingTransactions || _transactions.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _RecentTransactionsSection(
                                  isLoading: _isLoadingTransactions,
                                  transactions: _transactions,
                                ),
                              ],
                              const SizedBox(height: 24),
                              _EWalletSection(
                                balanceVisible: _balanceVisible,
                                balance: _accountBalance,
                              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                builder: (ctx) => Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Calibri',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Apakah Anda yakin ingin keluar dari aplikasi?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontFamily: 'Calibri',
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: Color(0xFFCC0000),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(ctx, true),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFCC0000), Color(0xFF8C0E1A)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Keluar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      fontFamily: 'Calibri',
                                    ),
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
              );
              if (confirm == true && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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

// ACCOUNT CARD (SUDAH LOGIN)
// ─────────────────────────────────────────────
class _AccountCard extends StatefulWidget {
  const _AccountCard({
    required this.isLoading,
    required this.accountName,
    required this.accountNumber,
    required this.accountMasked,
    required this.balance,
    required this.balanceVisible,
    required this.onToggleBalance,
  });

  final bool isLoading;
  final String accountName;
  final String accountNumber;
  final String accountMasked;
  final double balance;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7B0000),
            strokeWidth: 2,
          ),
        ),
      );
    }

    final cards = [
      {
        'type': 'Tabungan',
        'badgeColor': const Color(0xFF1A5C4A),
        'name': 'Tabungan Xtra',
        'accountDisplay': widget.balanceVisible
            ? widget.accountNumber
            : widget.accountMasked,
        'balance': widget.balance,
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
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
                                  '${card['name']} ${card['accountDisplay']}',
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
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/transfer'),
                      child: Column(
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
                            'Transfer',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Dot indicator
        if (cards.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cards.length, (i) {
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
  const _EWalletSection({required this.balanceVisible, required this.balance});
  final bool balanceVisible;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'e-Wallet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Calibri',
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card OCTO Pay
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFEFEF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/octo/octopay-logo.svg',
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Octo Pay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Calibri',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Transaksi lebih praktis untuk kamu di sini.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontFamily: 'Calibri',
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 14),
                        _buildHubungkanButton(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Card GoPay
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFEFEF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/gopay-logo.svg',
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Gopay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Calibri',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Top up saldo lebih mudah untuk kamu di sini.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontFamily: 'Calibri',
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 14),
                        _buildHubungkanButton(),
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

  Widget _buildHubungkanButton() {
    return Container(
      width: double.infinity,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: const LinearGradient(
          colors: [Color(0xFFCC0000), Color(0xFF8C0E1A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCC0000).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'Hubungkan',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'Calibri',
        ),
      ),
    );
  }
}

// ================================================================
// SHARED WIDGETS
// ================================================================

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

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.tabIndex, required this.isLoggedIn});
  final int tabIndex;
  final bool isLoggedIn;

  static const List<List<Map<String, dynamic>>> _menus = [
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
      {'label': 'Investasi', 'icon': 'assets/icons/Investasi.svg'},
      {'label': 'Kode Promo', 'icon': 'assets/icons/KodePromo.svg'},
      {
        'label': 'Tabungan &\nDeposito',
        'icon': 'assets/icons/TabunganDeposito.svg',
      },
    ],
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
                          onTap: () {
                            if (item['label'] == 'Transfer') {
                              ApiService.trackInteraction(
                                featureAccessed: 'Transfer',
                                action: 'click',
                                interactionType: 'feature_click',
                              );
                              Navigator.pushNamed(context, '/transfer');
                            } else if (item['label'] == 'QRIS' ||
                                item['label'] == 'QRIS Tap') {
                              ApiService.trackInteraction(
                                featureAccessed: 'QRIS',
                                action: 'click',
                                interactionType: 'feature_click',
                              );
                              Navigator.pushNamed(context, '/qris');
                            } else if (item['label'] ==
                                'Tagihan &\nIsi Ulang') {
                              ApiService.trackInteraction(
                                featureAccessed: 'Tagihan & Isi Ulang',
                                action: 'click',
                                interactionType: 'feature_click',
                              );
                              Navigator.pushNamed(context, '/tagihan');
                            }
                          },
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
    {'image': 'assets/banner/berita/askocto.jpg', 'type': 'Berita'},
    {'image': 'assets/banner/promosi/octoloan-qris.jpg', 'type': 'Promosi'},
    {'image': 'assets/banner/promosi/goalsavers-valas.png', 'type': 'Promosi'},
    {'image': 'assets/banner/berita/adsocto.png', 'type': 'Berita'},
    {'image': 'assets/banner/berita/securityawareness.jpg', 'type': 'Berita'},
    {'image': 'assets/banner/promosi/os-bifast.jpg', 'type': 'Promosi'},
    {'image': 'assets/banner/promosi/mastercard-rev.jpg', 'type': 'Promosi'},
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

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection({
    required this.isLoading,
    required this.transactions,
  });

  final bool isLoading;
  final List<TransactionResponse> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Transaksi Kamu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Calibri',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFEFEF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7B0000),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.history_toggle_off_rounded,
                color: Colors.grey,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada transaksi terakhir',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Calibri',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayTransactions = transactions.take(3).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: displayTransactions.length,
          separatorBuilder: (_, __) =>
              const Divider(color: Color(0xFFF5F5F5), height: 24, thickness: 1),
          itemBuilder: (context, index) {
            final trx = displayTransactions[index];
            final displayTitle = getTransactionDisplayTitle(trx);
            final displaySubtitle = getTransactionDisplaySubtitle(trx);

            return Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getTransactionIcon(trx),
                    color: const Color(0xFFCC0000),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                          fontFamily: 'Calibri',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        displaySubtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontFamily: 'Calibri',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatTrxDateTime(trx.timestamp),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontFamily: 'Calibri',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '-${formatRpCurrency(trx.amount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                        fontFamily: 'Calibri',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Berhasil',
                      style: TextStyle(
                        color: Color(0xFF2E8540),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Calibri',
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const Divider(color: Color(0xFFF5F5F5), height: 24, thickness: 1),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RiwayatTransaksiScreen(),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Transaksi Lainnya',
                  style: TextStyle(
                    color: Color(0xFFCC0000),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Calibri',
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCC0000),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
