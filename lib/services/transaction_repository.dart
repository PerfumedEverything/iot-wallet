import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iot_wallet/models/transaction.dart';
import 'package:iot_wallet/services/transaction_service.dart';

/// Singleton that fetches and auto-refreshes transactions every 2 min.
/// - [isLoadingNotifier] is true until the first successful fetch completes.
/// - On API error (null result) the previous list is kept and loading stays
///   true until a successful response or the address changes.
/// - If the first fetch fails (rate limit), retries once after 3 s.
class TransactionRepository {
  TransactionRepository._();
  static final TransactionRepository instance = TransactionRepository._();

  final ValueNotifier<List<Transaction>> transactionsNotifier =
      ValueNotifier([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  String? _address;
  Timer? _timer;
  bool _fetching = false;
  bool _hasSuccessfulFetch = false;

  /// True if startWatching has completed at least one cycle for an address.
  bool get isWatching => _timer != null;

  Future<void> startWatching(
    String address, {
    Duration initialDelay = Duration.zero,
  }) async {
    if (_address == address && _timer != null) return;

    _address = address;
    _hasSuccessfulFetch = false;
    _timer?.cancel();
    isLoadingNotifier.value = true;

    if (initialDelay > Duration.zero) {
      await Future.delayed(initialDelay);
    }

    await _refresh();

    // If first attempt failed (rate limit / network), retry once after 3 s.
    if (!_hasSuccessfulFetch) {
      print('[TxRepo] first fetch failed — retrying in 3 s');
      await Future.delayed(const Duration(seconds: 3));
      await _refresh();
    }

    // If still no data after retry, stop spinner and show empty state.
    if (!_hasSuccessfulFetch) {
      isLoadingNotifier.value = false;
    }

    _timer = Timer.periodic(const Duration(minutes: 2), (_) => _refresh());
  }

  void stopWatching() {
    _timer?.cancel();
    _timer = null;
    _address = null;
    isLoadingNotifier.value = false;
  }

  Future<void> _refresh() async {
    if (_address == null || _fetching) return;
    _fetching = true;
    print('[TxRepo] fetching for $_address  hasSuccessfulFetch=$_hasSuccessfulFetch');
    try {
      final txs = await TransactionService.getTransactions(
        _address!,
        limit: 50,
      );
      if (txs != null) {
        print('[TxRepo] success — ${txs.length} transactions');
        transactionsNotifier.value = txs;
        _hasSuccessfulFetch = true;
        isLoadingNotifier.value = false;
      } else {
        print('[TxRepo] error (null) — keeping previous state');
      }
    } catch (e) {
      print('[TxRepo] exception: $e');
    } finally {
      _fetching = false;
    }
  }
}
