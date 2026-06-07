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

  String _formatCurrency(double amount) {
    int val = amount.toInt();
    String str = val.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'IDR ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & beverage':
      case 'f&b':
        return Icons.restaurant_rounded;
      case 'e-wallet':
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'transport & mobility':
      case 'transport':
      case 'transportasi':
        return Icons.directions_car_rounded;
      case 'utilities':
      case 'tagihan':
      case 'utility':
        return Icons.bolt_rounded;
      case 'lifestyle & entertainment':
      case 'lifestyle':
        return Icons.sports_esports_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & beverage':
      case 'f&b':
        return const Color(0xFFFFECE5);
      case 'e-wallet':
      case 'wallet':
        return const Color(0xFFE5F1FF);
      case 'transport & mobility':
      case 'transport':
      case 'transportasi':
        return const Color(0xFFE5FFE6);
      case 'utilities':
      case 'tagihan':
      case 'utility':
        return const Color(0xFFFFF9E5);
      case 'lifestyle & entertainment':
      case 'lifestyle':
        return const Color(0xFFF3E5FF);
      default:
        return const Color(0xFFF2F2F2);
    }
  }

  Color _getCategoryIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & beverage':
      case 'f&b':
        return const Color(0xFFE05315);
      case 'e-wallet':
      case 'wallet':
        return const Color(0xFF0F75BD);
      case 'transport & mobility':
      case 'transport':
      case 'transportasi':
        return const Color(0xFF2E8540);
      case 'utilities':
      case 'tagihan':
      case 'utility':
        return const Color(0xFFBF8F00);
      case 'lifestyle & entertainment':
      case 'lifestyle':
        return const Color(0xFF8B25C6);
      default:
        return const Color(0xFF666666);
    }
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

    if (_transactions.isEmpty) {
      return Center(
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
              'Belum ada riwayat transaksi',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const Divider(
        color: Color(0xFFF5F5F5),
        height: 24,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        final trx = _transactions[index];
        final cat = trx.category;
        final icon = _getCategoryIcon(cat);
        final bgColor = _getCategoryColor(cat);
        final iconColor = _getCategoryIconColor(cat);

        final displayDate = trx.timestamp.length >= 10
            ? trx.timestamp.substring(0, 10)
            : trx.timestamp;

        return Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: iconColor, size: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trx.merchantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$cat • $displayDate',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '- ${_formatCurrency(trx.amount)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF7B0000),
              ),
            ),
          ],
        );
      },
    );
  }
}
