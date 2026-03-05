import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/models/transaction.dart';
import 'package:iot_wallet/models/wallet.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'package:iot_wallet/services/price_service.dart';
import 'package:iot_wallet/services/transaction_repository.dart';
import 'package:iot_wallet/widgets/transaction_card.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool copied = false;
  Wallet? _activeWallet;
  String _balance = '0.00';
  String _usdValue = '\$0.00';
  List<Transaction> _transactions = [];
  bool _isLoadingTx = true;
  Timer? _balanceTimer;
  final _repo = TransactionRepository.instance;
  final PriceService _priceService = PriceService();

  @override
  void initState() {
    super.initState();
    _transactions = _repo.transactionsNotifier.value.take(5).toList();
    _isLoadingTx = _repo.isWatching
        ? _repo.isLoadingNotifier.value
        : true;
    _repo.transactionsNotifier.addListener(_onTransactionsChanged);
    _repo.isLoadingNotifier.addListener(_onLoadingChanged);
    _loadActiveWallet();
    _startBalanceTimer();
    _priceService.priceNotifier.addListener(_onPriceChanged);
    _updateUsdValue();
  }

  @override
  void dispose() {
    _balanceTimer?.cancel();
    _priceService.priceNotifier.removeListener(_onPriceChanged);
    _repo.transactionsNotifier.removeListener(_onTransactionsChanged);
    _repo.isLoadingNotifier.removeListener(_onLoadingChanged);
    super.dispose();
  }

  void _onTransactionsChanged() {
    if (!mounted) return;
    setState(() {
      _transactions = _repo.transactionsNotifier.value.take(5).toList();
    });
  }

  void _onLoadingChanged() {
    if (!mounted) return;
    setState(() => _isLoadingTx = _repo.isLoadingNotifier.value);
  }

  void _onPriceChanged() {
    _updateUsdValue();
  }

  void _startBalanceTimer() {
    _balanceTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (_activeWallet != null) {
        _loadBalance(_activeWallet!.address);
      }
    });
  }

  Future<void> _loadActiveWallet() async {
    final wallet = await WalletService.getActiveWallet();
    setState(() => _activeWallet = wallet);
    if (wallet != null) {
      await _loadBalance(wallet.address);
      _repo.startWatching(
        wallet.address,
        initialDelay: const Duration(milliseconds: 600),
      );
    }
  }

  Future<void> _loadBalance(String address) async {
    try {
      final balance = await WalletService.getBalance(address);
      if (mounted) setState(() => _balance = balance);
      _updateUsdValue();
    } catch (e) {
      // ignore
    }
  }

  void _updateUsdValue() {
    try {
      final balanceNum = double.parse(_balance);
      final priceNum = double.parse(_priceService.getPrice());
      setState(() => _usdValue = '\$${(balanceNum * priceNum).toStringAsFixed(2)}');
    } catch (e) {
      setState(() => _usdValue = '\$0.00');
    }
  }

  Future<void> _copyAddress(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    setState(() => copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = 120.0 + MediaQuery.of(context).viewPadding.bottom;

    return Stack(
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

        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---- fixed top section ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // ADDRESS CHIP
                    GestureDetector(
                      onTap: () {
                        if (_activeWallet != null) {
                          _copyAddress(_activeWallet!.address);
                        }
                      },
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

                    const SizedBox(height: 21),

                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7084FF),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$_balance ',
                            style: const TextStyle(
                              fontSize: 38,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: 'TON',
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '$_usdValue USD',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF696B82),
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '1 TON = \$${_priceService.getPrice()}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF696B82),
                            fontSize: 13,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_up_sharp,
                          color: Color(0xFF47D653),
                          size: 30,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: ActionButtonContent(
                            text: 'Send',
                            iconPath: 'assets/ic_send.svg',
                            onTap: () {
                              navigatorKey.currentState?.pushNamed('/send');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ActionButtonContent(
                            text: 'Receive',
                            iconPath: 'assets/ic_receive.svg',
                            onTap: () {
                              navigatorKey.currentState?.pushNamed('/receive');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recent transactions',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // ---- scrollable transactions area ----
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 24, right: 24, bottom: bottomPad),
                  child: _isLoadingTx
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
                                      width: 77, height: 77),
                                  const SizedBox(height: 7),
                                  const Text(
                                    'History not found',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFCECECE),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _transactions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) =>
                                  TransactionCard(
                                      transaction: _transactions[index]),
                            ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
    );
  }
}

class ActionButtonContent extends StatefulWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onTap;

  const ActionButtonContent({
    super.key,
    required this.text,
    required this.iconPath,
    this.onTap,
  });

  @override
  State<ActionButtonContent> createState() => ActionButtonContentState();
}

class ActionButtonContentState extends State<ActionButtonContent> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgGradient = !isPressed
        ? const LinearGradient(
            colors: [Color(0xFF6D8BFF), Color(0xFF2D5BFF)],
          )
        : null;

    final bgColor = isPressed ? const Color(0xFF2A2F47) : null;

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration.zero,
        padding: const EdgeInsets.only(bottom: 12, top: 14),
        decoration: BoxDecoration(
          gradient: bgGradient,
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              widget.iconPath,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
