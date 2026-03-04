import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_wallet/models/transaction.dart';
import 'package:iot_wallet/services/price_service.dart';

class TransactionService {
  static const String _baseUrl = 'https://toncenter.com/api/v3';

  /// Returns null on network/API error (rate limit, 5xx, etc.)
  /// Returns empty list only when the server confirms no transactions exist.
  static Future<List<Transaction>?> getTransactions(
    String address, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/transactions?account=$address&limit=$limit&offset=$offset&sort=desc',
      );

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> rawList = data['transactions'] ?? [];

        final priceService = PriceService();
        final currentPrice = double.tryParse(priceService.getPrice()) ?? 0.0;

        final List<Transaction> result = [];
        for (final txData in rawList) {
          try {
            final tx = _parseTransaction(txData, currentPrice);
            if (tx != null) result.add(tx);
          } catch (e) {
            continue;
          }
        }
        return result; // may be empty list — that's valid (no transactions)
      } else {
        return null; // API error (429, 500, etc.)
      }
    } catch (e) {
      return null; // network error
    }
  }

  static Transaction? _parseTransaction(
    Map<String, dynamic> txData,
    double currentPrice,
  ) {
    final txHash = txData['hash']?.toString() ?? '';
    final utime = txData['now'] as int? ?? 0;
    final inMsg = txData['in_msg'] as Map<String, dynamic>?;
    final outMsgs = txData['out_msgs'] as List<dynamic>? ?? [];

    bool isReceive = false;
    double tonAmount = 0.0;

    // External in_msg (source == null or empty) means WE initiated the transfer.
    // Internal in_msg (source non-empty) means someone sent US money.
    if (inMsg != null) {
      final source = inMsg['source']?.toString() ?? '';
      final value = double.tryParse(inMsg['value']?.toString() ?? '0') ?? 0.0;
      if (source.isNotEmpty && value > 0) {
        isReceive = true;
        tonAmount = value / 1e9;
      }
    }

    if (!isReceive) {
      for (final raw in outMsgs) {
        if (raw is Map) {
          final value = double.tryParse(raw['value']?.toString() ?? '0') ?? 0.0;
          if (value > 0) {
            tonAmount = value / 1e9;
            break;
          }
        }
      }
    }

    if (tonAmount == 0.0) return null;

    final usdAmount = tonAmount * currentPrice;
    final date = DateTime.fromMillisecondsSinceEpoch(utime * 1000);
    final description = isReceive ? 'Receive' : 'Transfer';

    return Transaction(
      id: txHash,
      transactionType: description,
      tonAmount: tonAmount,
      usdAmount: usdAmount,
      date: date,
      description: description,
    );
  }
}
