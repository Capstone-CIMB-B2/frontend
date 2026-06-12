import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'rekening_lain_screen.dart';
import 'detail_transfer_screen.dart';
import '../services/api_service.dart';

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

  // Data kontak tab "Tersimpan"
  List<Map<String, String>> _savedContacts = [];

  // Data kontak tab "Terakhir"
  List<Map<String, String>> _recentContacts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    _fetchSavedContacts();
    _fetchRecentContacts();
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'SA';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Future<void> _fetchSavedContacts() async {
    try {
      final data = await ApiService.getSavedContacts(category: 'Transfer');
      if (data != null && mounted) {
        setState(() {
          _savedContacts = data.map<Map<String, String>>((x) {
            final name = x['name']?.toString() ?? '';
            return {
              'id': x['id']?.toString() ?? '',
              'name': name,
              'initials': _getInitials(name),
              'bank': x['bank_name']?.toString() ?? '',
              'account': x['account_number']?.toString() ?? '',
            };
          }).toList();
        });
      }
    } catch (e) {
      // silent
    }
  }

  Future<void> _fetchRecentContacts() async {
    try {
      final trxs = await ApiService.getRecentTransactions(
        limit: 10,
        transactionMethod: 'Transfer',
      );
      if (trxs != null && mounted) {
        setState(() {
          final seen = <String>{};
          final contacts = <Map<String, String>>[];
          for (var trx in trxs) {
            final name = trx.merchantName;
            final bank = trx.recipientBank ?? 'CIMB NIAGA';
            final acc = trx.recipientAccount ?? '';
            final key = '$name|$bank|$acc';
            if (!seen.contains(key) && name.isNotEmpty && acc.isNotEmpty) {
              seen.add(key);
              contacts.add({
                'name': name,
                'initials': _getInitials(name),
                'bank': bank,
                'account': acc,
              });
            }
          }
          _recentContacts = contacts;
        });
      }
    } catch (e) {
      // silent
    }
  }

  bool _isContactFavorited(Map<String, String> contact) {
    return _savedContacts.any((c) => c['account'] == contact['account']);
  }

  String? _getSavedContactId(Map<String, String> contact) {
    try {
      return _savedContacts.firstWhere((c) => c['account'] == contact['account'])['id'];
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleFavoriteTap(Map<String, String> contact) async {
    final isSaved = _isContactFavorited(contact);
    if (isSaved) {
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
                  'Hapus Favorit',
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
                  'Apakah Anda yakin ingin menghapus transaksi ini dari daftar favorit?',
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
                          'Kembali',
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
                            'Hapus',
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

      if (confirm == true) {
        final savedId = _getSavedContactId(contact);
        if (savedId != null) {
          final success = await ApiService.deleteSavedContact(int.parse(savedId));
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kontak berhasil dihapus dari favorit'),
                duration: Duration(seconds: 2),
              ),
            );
            _fetchSavedContacts();
            _fetchRecentContacts();
          }
        }
      }
    } else {
      // Add to favorites
      final res = await ApiService.addSavedContact(
        name: contact['name']!,
        accountNumber: contact['account']!,
        bankName: contact['bank']!,
        category: 'Transfer',
      );
      if (res != null && res['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${contact['name']} disimpan ke favorit!'),
            duration: const Duration(seconds: 2),
          ),
        );
        _fetchSavedContacts();
        _fetchRecentContacts();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Gagal menyimpan kontak'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
                          isFavoritedFn: _isContactFavorited,
                          onFavoriteTapFn: _handleFavoriteTap,
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
    required this.isFavoritedFn,
    required this.onFavoriteTapFn,
  });

  final bool isSavedActive;
  final List<Map<String, String>> savedContacts;
  final List<Map<String, String>> recentContacts;
  final ValueChanged<Map<String, String>> onContactTap;
  final VoidCallback onUbahTap;
  final bool Function(Map<String, String>) isFavoritedFn;
  final Function(Map<String, String>) onFavoriteTapFn;

  List<Map<String, String>> get _activeList =>
      isSavedActive ? savedContacts : recentContacts;

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
                ? 'Belum Ada Transfer Favorit'
                : 'Belum Ada Riwayat Transfer',
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
                ? 'Simpan tujuan transfer favorit Anda agar transaksi berikutnya menjadi lebih cepat dan mudah.'
                : 'Riwayat transfer yang pernah Anda lakukan akan muncul di sini.',
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

  @override
  Widget build(BuildContext context) {
    final contacts = _activeList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header jumlah penerima & tombol kelola (hanya di tab "Tersimpan")
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
                  'Kelola',
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
          const SizedBox(height: 14),
        ],

        // Daftar kontak
        if (contacts.isEmpty)
          _buildEmptyState(isTabSaved: isSavedActive)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return _ContactItem(
                contact: contact,
                onTap: () => onContactTap(contact),
                isFavorited: isFavoritedFn(contact),
                onFavoriteTap: () => onFavoriteTapFn(contact),
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
  const _ContactItem({
    required this.contact,
    required this.onTap,
    required this.isFavorited,
    required this.onFavoriteTap,
  });

  final Map<String, String> contact;
  final VoidCallback onTap;
  final bool isFavorited;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Avatar Lingkaran dengan Inisial
            Container(
              width: 48,
              height: 48,
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
            // Ikon Love/Heart
            GestureDetector(
              onTap: onFavoriteTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? const Color(0xFFCC0000) : Colors.grey,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
