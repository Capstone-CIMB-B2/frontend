import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'detail_transfer_screen.dart';
import 'payment_screen.dart';


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

  int _selectedCategoryTab =
      0; // 0: Semua, 1: Tagihan, 2: Isi Ulang, 3: Lainnya
  int _selectedFavTab = 0; // 0: Tersimpan, 1: Terakhir

  int _currentPageGrid = 0;
  final PageController _pageController = PageController();

  // State Simulasi Favorit (Empty vs Filled)
  bool _isFavoritesSimulatedEmpty = false;

  // Data Kategori Fitur (menggunakan iconPath SVG)
  static final List<_ServiceItem> _allServices = [
    // Page 1
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
      label: 'Pajak',
      category: 'lainnya',
      iconPath: 'assets/icons/tagihan/Pajak.svg',
      keywords: ['pajak', 'pbb'],
    ),
    const _ServiceItem(
      label: 'PAM/PDAM',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/PDAM.svg',
      keywords: ['pam', 'pdam'],
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
      label: 'BPJS',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/BPJS.svg',
      keywords: ['bpjs', 'kesehatan', 'ketenagakerjaan'],
    ),
    // Page 2
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
      keywords: ['keuangan', 'pinjaman', 'kredit', 'cicilan', 'multi finance'],
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
      label: 'Streaming & Hiburan',
      category: 'tagihan',
      iconPath: 'assets/icons/tagihan/Ecommerce.svg',
      keywords: ['netflix', 'spotify', 'youtube', 'streaming', 'hiburan'],
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

  // Data Dummy Favorit - Tersimpan
  final List<Map<String, String>> _initialSavedFavorites = [
    {
      'name': 'ShopeePay - Louhan',
      'number': '081316274424',
      'type': 'ShopeePay',
      'logo': 'assets/logo/Shopeepay.svg',
    },
  ];

  // Data Dummy Favorit - Terakhir (Recent)
  final List<Map<String, String>> _initialRecentFavorites = [
    {
      'name': 'ShopeePay - Azriel Edbert',
      'number': '081231366285',
      'type': 'ShopeePay',
      'logo': 'assets/logo/Shopeepay.svg',
    },
    {
      'name': 'Dana - Azriel Edbert Kusuma Polin',
      'number': '081231366285',
      'type': 'Dana',
      'logo': 'assets/logo/Dana.svg',
    },
  ];

  late List<Map<String, String>> _savedFavorites;
  late List<Map<String, String>> _recentFavorites;

  @override
  void initState() {
    super.initState();
    _savedFavorites = List.from(_initialSavedFavorites);
    _recentFavorites = List.from(_initialRecentFavorites);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _currentPageGrid = 0; // Reset page on search
      });
    });

    _favSearchController.addListener(() {
      setState(() {
        _favSearchQuery = _favSearchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _favSearchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Filter Kategori berdasarkan Tab Aktif
  List<_ServiceItem> get _filteredServicesByCategory {
    switch (_selectedCategoryTab) {
      case 1: // Tagihan
        return _allServices
            .where(
              (s) =>
                  s.category == 'tagihan' || s.category == 'tagihan_isi_ulang',
            )
            .toList();
      case 2: // Isi Ulang
        return _allServices
            .where(
              (s) =>
                  s.category == 'isi_ulang' ||
                  s.category == 'tagihan_isi_ulang',
            )
            .toList();
      case 3: // Lainnya
        return _allServices.where((s) => s.category == 'lainnya').toList();
      case 0: // Semua
      default:
        return _allServices;
    }
  }

  // Filter Kategori berdasarkan Tab Aktif DAN Search Query
  List<_ServiceItem> get _finalFilteredServices {
    final categoryList = _filteredServicesByCategory;
    if (_searchQuery.isEmpty) return categoryList;
    return categoryList.where((s) {
      return s.label.toLowerCase().contains(_searchQuery) ||
          s.keywords.any((k) => k.contains(_searchQuery));
    }).toList();
  }

  // Filter Kontak Favorit - Tersimpan
  List<Map<String, String>> get _filteredSavedFavorites {
    if (_isFavoritesSimulatedEmpty) return [];
    if (_favSearchQuery.isEmpty) return _savedFavorites;
    return _savedFavorites.where((c) {
      return c['name']!.toLowerCase().contains(_favSearchQuery) ||
          c['number']!.toLowerCase().contains(_favSearchQuery);
    }).toList();
  }

  // Filter Kontak Favorit - Terakhir
  List<Map<String, String>> get _filteredRecentFavorites {
    if (_isFavoritesSimulatedEmpty) return [];
    if (_favSearchQuery.isEmpty) return _recentFavorites;
    return _recentFavorites.where((c) {
      return c['name']!.toLowerCase().contains(_favSearchQuery) ||
          c['number']!.toLowerCase().contains(_favSearchQuery);
    }).toList();
  }

  // Helper untuk memecah list menjadi chunks per halaman
  List<List<_ServiceItem>> _chunkList(List<_ServiceItem> list, int chunkSize) {
    List<List<_ServiceItem>> chunks = [];
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

  // Aksi Klik Layanan Kategori
  void _onServiceTap(String label) {
    if (label == 'eWallet') {
      _showEWalletBottomSheet();
    } else if (label == 'Telepon/Ponsel') {
      _showTeleponBottomSheet();
    } else if (label == 'Listrik') {
      _showListrikBottomSheet();
    } else if (label == 'PAM/PDAM') {
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
    } else if (label == 'Internet/Kabel TV') {
      _showInternetBottomSheet();
    } else if (label == 'Streaming & Hiburan') {
      _showStreamingBottomSheet();
    }
  }

  // Bottom Sheet E-Wallet
  void _showEWalletBottomSheet() {
    _showCustomBottomSheet(
      title: 'Isi Ulang e-Wallet',
      child: _EWalletBottomSheetContent(
        onSelect: (wallet) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                category: 'E-Wallet',
                merchantName: wallet['name']!,
                transactionMethod: 'Top Up',
              ),
            ),
          );
        },
      ),
    );
  }

  // Bottom Sheet Telepon/Ponsel
  void _showTeleponBottomSheet() {
    _showCustomBottomSheet(
      title: 'Pilih Operator Seluler',
      child: _buildSimpleOptionsSheet(
        options: const ['Telkomsel', 'XL', 'Indosat'],
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

  // Bottom Sheet Listrik
  void _showListrikBottomSheet() {
    _showCustomBottomSheet(
      title: 'Layanan Listrik PLN',
      child: _buildSimpleOptionsSheet(
        options: const [
          'Tagihan Listrik PLN',
          'Token Listrik PLN',
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

  // Bottom Sheet Internet
  void _showInternetBottomSheet() {
    _showCustomBottomSheet(
      title: 'Pilih Provider Internet/Kabel TV',
      child: _buildSimpleOptionsSheet(
        options: const ['Indihome', 'Biznet', 'Telkom'],
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

  // Bottom Sheet Streaming & Hiburan
  void _showStreamingBottomSheet() {
    _showCustomBottomSheet(
      title: 'Pilih Layanan Hiburan',
      child: _buildSimpleOptionsSheet(
        options: const ['Netflix', 'Spotify', 'Youtube'],
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


  // Helper menampilkan bottom sheet konsisten
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
      builder: (context) {
        return Padding(
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
                // Drag Indicator
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),

                // Header
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

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEFEFEF),
                ),

                Flexible(child: child),
              ],
            ),
          ),
        );
      },
    );
  }

  // Builder opsi sederhana untuk bottom sheet
  Widget _buildSimpleOptionsSheet({
    required List<String> options,
    required Function(String) onSelect,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = options[index];
        return GestureDetector(
          onTap: () => onSelect(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E2E6), width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
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

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 100;

    final services = _finalFilteredServices;
    final isSearching = _searchQuery.isNotEmpty;

    // Hitung halaman grid hanya jika tidak sedang mencari
    final chunks = isSearching ? [] : _chunkList(services, 10);
    final pageCount = isSearching ? 0 : chunks.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Header merah khas (sama seperti transfer screen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: headerHeight,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
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

          // 2. Konten utama
          Positioned(
            top: headerHeight - 25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
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
                      horizontal: 18.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar Utama
                        _buildSearchBar(
                          controller: _searchController,
                          hintText: 'Cari nomor VA atau perusahaan',
                        ),
                        const SizedBox(height: 20),

                        // Kategori Tabs
                        _CategoryTabs(
                          selectedIndex: _selectedCategoryTab,
                          onSelect: (i) {
                            setState(() {
                              _selectedCategoryTab = i;
                              _currentPageGrid = 0;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Kategori Grid (Swipeable / Filtered List)
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
                          // Mode Pencarian: Tampilkan single grid dengan wrap
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final itemWidth = constraints.maxWidth / 5;
                              return Wrap(
                                runSpacing: 16,
                                children: services.map<Widget>((item) {
                                  return SizedBox(
                                    width: itemWidth,
                                    child: _ServiceGridItem(
                                      label: item.label,
                                      iconPath: item.iconPath,
                                      onTap: () => _onServiceTap(item.label),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          )
                        else
                          // Mode Biasa: Tampilkan swipeable PageView
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
                                          children: pageItems.map<Widget>((
                                            item,
                                          ) {
                                            return SizedBox(
                                              width: itemWidth,
                                              child: _ServiceGridItem(
                                                label: item.label,
                                                iconPath: item.iconPath,
                                                onTap: () =>
                                                    _onServiceTap(item.label),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Page Indicator
                              _GridPageIndicator(
                                pageCount: pageCount,
                                currentPage: _currentPageGrid,
                              ),
                            ],
                          ),

                        const SizedBox(height: 25),

                        // Section Favorit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Favorit Anda',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Calibri',
                              ),
                            ),
                            // Button Simulasi untuk demonstrasi
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isFavoritesSimulatedEmpty =
                                      !_isFavoritesSimulatedEmpty;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(60, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: Icon(
                                _isFavoritesSimulatedEmpty
                                    ? Icons.star_border
                                    : Icons.star,
                                size: 14,
                                color: const Color(0xFF8C0E1A),
                              ),
                              label: Text(
                                _isFavoritesSimulatedEmpty
                                    ? 'Isi Data'
                                    : 'Kosongkan',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8C0E1A),
                                  fontFamily: 'Calibri',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Search Bar Favorit
                        _buildSearchBar(
                          controller: _favSearchController,
                          hintText: 'Cari Layanan Favorit',
                        ),
                        const SizedBox(height: 20),

                        // Tab Segmented control
                        _buildSegmentedControl(),
                        const SizedBox(height: 20),

                        // List Favorit (Empty State vs Filled State)
                        _buildFavoritesContent(),
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

  // Builder Search Bar (bisa digunakan berulang)
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

  // Builder Segmented Tab Control (Tersimpan vs Terakhir)
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
            color: isActive ? const Color(0xFF8C0E1A) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
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

  // Builder Konten Utama Favorit
  Widget _buildFavoritesContent() {
    final savedList = _filteredSavedFavorites;
    final recentList = _filteredRecentFavorites;
    final activeList = _selectedFavTab == 0 ? savedList : recentList;

    if (activeList.isEmpty) {
      // 3.1. Empty State
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset('assets/octo/octo-profile.png', width: 80, height: 80),
            const SizedBox(height: 16),
            const Text(
              'Belum ada favorit tersimpan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Calibri',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Tambahkan layanan atau transaksi yang sering digunakan untuk akses yang lebih praktis.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontFamily: 'Calibri',
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // 3.2. Filled State
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header jumlah & Kelola
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur Kelola Penerima (Placeholder)'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
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

        // List item
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: activeList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = activeList[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E2E6), width: 1.2),
              ),
              child: Row(
                children: [
                  // Logo/Placeholder e-wallet
                  _buildSavedLogo(item['logo'], item['type'] ?? ''),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Calibri',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['number'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: 'Calibri',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Aksi tambahan untuk "Terakhir": add to favorites
                  if (_selectedFavTab == 1)
                    IconButton(
                      icon: const Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Color(0xFF8C0E1A),
                      ),
                      onPressed: () {
                        // Tambahkan ke tersimpan
                        setState(() {
                          final exist = _savedFavorites.any(
                            (element) => element['name'] == item['name'],
                          );
                          if (!exist) {
                            _savedFavorites.add({
                              'name': item['name']!,
                              'number': item['number']!,
                              'type': item['type']!,
                              'logo': item['logo']!,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item['name']} disimpan ke favorit!',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item['name']} sudah ada di favorit!',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        });
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Builder Logo Favorit
  Widget _buildSavedLogo(String? logoPath, String type) {
    if (logoPath != null && logoPath.isNotEmpty) {
      if (logoPath.endsWith('.svg')) {
        return SvgPicture.asset(
          logoPath,
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFF8C0E1A),
            size: 32,
          ),
        );
      } else {
        return Image.asset(
          logoPath,
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFF8C0E1A),
            size: 32,
          ),
        );
      }
    }
    return const Icon(
      Icons.account_balance_wallet_outlined,
      color: Color(0xFF8C0E1A),
      size: 32,
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM SUB-WIDGETS
// ─────────────────────────────────────────────

// Item Grid Kategori Layanan
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
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
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

// Kategori Filter Tab Bar
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

// Page Indicator
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
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;

          return Container(
            width: 32,
            height: 4,
            color: isActive ? const Color(0xFF8C0E1A) : const Color(0xFFE2E2E6),
          );
        }),
      ),
    );
  }
}

// Konten Bottom Sheet E-Wallet
class _EWalletBottomSheetContent extends StatefulWidget {
  final Function(Map<String, String>) onSelect;
  const _EWalletBottomSheetContent({required this.onSelect});

  @override
  State<_EWalletBottomSheetContent> createState() =>
      _EWalletBottomSheetContentState();
}

class _EWalletBottomSheetContentState
    extends State<_EWalletBottomSheetContent> {
  final TextEditingController _walletSearchController = TextEditingController();
  String _query = '';

  final List<Map<String, String>> _wallets = [
    {'name': 'Flazz BCA', 'logo': 'assets/logo/FlazzBCA.svg'},
    {'name': 'BNI TapCash', 'logo': 'assets/logo/TapCash.svg'},
    {'name': 'ShopeePay', 'logo': 'assets/logo/Shopeepay.svg'},
    {'name': 'Gopay', 'logo': 'assets/gopay.svg'},
    {'name': 'Ovo', 'logo': 'assets/logo/OVO.svg'},
    {'name': 'Dana', 'logo': 'assets/logo/Dana.svg'},
    {'name': 'Doku Wallet', 'logo': 'assets/logo/DOKU.svg'},
    {'name': 'iPaymu', 'logo': 'assets/Logo/IPaymu.png'},
    {'name': 'AstraPay', 'logo': 'assets/logo/AstraPay.png'},
    {'name': 'LinkAja', 'logo': 'assets/logo/LinkAja.svg'},
    {'name': 'OTTOCASH', 'logo': 'assets/logo/OTTOCASH.png'},
  ];

  @override
  void initState() {
    super.initState();
    _walletSearchController.addListener(() {
      setState(() {
        _query = _walletSearchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _walletSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _wallets
        .where((w) => w['name']!.toLowerCase().contains(_query))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Bar E-Wallet
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
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
                    controller: _walletSearchController,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontFamily: 'Calibri',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari nama produk',
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
                if (_walletSearchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: _walletSearchController.clear,
                    child: Icon(Icons.close, color: Colors.grey[400], size: 20),
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
        // List e-wallet
        Expanded(
          child: filtered.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontFamily: 'Calibri',
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final wallet = filtered[index];
                    return GestureDetector(
                      onTap: () {
                        widget.onSelect(wallet);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E2E6),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildWalletLogo(wallet['logo'], wallet['name']!),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                wallet['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Builder Logo E-Wallet
  Widget _buildWalletLogo(String? logoPath, String name) {
    Widget logoWidget;

    if (logoPath != null && logoPath.isNotEmpty) {
      if (logoPath.endsWith('.svg')) {
        logoWidget = SvgPicture.asset(
          logoPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFFCC0000),
            size: 24,
          ),
        );
      } else {
        logoWidget = Image.asset(
          logoPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFFCC0000),
            size: 24,
          ),
        );
      }
    } else {
      logoWidget = const Icon(
        Icons.account_balance_wallet_outlined,
        color: Color(0xFFCC0000),
        size: 24,
      );
    }

    return SizedBox(width: 39, height: 32, child: Center(child: logoWidget));
  }
}

class _ServiceItem {
  final String label;
  final String category;
  final String iconPath;
  final List<String> keywords;

  const _ServiceItem({
    required this.label,
    required this.category,
    required this.iconPath,
    required this.keywords,
  });
}
