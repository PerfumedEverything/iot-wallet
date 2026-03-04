import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/models/transaction.dart';
import 'package:iot_wallet/models/wallet.dart';
import 'package:iot_wallet/services/transaction_repository.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'package:iot_wallet/widgets/back_button.dart';
import 'package:iot_wallet/widgets/transaction_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool copied = false;
  Wallet? _activeWallet;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  final _repo = TransactionRepository.instance;

  @override
  void initState() {
    super.initState();
    _transactions = _repo.transactionsNotifier.value;
    _isLoading = _repo.isLoadingNotifier.value;
    _repo.transactionsNotifier.addListener(_onTransactionsChanged);
    _repo.isLoadingNotifier.addListener(_onLoadingChanged);
    _loadActiveWallet();
  }

  @override
  void dispose() {
    _repo.transactionsNotifier.removeListener(_onTransactionsChanged);
    _repo.isLoadingNotifier.removeListener(_onLoadingChanged);
    super.dispose();
  }

  void _onTransactionsChanged() {
    if (!mounted) return;
    setState(() => _transactions = _repo.transactionsNotifier.value);
  }

  void _onLoadingChanged() {
    if (!mounted) return;
    setState(() => _isLoading = _repo.isLoadingNotifier.value);
  }

  Future<void> _loadActiveWallet() async {
    final wallet = await WalletService.getActiveWallet();
    setState(() => _activeWallet = wallet);
    if (wallet != null) {
      _repo.startWatching(
        wallet.address,
        initialDelay: const Duration(milliseconds: 600),
      );
    }
  }

  Future<void> _copy() async {
    if (_activeWallet == null) return;
    await Clipboard.setData(ClipboardData(text: _activeWallet!.address));
    setState(() => copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => copied = false);
  }

  List<_DateGroup> _groupByDate(List<Transaction> txs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<String, List<Transaction>> map = {};
    final List<String> order = [];

    for (final tx in txs) {
      final txDay = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final diff = today.difference(txDay).inDays;

      final String label;
      if (diff == 0) {
        label = 'Today';
      } else if (diff == 1) {
        label = 'Yesterday';
      } else {
        label = '$diff days ago';
      }

      if (!map.containsKey(label)) {
        map[label] = [];
        order.add(label);
      }
      map[label]!.add(tx);
    }

    return order.map((label) => _DateGroup(label, map[label]!)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = 120.0 + MediaQuery.of(context).viewPadding.bottom;

    return SafeArea(
      child: Stack(
        children: [
          // Glow background
          Positioned(
            top: -150,
            left: -200,
            child: Container(
              width: 400,
              height: 700,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromARGB(18, 27, 89, 234),
                    Color.fromARGB(27, 35, 36, 57),
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 20,
            left: 20,
            child: BackSvgButton(
              asset: 'assets/ic_back.svg',
              size: 27,
              color: Colors.white,
              hoverColor: const Color(0xFF3A6DF7),
              tapColor: const Color(0xFF3A6DF7),
              onTap: () {
                bottomTabIndex.value = 0;
              },
            ),
          ),

          // Content
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---- fixed top section ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ADDRESS CHIP
                      Center(
                        child: GestureDetector(
                          onTap: _copy,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2F47),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/ic_app.png',
                                    width: 17, height: 17),
                                const SizedBox(width: 6),
                                Text(
                                  _activeWallet != null &&
                                          _activeWallet!.address.length > 12
                                      ? '${_activeWallet!.address.substring(0, 6)}...${_activeWallet!.address.substring(_activeWallet!.address.length - 6)}'
                                      : (_activeWallet?.address ?? 'No wallet'),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SvgPicture.asset(
                                  'assets/ic_copy.svg',
                                  width: 17,
                                  height: 17,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      const Center(
                        child: Text(
                          'All History',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),

                // ---- scrollable transactions area ----
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6D8BFF)),
                          ),
                        )
                      : _transactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/ic_history.png',
                                      width: 90, height: 90),
                                  const SizedBox(height: 7),
                                  const Text(
                                    'History not found',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFCECECE),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding: EdgeInsets.only(
                                left: 24,
                                right: 24,
                                bottom: bottomPad,
                              ),
                              children: [
                                for (final group
                                    in _groupByDate(_transactions)) ...[
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      group.label,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ...group.transactions.map(
                                    (tx) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: TransactionCard(transaction: tx),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                ),
              ],
            ),
          ),

          // COPY TOAST
          Positioned(
            left: 0,
            right: 0,
            top: 12,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: copied ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Address wallet copied',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF0D1B2A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check, color: Color(0xFF0D1B2A), size: 18),
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

class _DateGroup {
  final String label;
  final List<Transaction> transactions;
  _DateGroup(this.label, this.transactions);
}
