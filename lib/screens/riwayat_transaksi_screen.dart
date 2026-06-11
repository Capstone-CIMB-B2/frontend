import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../models/transaction_response.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  List<TransactionResponse> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final trxs = await ApiService.getRecentTransactions(limit: 50);
    if (mounted) {
      setState(() {
        if (trxs != null) {
          _transactions = trxs;
        }
        _isLoading = false;
      });
    }
  }

  int _selectedMonthIndex = 5; // Default to June
  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  String formatRpCurrency(double amount) {
    int val = amount.toInt();
    String str = val.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  String formatDateHeader(String timestamp) {
    try {
      final cleanTs = timestamp.replaceAll('T', ' ');
      final datePart = cleanTs.split(' ')[0];
      final dateSplit = datePart.split('-');
      if (dateSplit.length == 3) {
        final year = dateSplit[0];
        final monthNum = dateSplit[1];
        final day = int.parse(dateSplit[2]).toString();

        const months = {
          '01': 'Januari', '02': 'Februari', '03': 'Maret', '04': 'April',
          '05': 'Mei', '06': 'Juni', '07': 'Juli', '08': 'Agustus',
          '09': 'September', '10': 'Oktober', '11': 'November', '12': 'Desember'
        };
        final monthName = months[monthNum] ?? monthNum;
        return '$day $monthName $year';
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

  Widget _buildMonthTabs() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final isActive = index == _selectedMonthIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedMonthIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFCC0000) : const Color(0xFFF1F1F3),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Text(
                _months[index],
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // HEADER
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
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                                  'Riwayat Transaksi',
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
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CONTENT
          Positioned(
            top: headerHeight - 20,
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
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7B0000),
          strokeWidth: 2,
        ),
      );
    }

    final selectedMonthAbbr = _months[_selectedMonthIndex];
    final Map<String, String> monthAbbrToNum = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'Mei': '05',
      'Jun': '06',
      'Jul': '07',
      'Agu': '08',
      'Sep': '09',
      'Okt': '10',
      'Nov': '11',
      'Des': '12',
    };
    final targetMonthNum = monthAbbrToNum[selectedMonthAbbr];

    final filteredTrxs = _transactions.where((trx) {
      try {
        final cleanTs = trx.timestamp.replaceAll('T', ' ');
        final datePart = cleanTs.split(' ')[0];
        final dateSplit = datePart.split('-');
        if (dateSplit.length == 3) {
          return dateSplit[1] == targetMonthNum;
        }
      } catch (_) {}
      return false;
    }).toList();

    // Group transactions by date
    final Map<String, List<TransactionResponse>> groupedTransactions = {};
    final List<String> sortedDates = [];
    for (var trx in filteredTrxs) {
      final header = formatDateHeader(trx.timestamp);
      if (!groupedTransactions.containsKey(header)) {
        groupedTransactions[header] = [];
        sortedDates.add(header);
      }
      groupedTransactions[header]!.add(trx);
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildMonthTabs(),
        const SizedBox(height: 16),
        Expanded(
          child: filteredTrxs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history_toggle_off_rounded,
                        color: Colors.grey,
                        size: 50,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada transaksi pada bulan ini.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Calibri',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, dateIndex) {
                    final dateHeader = sortedDates[dateIndex];
                    final dateTrxs = groupedTransactions[dateHeader]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          dateHeader,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Calibri',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Divider(color: Color(0xFFE2E2E6), thickness: 1, height: 16),
                        const SizedBox(height: 8),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: dateTrxs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 18),
                          itemBuilder: (context, trxIndex) {
                            final trx = dateTrxs[trxIndex];
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
                                      const SizedBox(height: 4),
                                      Text(
                                        displaySubtitle,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13,
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
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
