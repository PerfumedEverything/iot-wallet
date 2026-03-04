import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/models/wallet.dart';
import 'package:iot_wallet/services/price_service.dart';
import 'package:iot_wallet/services/send_service.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'package:iot_wallet/widgets/back_button.dart';
import 'package:iot_wallet/widgets/universal_button.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool addressFocused = false;
  bool amountFocused = false;

  // Per-field error messages
  String? _addressError;
  String? _amountError;

  // Sending state
  bool _isSending = false;

  Wallet? _activeWallet;
  String _balance = '0.00';
  String _usdValue = '\$0.00';
  Timer? _balanceTimer;
  final PriceService _priceService = PriceService();

  @override
  void initState() {
    super.initState();
    _loadActiveWallet();
    _startBalanceTimer();
    _priceService.priceNotifier.addListener(_onPriceChanged);
    _updateUsdValue();
  }

  @override
  void dispose() {
    _balanceTimer?.cancel();
    _priceService.priceNotifier.removeListener(_onPriceChanged);
    addressController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _onPriceChanged() => _updateUsdValue();

  void _startBalanceTimer() {
    _balanceTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (_activeWallet != null) _loadBalance(_activeWallet!.address);
    });
  }

  Future<void> _loadActiveWallet() async {
    final wallet = await WalletService.getActiveWallet();
    setState(() => _activeWallet = wallet);
    if (wallet != null) _loadBalance(wallet.address);
  }

  Future<void> _loadBalance(String address) async {
    try {
      final balance = await WalletService.getBalance(address);
      if (mounted) setState(() => _balance = balance);
      _updateUsdValue();
    } catch (_) {}
  }

  void _updateUsdValue() {
    try {
      final b = double.parse(_balance);
      final p = double.parse(_priceService.getPrice());
      if (mounted) setState(() => _usdValue = '\$${(b * p).toStringAsFixed(2)}');
    } catch (_) {
      if (mounted) setState(() => _usdValue = '\$0.00');
    }
  }

  // ── Step 1: validate fields ─────────────────────────────────────────────────

  bool _validateFields() {
    final addressErr =
        SendService.validateAddressFormat(addressController.text);
    final amountErr = SendService.validateAmount(
      amountController.text,
      double.tryParse(_balance) ?? 0.0,
    );

    setState(() {
      _addressError = addressErr;
      _amountError = amountErr;
    });

    print('[SendScreen] step 1 — address error: $addressErr');
    print('[SendScreen] step 1 — amount  error: $amountErr');

    return addressErr == null && amountErr == null;
  }

  // ── Steps 2+3: sign & send ──────────────────────────────────────────────────

  Future<void> _onSendPressed() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_validateFields()) return;

    if (_activeWallet == null) {
      setState(() => _amountError = 'No active wallet found');
      return;
    }

    setState(() => _isSending = true);

    print('[SendScreen] step 2+3 — starting send');
    print('[SendScreen]   from   : ${_activeWallet!.address}');
    print('[SendScreen]   to     : ${addressController.text.trim()}');
    print('[SendScreen]   amount : ${amountController.text.trim()} TON');
    print('[SendScreen]   balance: $_balance TON');

    try {
      final error = await SendService.send(
        seedPhrase: _activeWallet!.seed,
        fromAddress: _activeWallet!.address,
        toAddress: addressController.text.trim(),
        amountTon: double.parse(amountController.text.trim().replaceAll(',', '.')),
        balance: double.tryParse(_balance) ?? 0.0,
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () => 'Transaction timeout. The operation took too long. Please try again.',
      );

      if (!mounted) return;
      setState(() => _isSending = false);

      if (error == null) {
        print('[SendScreen] step 3 — success, showing dialog');
        _showSuccessDialog();
      } else {
        print('[SendScreen] step 3 — error: $error');
        setState(() => _amountError = error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      print('[SendScreen] step 3 — exception: $e');
      setState(() => _amountError = 'An unexpected error occurred. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFF2A2F47),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🚀',
                    style: TextStyle(fontSize: 56)),
                const SizedBox(height: 20),
                const Text(
                  'Successful transaction',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your transaction has been successfully sent. The recipient will receive your transfer shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB5B8D6),
                  ),
                ),
                const SizedBox(height: 28),
                UniversalButton(
                  label: 'Done',
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    navigatorKey.currentState?.pop();
                  },
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232439),
      body: SafeArea(
        child: Stack(
          children: [
            // BACKGROUND GLOW
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

            Positioned(
              top: 20,
              left: 20,
              child: BackSvgButton(
                asset: 'assets/ic_back.svg',
                size: 27,
                color: Colors.white,
                hoverColor: const Color(0xFF3A6DF7),
                tapColor: const Color(0xFF3A6DF7),
                onTap: () => navigatorKey.currentState?.pop(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // TOP BAR
                  const SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        'Send coins',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // BALANCE
                  const Center(
                    child: Text(
                      'Current Balance',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7084FF),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text.rich(TextSpan(children: [
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
                    ])),
                  ),
                  Center(
                    child: Text(
                      '$_usdValue USD',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF696B82),
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 21),

                  // RECEIVING ADDRESS
                  const Text(
                    'Receiving address',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Focus(
                    onFocusChange: (v) => setState(() => addressFocused = v),
                    child: _inputContainer(
                      focused: addressFocused,
                      error: _addressError != null,
                      child: TextField(
                        controller: addressController,
                        onChanged: (_) =>
                            setState(() => _addressError = null),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Enter the recipient's address here",
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF888992),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  if (_addressError != null) ...[
                    const SizedBox(height: 6),
                    _errorRow(_addressError!),
                  ],

                  const SizedBox(height: 20),

                  // TRANSFER AMOUNT
                  const Text(
                    'Transfer amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Focus(
                    onFocusChange: (v) => setState(() => amountFocused = v),
                    child: _inputContainer(
                      focused: amountFocused,
                      error: _amountError != null,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              onChanged: (_) =>
                                  setState(() => _amountError = null),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.,]')),
                                LengthLimitingTextInputFormatter(15),
                              ],
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Amount',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF888992),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Text(
                            'TON',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF888992),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                              width: 1.1, height: 21, color: const Color(0xFF888992)),
                          const SizedBox(width: 12),
                          Image.asset('assets/ic_app.png',
                              width: 17, height: 17),
                        ],
                      ),
                    ),
                  ),
                  if (_amountError != null) ...[
                    const SizedBox(height: 6),
                    _errorRow(_amountError!),
                  ],

                  const Spacer(),

                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.only(top: 10, bottom: 42),
                    child: _isSending
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6D8BFF), Color(0xFF2D5BFF)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                          )
                        : UniversalButton(
                            label: 'Send',
                            onPressed: _onSendPressed,
                            width: double.infinity,
                          ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorRow(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            'assets/ic_error_red.svg',
            width: 16,
            height: 16,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputContainer({
    required Widget child,
    required bool focused,
    required bool error,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F47),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: error
              ? Colors.red
              : focused
                  ? const Color(0xFF6D8BFF)
                  : Colors.white.withOpacity(0.06),
        ),
      ),
      child: child,
    );
  }
}
