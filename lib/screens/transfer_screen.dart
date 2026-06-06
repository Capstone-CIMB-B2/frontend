import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'rekening_lain_screen.dart';
import 'detail_transfer_screen.dart';

// TRANSFER SCREEN
// ─────────────────────────────────────────────
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  int _selectedCurrencyIndex = 0;
  int _selectedFavoriteTab = 0; // 0: Tersimpan, 1: Terakhir
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> _currencyTabs = [
    'Rupiah',
    'Mata Uang Asing',
    'Octo Pay',
    'Poin Xtra',
  ];

  // Data dummy untuk tab "Tersimpan"
  final List<Map<String, String>> _savedContacts = [
    {
      'name': 'GANTANG SATRIA YUDHA',
      'initials': 'GS',
      'bank': 'BNI',
      'account': '1791687886',
    },
    {
      'name': 'AHMAD YUJIN',
      'initials': 'AY',
      'bank': 'BCA',
      'account': '2203948728',
    },
  ];

  // Data dummy untuk tab "Terakhir"
  final List<Map<String, String>> _recentContacts = [
    {
      'name': 'ADITRI SURYA',
      'initials': 'AS',
      'bank': 'BNI',
      'account': '1791687886',
    },
    {
      'name': 'NUR SATRIA JATIKUSUMAH',
      'initials': 'NS',
      'bank': 'CIMB NIAGA',
      'account': '123957642882',
    },
    {
      'name': 'NUR SATRIA JATIKUSUMAH',
      'initials': 'NS',
      'bank': 'CIMB NIAGA',
      'account': '123957642882',
    },
    {
      'name': 'NUR SATRIA JATIKUSUMAH',
      'initials': 'NS',
      'bank': 'CIMB NIAGA',
      'account': '123957642882',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    // TODO: Hubungkan dengan API endpoint pada saat inisialisasi untuk memuat data dari backend
    _fetchSavedContacts();
    _fetchRecentContacts();
  }

  // TODO: Integrasikan API endpoint untuk mengambil data kontak tersimpan
  // Contoh: GET /api/transfer/saved
  Future<void> _fetchSavedContacts() async {
    // setState(() => _isLoading = true);
    // try {
    //   final data = await ApiService.getSavedContacts();
    //   setState(() => _savedContacts = data);
    // } catch (e) { ... }
  }

  // TODO: Integrasikan API endpoint untuk mengambil data kontak terakhir/terbaru
  // Contoh: GET /api/transfer/recent
  Future<void> _fetchRecentContacts() async {
    // try {
    //   final data = await ApiService.getRecentContacts();
    //   setState(() => _recentContacts = data);
    // } catch (e) { ... }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredSavedContacts {
    if (_searchQuery.isEmpty) return _savedContacts;
    return _savedContacts.where((c) {
      return c['name']!.toLowerCase().contains(_searchQuery) ||
          c['bank']!.toLowerCase().contains(_searchQuery) ||
          c['account']!.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<Map<String, String>> get _filteredRecentContacts {
    if (_searchQuery.isEmpty) return _recentContacts;
    return _recentContacts.where((c) {
      return c['name']!.toLowerCase().contains(_searchQuery) ||
          c['bank']!.toLowerCase().contains(_searchQuery) ||
          c['account']!.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 180;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Header Widget (Menggabungkan background SVG, safe area, back button, judul, dan tab)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TransferHeader(
              height: headerHeight,
              tabs: _currencyTabs,
              selectedIndex: _selectedCurrencyIndex,
              onSelect: (i) => setState(() => _selectedCurrencyIndex = i),
              onBack: () => Navigator.pop(context),
            ),
          ),

          // 2. Konten Utama (Kartu putih bertumpuk di atas header dengan overlap 45px)
          Positioned(
            top: headerHeight - 45,
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
                        const _SectionTitle('Tujuan Transfer'),
                        const SizedBox(height: 15),
                        _TransferTypeRow(
                          onRekeningLainTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RekeningLainScreen(),
                              ),
                            );
                          },
                          onRekeningSendiriTap: () {
                            // TODO: Navigasi ke TransferKeRekeningSendiriScreen
                          },
                        ),
                        const SizedBox(height: 25),
                        const _SectionTitle('Favorit Anda'),
                        const SizedBox(height: 15),
                        _SearchBar(controller: _searchController),
                        const SizedBox(height: 20),
                        _FavoriteSegmentControl(
                          selectedTab: _selectedFavoriteTab,
                          onSelect: (i) =>
                              setState(() => _selectedFavoriteTab = i),
                        ),
                        const SizedBox(height: 20),
                        _ContactList(
                          isSavedActive: _selectedFavoriteTab == 0,
                          savedContacts: _filteredSavedContacts,
                          recentContacts: _filteredRecentContacts,
                          onContactTap: (contact) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailTransferScreen(
                                  recipientName: contact['name'] ?? '',
                                  recipientBank: contact['bank'] ?? '',
                                  recipientAccount: contact['account'] ?? '',
                                ),
                              ),
                            );
                          },
                          onUbahTap: () {
                            // TODO: Navigasi ke halaman ubah penerima tersimpan
                          },
                        ),
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
}

// HEADER
// ─────────────────────────────────────────────
class _TransferHeader extends StatelessWidget {
  const _TransferHeader({
    required this.height,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
    required this.onBack,
  });

  final double height;
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 20,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: onBack,
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
                            'Transfer',
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
                  const SizedBox(height: 0),
                  _CurrencyTabs(
                    tabs: tabs,
                    selectedIndex: selectedIndex,
                    onSelect: onSelect,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CURRENCY TABS
// ─────────────────────────────────────────────
class _CurrencyTabs extends StatelessWidget {
  const _CurrencyTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isActive ? const Color(0xFF8C0E1A) : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// SECTION TITLE
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Calibri',
      ),
    );
  }
}

// TRANSFER TYPE ROW
// ─────────────────────────────────────────────
class _TransferTypeRow extends StatelessWidget {
  const _TransferTypeRow({
    required this.onRekeningLainTap,
    required this.onRekeningSendiriTap,
  });

  final VoidCallback onRekeningLainTap;
  final VoidCallback onRekeningSendiriTap;

  @override
  Widget build(BuildContext context) {
    // Untuk mengatur jarak lebar kanan-kiri seluruh baris kotak ini,
    // sesuaikan nilai padding horizontal di bawah (misal: ganti 0 ke 4 atau 8).
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          Expanded(
            child: _TransferTypeButton(
              title: 'Rekening Lain',
              iconPath: 'assets/icons/Transfer.svg',
              onTap: onRekeningLainTap,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _TransferTypeButton(
              title: 'Rekening Sendiri',
              iconPath: 'assets/icons/Transfer.svg',
              onTap: onRekeningSendiriTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferTypeButton extends StatelessWidget {
  const _TransferTypeButton({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  final String title;
  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Menggunakan border outline abu-abu terang alih-alih bayangan (shadow)
          border: Border.all(color: const Color(0xFFE2E2E6), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Calibri',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SEARCH BAR
// ─────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
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
                hintText: 'Mau transfer ke siapa hari ini?',
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
}

// FAVORITE SEGMENT CONTROL
// ─────────────────────────────────────────────
class _FavoriteSegmentControl extends StatelessWidget {
  const _FavoriteSegmentControl({
    required this.selectedTab,
    required this.onSelect,
  });

  final int selectedTab;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          _SegmentTab(
            label: 'Tersimpan',
            isActive: selectedTab == 0,
            onTap: () => onSelect(0),
          ),
          _SegmentTab(
            label: 'Terakhir',
            isActive: selectedTab == 1,
            onTap: () => onSelect(1),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
}

// CONTACT LIST
// ─────────────────────────────────────────────
class _ContactList extends StatelessWidget {
  const _ContactList({
    required this.isSavedActive,
    required this.savedContacts,
    required this.recentContacts,
    required this.onContactTap,
    required this.onUbahTap,
  });

  final bool isSavedActive;
  final List<Map<String, String>> savedContacts;
  final List<Map<String, String>> recentContacts;
  final ValueChanged<Map<String, String>> onContactTap;
  final VoidCallback onUbahTap;

  List<Map<String, String>> get _activeList =>
      isSavedActive ? savedContacts : recentContacts;

  @override
  Widget build(BuildContext context) {
    final contacts = _activeList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header jumlah penerima & tombol ubah (hanya di tab "Tersimpan")
        if (isSavedActive) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${contacts.length}/250 penerima',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Calibri',
                ),
              ),
              GestureDetector(
                onTap: onUbahTap,
                child: const Text(
                  'Ubah',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C0E1A),
                    fontFamily: 'Calibri',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Daftar kontak
        if (contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'Tidak ada penerima ditemukan',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const Divider(
              color: Color(0xFFEFEFEF),
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              return _ContactItem(
                contact: contacts[index],
                onTap: () => onContactTap(contacts[index]),
              );
            },
          ),
      ],
    );
  }
}

// CONTACT ITEM
// ─────────────────────────────────────────────
class _ContactItem extends StatelessWidget {
  const _ContactItem({required this.contact, required this.onTap});

  final Map<String, String> contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailTransferScreen(
              recipientName: contact['name']!,
              recipientBank: contact['bank']!,
              recipientAccount: contact['account']!,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            // Avatar Lingkaran dengan Inisial
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3F3),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                contact['initials']!,
                style: const TextStyle(
                  color: Color(0xFF8C0E1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Informasi Kontak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name']!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Calibri',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${contact['bank']!} • ${contact['account']!}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontFamily: 'Calibri',
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
}
