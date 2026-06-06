class TransactionResponse {
  final int trxId;
  final String timestamp;
  final String category;
  final String merchantName;
  final String transactionMethod;
  final double amount;

  TransactionResponse({
    required this.trxId,
    required this.timestamp,
    required this.category,
    required this.merchantName,
    required this.transactionMethod,
    required this.amount,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      trxId: json['trx_id'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      category: json['category'] ?? '',
      merchantName: json['merchant_name'] ?? '',
      transactionMethod: json['transaction_method'] ?? '',
      amount: double.tryParse((json['amount'] ?? 0.0).toString()) ?? 0.0,
    );
  }
}
