import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'payment_screen.dart';
import '../services/api_service.dart';

class TagihanScreen extends StatefulWidget {
  const TagihanScreen({super.key});

  @override
  State<TagihanScreen> createState() => _TagihanScreenState();
}

class _TagihanScreenState extends State<TagihanScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _favSearchController = TextEditingController();

  String _searchQuery = '';
  String _favSearchQuery = '';

  int _selectedCategoryTab = 0;
  int _selectedFavTab = 0;

  int _currentPageGrid = 0;
  final PageController _pageController = PageController();

  static final List<_ServiceItem> _allServices = [
    const _ServiceItem(
      label: 'eWallet',
      category: 'isi_ulang',
      iconPath: 'assets/icons/tagihan/eWallet.svg',
      keywords: [
        'ewallet',
        'e-wallet',
        'gopay',
        'ovo',
        'dana',
        'shopeepay',
        'linkaja',
        'astrapay',
        'doku',
        'ipaymu',
        'flazz',
        'tapcash',
      ],
    ),
    const _ServiceItem(
      label: 'Telepon/Ponsel',
      category: 'isi_ulang',
      iconPath: 'assets/icons/tagihan/Ponsel.svg',
      keywords: [
        'telepon',
        'ponsel',
        'pulsa',
        'paket data',
        'pascabayar',
        'prabayar',
      ],
    ),
    const _ServiceItem(
      label: 'Listrik',
      category: 'tagihan_isi_ulang',
      iconPath: 'assets/icons/tagihan/Listrik.svg',
      keywords: [
        'listrik',
        'pln',
        'token',
        'prabayar',
        'non tagihan listrik',
        'listrik prabayar',
      ],
    ),
    const _ServiceItem(
      label: 'PAM/PDAM',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/PDAM.svg',
      keywords: ['pam', 'pdam'],
    ),
    const _ServiceItem(
      label: 'Internet/Kabel TV',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Internet.svg',
      keywords: [
        'internet',
        'kabel tv',
        'wifi',
        'indihome',
        'first media',
        'biznet',
      ],
    ),
    const _ServiceItem(
      label: 'Streaming & Hiburan',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Hiburan.svg',
      keywords: ['netflix', 'spotify', 'youtube', 'streaming', 'hiburan'],
    ),
    const _ServiceItem(
      label: 'e-Commerce & Pembayaran',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Ecommerce.svg',
      keywords: [
        'ecommerce',
        'e-commerce',
        'pembayaran',
        'tokopedia',
        'shopee',
        'bukalapak',
        'gojek',
        'traveloka',
        'gudang voucher',
        'winpay',
      ],
    ),
    const _ServiceItem(
      label: 'Pajak',
      category: 'lainnya',
      iconPath: 'assets/icons/tagihan/Pajak.svg',
      keywords: ['pajak', 'pbb'],
    ),
    const _ServiceItem(
      label: 'Kartu Kredit',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/KartuKredit.svg',
      keywords: ['kartu kredit', 'credit card', 'cc'],
    ),
    const _ServiceItem(
      label: 'Virtual Account',
      category: 'lainnya',
      iconPath: 'assets/icons/tagihan/VirtualAccount.svg',
      keywords: ['virtual account', 'va'],
    ),
    const _ServiceItem(
      label: 'BPJS',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/BPJS.svg',
      keywords: ['bpjs', 'kesehatan', 'ketenagakerjaan'],
    ),
    const _ServiceItem(
      label: 'Penerimaan Negara',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Penerimaan.svg',
      keywords: ['penerimaan negara', 'pnbp', 'sbn'],
    ),
    const _ServiceItem(
      label: 'Zakat & Kebajikan',
      category: 'lainnya',
      iconPath: 'assets/icons/tagihan/Zakat.svg',
      keywords: ['zakat', 'kebajikan', 'infaq', 'sedekah', 'donasi'],
    ),
    const _ServiceItem(
      label: 'Pendidikan',
      category: 'lainnya',
      iconPath: 'assets/icons/tagihan/Pendidikan.svg',
      keywords: ['pendidikan', 'school', 'college'],
    ),
    const _ServiceItem(
      label: 'Bea Cukai & Pajak Kendaraan',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Bea.svg',
      keywords: ['bea cukai', 'pajak kendaraan', 'samsat', 'pajak'],
    ),
    const _ServiceItem(
      label: 'Pajak Kendaraan',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Pajak.svg',
      keywords: [
        'pajak',
        'e-samsat',
        'stnk',
        'denda',
        'perpanjangan',
        'penerbitan',
        'sim',
        'bpkb',
      ],
    ),
    const _ServiceItem(
      label: 'Keuangan & Pinjaman',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Keuangan.svg',
      keywords: ['keuangan', 'pinjaman', 'kredit', 'cicilan', 'multi finance'],
    ),
    const _ServiceItem(
      label: 'Asuransi',
      category: 'lainnya',
      iconPath: 'assets/icons/tagihan/Asuransi.svg',
      keywords: ['asuransi', 'insurance'],
    ),
    const _ServiceItem(
      label: 'Visa/Paspor',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Visa.svg',
      keywords: ['visa', 'paspor', 'imigrasi'],
    ),
    const _ServiceItem(
      label: 'Kantor Urusan Agama (KUA)',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/KUA.svg',
      keywords: ['kua', 'nikah', 'kantor urusan agama'],
    ),
    const _ServiceItem(
      label: 'Layanan Properti',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Layanan.svg',
      keywords: ['layanan properti', 'ipl', 'apartemen'],
    ),
    const _ServiceItem(
      label: 'Makanan & Minuman',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Makanan.svg',
      keywords: ['makanan', 'minuman', 'kuliner'],
    ),
    const _ServiceItem(
      label: 'Pertamina Gas Negara (PGN)',
      category: 'isi_ulang',
      iconPath: 'assets/icons/tagihan/PGN.svg',
      keywords: ['pgn', 'gas', 'pertamina'],
    ),
    const _ServiceItem(
      label: 'Tiket',
      category: 'lainnya',
      iconPath: 'assets/icons/tagihan/Tiket.svg',
      keywords: ['tiket', 'ticket', 'kereta', 'pesawat', 'konser'],
    ),
  ];

  List<Map<String, String>> _savedFavorites = [];
  List<Map<String, String>> _recentFavorites = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _currentPageGrid = 0;
      });
    });
    _favSearchController.addListener(() {
      setState(
        () => _favSearchQuery = _favSearchController.text.trim().toLowerCase(),
      );
    });
    _fetchSavedFavorites();
    _fetchRecentFavorites();
  }

  String _getWalletLogo(String type) {
    switch (type.toLowerCase()) {
      // E-Wallet
      case 'shopeepay':
        return 'assets/logo/Shopeepay.svg';

      case 'gopay':
        return 'assets/logo/Gopay.svg';

      case 'ovo':
        return 'assets/logo/Ovo.png';

      case 'dana':
        return 'assets/logo/Dana.svg';

      // Pulsa
      case 'telkomsel':
        return 'assets/logo/Telkomsel.svg';

      case 'indosat':
        return 'assets/logo/Indosat.svg';

      case 'xl':
        return 'assets/logo/Xl.svg';

      // Tagihan
      case 'pln':
        return 'assets/logo/Pln.svg';

      case 'biznet':
        return 'assets/logo/Biznet.svg';

      case 'indihome':
        return 'assets/logo/IndiHome.svg';

      case 'telkom':
        return 'assets/logo/Telkom.png';

      // Hiburan
      case 'netflix':
        return 'assets/logo/Netflix.svg';

      case 'spotify':
        return 'assets/logo/Spotify.svg';

      case 'youtube':
        return 'assets/logo/Youtube.png';

      default:
        return 'assets/icons/Tagihan.svg'; // fallback
    }
  }

  Future<void> _fetchSavedFavorites() async {
    try {
      final data = await ApiService.getSavedContacts(
        excludeCategory: 'Transfer',
      );
      if (data != null && mounted) {
        setState(() {
          _savedFavorites = data.map<Map<String, String>>((x) {
            final type = x['bank_name']?.toString() ?? 'E-Wallet';
            return {
              'id': x['id']?.toString() ?? '',
              'name': x['name']?.toString() ?? '',
              'number': x['account_number']?.toString() ?? '',
              'type': type,
              'logo': _getWalletLogo(type),
            };
          }).toList();
        });
      }
    } catch (e) {
      /* silent */
    }
  }

  Future<void> _fetchRecentFavorites() async {
    try {
      final trxs = await ApiService.getRecentTransactions(
        limit: 10,
        excludeMethod: 'Transfer',
      );
      if (trxs != null && mounted) {
        setState(() {
          final seen = <String>{};
          final list = <Map<String, String>>[];
          for (var trx in trxs) {
            final numVal = trx.recipientAccount ?? '';
            final type = trx.merchantName;
            final key = '$numVal|$type';
            if (!seen.contains(key) && numVal.isNotEmpty && type.isNotEmpty) {
              seen.add(key);
              list.add({
                'name': '$type - $numVal',
                'number': numVal,
                'type': type,
                'logo': _getWalletLogo(type),
              });
            }
          }
          _recentFavorites = list;
        });
      }
    } catch (e) {
      /* silent */
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _favSearchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<_ServiceItem> get _filteredServicesByCategory {
    switch (_selectedCategoryTab) {
      case 1:
        return _allServices
            .where(
              (s) =>
                  s.category == 'tagihan' || s.category == 'tagihan_isi_ulang',
            )
            .toList();
      case 2:
        return _allServices
            .where(
              (s) =>
                  s.category == 'isi_ulang' ||
                  s.category == 'tagihan_isi_ulang',
            )
            .toList();
      case 3:
        return _allServices.where((s) => s.category == 'lainnya').toList();
      default:
        return _allServices;
    }
  }

  List<_ServiceItem> get _finalFilteredServices {
    final categoryList = _filteredServicesByCategory;
    if (_searchQuery.isEmpty) return categoryList;
    return categoryList
        .where(
          (s) =>
              s.label.toLowerCase().contains(_searchQuery) ||
              s.keywords.any((k) => k.contains(_searchQuery)),
        )
        .toList();
  }

  List<Map<String, String>> get _filteredSavedFavorites {
    if (_favSearchQuery.isEmpty) return _savedFavorites;
    return _savedFavorites
        .where(
          (c) =>
              c['name']!.toLowerCase().contains(_favSearchQuery) ||
              c['number']!.toLowerCase().contains(_favSearchQuery),
        )
        .toList();
  }

  List<Map<String, String>> get _filteredRecentFavorites {
    if (_favSearchQuery.isEmpty) return _recentFavorites;
    return _recentFavorites
        .where(
          (c) =>
              c['name']!.toLowerCase().contains(_favSearchQuery) ||
              c['number']!.toLowerCase().contains(_favSearchQuery),
        )
        .toList();
  }

  List<List<_ServiceItem>> _chunkList(List<_ServiceItem> list, int chunkSize) {
    final chunks = <List<_ServiceItem>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  void _onServiceTap(String label) {
    switch (label) {
      case 'eWallet':
        _showEWalletBottomSheet();
        break;
      case 'Telepon/Ponsel':
        _showTeleponBottomSheet();
        break;
      case 'Listrik':
        _showListrikBottomSheet();
        break;
      case 'PAM/PDAM':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PaymentScreen(
              category: 'Utilities',
              merchantName: 'PDAM',
              transactionMethod: 'Bayar Tagihan',
            ),
          ),
        );
        break;
      case 'Internet/Kabel TV':
        _showInternetBottomSheet();
        break;
      case 'Streaming & Hiburan':
        _showStreamingBottomSheet();
        break;
    }
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────
  void _showEWalletBottomSheet() {
    _showCustomBottomSheet(
      title: 'Isi Ulang e-Wallet',
      child: _buildLogoOptionsSheet(
        options: const [
          {'name': 'ShopeePay', 'logo': 'assets/logo/Shopeepay.svg'},
          {'name': 'Gopay', 'logo': 'assets/logo/Gopay.svg'},
          {'name': 'OVO', 'logo': 'assets/logo/Ovo.png'},
          {'name': 'Dana', 'logo': 'assets/logo/Dana.svg'},
        ],
        onSelect: (option) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                category: 'E-Wallet',
                merchantName: option,
                transactionMethod: 'Top Up',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTeleponBottomSheet() {
    _showCustomBottomSheet(
      title: 'Pilih Operator Seluler',
      child: _buildLogoOptionsSheet(
        options: const [
          {'name': 'Telkomsel', 'logo': 'assets/logo/Telkomsel.svg'},
          {'name': 'XL', 'logo': 'assets/logo/Xl.svg'},
          {'name': 'Indosat', 'logo': 'assets/logo/Indosat.svg'},
        ],
        onSelect: (option) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                category: 'Telco',
                merchantName: option,
                transactionMethod: 'Pembelian Pulsa',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showListrikBottomSheet() {
    _showCustomBottomSheet(
      title: 'Layanan Listrik PLN',
      child: _buildLogoOptionsSheet(
        options: const [
          {'name': 'Tagihan Listrik PLN', 'logo': 'assets/logo/Pln.svg'},
          {'name': 'Token Listrik PLN', 'logo': 'assets/logo/Pln.svg'},
        ],
        onSelect: (option) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PaymentScreen(
                category: 'Utilities',
                merchantName: 'PLN',
                transactionMethod: 'Bayar Tagihan',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInternetBottomSheet() {
    _showCustomBottomSheet(
      title: 'Pilih Provider Internet/Kabel TV',
      child: _buildLogoOptionsSheet(
        options: const [
          {'name': 'Indihome', 'logo': 'assets/logo/Indihome.svg'},
          {'name': 'Biznet', 'logo': 'assets/logo/Biznet.svg'},
          {'name': 'Telkom', 'logo': 'assets/logo/Telkom.png'},
        ],
        onSelect: (option) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                category: 'Internet',
                merchantName: option,
                transactionMethod: 'Bayar Tagihan',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStreamingBottomSheet() {
    _showCustomBottomSheet(
      title: 'Pilih Layanan Hiburan',
      child: _buildLogoOptionsSheet(
        options: const [
          {'name': 'Netflix', 'logo': 'assets/logo/Netflix.svg'},
          {'name': 'Spotify', 'logo': 'assets/logo/Spotify.svg'},
          {'name': 'Youtube', 'logo': 'assets/logo/Youtube.png'},
        ],
        onSelect: (option) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                category: 'Lifestyle & Entertainment',
                merchantName: option,
                transactionMethod: 'Bayar Tagihan',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCustomBottomSheet({required String title, required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.70,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Calibri',
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoOptionsSheet({
    required List<Map<String, String>> options,
    required Function(String) onSelect,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = options[index];
        final logo = option['logo'] ?? '';
        return GestureDetector(
          onTap: () => onSelect(option['name']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E2E6), width: 1.2),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 34,
                  child: logo.endsWith('.svg')
                      ? SvgPicture.asset(
                          logo,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 24,
                            color: Colors.grey,
                          ),
                        )
                      : Image.asset(
                          logo,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Calibri',
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 100;

    final services = _finalFilteredServices;
    final isSearching = _searchQuery.isNotEmpty;
    final chunks = isSearching
        ? <List<_ServiceItem>>[]
        : _chunkList(services, 10);
    final pageCount = isSearching ? 0 : chunks.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: headerHeight,
              child: ClipRRect(
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
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
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
                                'Tagihan & Isi Ulang',
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
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Konten utama ───────────────────────────────────────────────
          Positioned(
            top: headerHeight - 25,
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
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(
                          controller: _searchController,
                          hintText: 'Cari nomor VA atau perusahaan',
                        ),
                        const SizedBox(height: 20),

                        _CategoryTabs(
                          selectedIndex: _selectedCategoryTab,
                          onSelect: (i) => setState(() {
                            _selectedCategoryTab = i;
                            _currentPageGrid = 0;
                          }),
                        ),
                        const SizedBox(height: 24),

                        // Grid layanan
                        if (services.isEmpty)
                          Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: const Text(
                              'Layanan tidak ditemukan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontFamily: 'Calibri',
                              ),
                            ),
                          )
                        else if (isSearching)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final itemWidth = constraints.maxWidth / 5;
                              return Wrap(
                                runSpacing: 16,
                                children: services
                                    .map<Widget>(
                                      (item) => SizedBox(
                                        width: itemWidth,
                                        child: _ServiceGridItem(
                                          label: item.label,
                                          iconPath: item.iconPath,
                                          onTap: () =>
                                              _onServiceTap(item.label),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          )
                        else
                          Column(
                            children: [
                              SizedBox(
                                height: 180,
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (i) =>
                                      setState(() => _currentPageGrid = i),
                                  itemCount: pageCount,
                                  itemBuilder: (context, pageIndex) {
                                    final pageItems = chunks[pageIndex];
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final itemWidth =
                                            constraints.maxWidth / 5;
                                        return Wrap(
                                          runSpacing: 16,
                                          children: pageItems
                                              .map<Widget>(
                                                (item) => SizedBox(
                                                  width: itemWidth,
                                                  child: _ServiceGridItem(
                                                    label: item.label,
                                                    iconPath: item.iconPath,
                                                    onTap: () => _onServiceTap(
                                                      item.label,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              _GridPageIndicator(
                                pageCount: pageCount,
                                currentPage: _currentPageGrid,
                              ),
                            ],
                          ),

                        const SizedBox(height: 28),
                        // ── FAVORIT ANDA ──────────────────────────────────
                        _buildFavoritSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FAVORIT SECTION ───────────────────────────────────────────────────
  Widget _buildFavoritSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header judul
        const Text(
          'Favorit Anda',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Calibri',
          ),
        ),
        const SizedBox(height: 16),

        // Search favorit
        _buildSearchBar(
          controller: _favSearchController,
          hintText: 'Cari Layanan Favorit',
        ),
        const SizedBox(height: 16),

        // Tab Tersimpan / Terakhir
        _buildSegmentedControl(),
        const SizedBox(height: 20),

        // Konten tab
        _buildFavoritesContent(),
      ],
    );
  }

  Widget _buildSearchBar({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[400], size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'Calibri',
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontFamily: 'Calibri',
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: controller.clear,
              child: Icon(Icons.close, color: Colors.grey[400], size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          _buildSegmentTab(
            label: 'Tersimpan',
            isActive: _selectedFavTab == 0,
            onTap: () => setState(() => _selectedFavTab = 0),
          ),
          _buildSegmentTab(
            label: 'Terakhir',
            isActive: _selectedFavTab == 1,
            onTap: () => setState(() => _selectedFavTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab({
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

  Widget _buildFavoritesContent() {
    final activeList = _selectedFavTab == 0
        ? _filteredSavedFavorites
        : _filteredRecentFavorites;

    if (activeList.isEmpty) {
      return _buildEmptyState(isTabSaved: _selectedFavTab == 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header count + Kelola (hanya tab Tersimpan)
        if (_selectedFavTab == 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${activeList.length}/250 penerima',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Calibri',
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur Kelola Penerima (Placeholder)'),
                    duration: Duration(seconds: 2),
                  ),
                ),
                child: const Text(
                  'Kelola',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C0E1A),
                    fontFamily: 'Calibri',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],

        // List kartu
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: activeList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildFavoritCard(activeList[index]),
        ),
      ],
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────
  Widget _buildEmptyState({required bool isTabSaved}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F2)),
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
          Image.asset('assets/octo/octo-profile.png', width: 90, height: 90),
          const SizedBox(height: 16),
          Text(
            isTabSaved
                ? 'Belum ada favorit tersimpan'
                : 'Belum ada transaksi terakhir',
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
            isTabSaved
                ? 'Tambahkan layanan atau transaksi yang sering digunakan untuk akses yang lebih praktis.'
                : 'Riwayat transaksi yang Anda lakukan akan ditampilkan di sini untuk memudahkan akses transaksi berikutnya.',
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
    );
  }

  // ── Kartu favorit / terakhir ───────────────────────────────────────────
  Widget _buildFavoritCard(Map<String, String> item) {
    final isRecent = _selectedFavTab == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo dalam lingkaran
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: ClipOval(child: _buildLogoWidget(item['logo'])),
          ),
          const SizedBox(width: 14),

          // Nama + nomor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Calibri',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item['number'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: 'Calibri',
                  ),
                ),
              ],
            ),
          ),

          // Ikon aksi
          if (isRecent)
            GestureDetector(
              onTap: () async {
                final res = await ApiService.addSavedContact(
                  name: item['name']!,
                  accountNumber: item['number']!,
                  bankName: item['type']!,
                  category: 'TopUp',
                );
                if (!mounted) return;
                if (res != null && res['success'] == true) {
                  _fetchSavedFavorites();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['name']} disimpan ke favorit!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        res?['message'] ?? 'Gagal menyimpan kontak',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Color(0xFF8C0E1A),
                  size: 22,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.chevron_right, color: Colors.grey, size: 22),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoWidget(String? logoPath) {
    if (logoPath == null || logoPath.isEmpty) {
      return const Icon(
        Icons.account_balance_wallet_outlined,
        color: Color(0xFF8C0E1A),
        size: 28,
      );
    }
    if (logoPath.endsWith('.svg')) {
      return SvgPicture.asset(
        logoPath,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.account_balance_wallet_outlined,
          color: Color(0xFF8C0E1A),
          size: 28,
        ),
      );
    }
    return Image.asset(
      logoPath,
      width: 48,
      height: 48,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.account_balance_wallet_outlined,
        color: Color(0xFF8C0E1A),
        size: 28,
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────

class _ServiceGridItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;
  const _ServiceGridItem({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: SvgPicture.asset(iconPath, width: 43, height: 43),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 48,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontFamily: 'Calibri',
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<String> tabs = const ['Semua', 'Tagihan', 'Isi Ulang', 'Lainnya'];
  const _CategoryTabs({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isActive = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFFFF3F3) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF8C0E1A)
                      : const Color(0xFF707070),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 17,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GridPageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  const _GridPageIndicator({
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          pageCount,
          (index) => Container(
            width: 32,
            height: 4,
            color: index == currentPage
                ? const Color(0xFF8C0E1A)
                : const Color(0xFFE2E2E6),
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String label, category, iconPath;
  final List<String> keywords;
  const _ServiceItem({
    required this.label,
    required this.category,
    required this.iconPath,
    required this.keywords,
  });
}
