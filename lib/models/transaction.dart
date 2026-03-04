class Transaction {
  final String id;
  final String transactionType; // 'receive' or 'transfer'
  final double tonAmount;
  final double usdAmount;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.transactionType,
    required this.tonAmount,
    required this.usdAmount,
    required this.date,
    required this.description,
  });

  bool get isReceive => transactionType.toLowerCase() == 'receive';
  bool get isTransfer => transactionType.toLowerCase() == 'transfer';
  
  String get tonAmountFormatted {
    final sign = isReceive ? '+' : '-';
    return '$sign${tonAmount.toStringAsFixed(2)}';
  }

  String get usdAmountFormatted {
    return '\$${usdAmount.toStringAsFixed(2)}';
  }
}
