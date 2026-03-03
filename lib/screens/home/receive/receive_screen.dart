import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/models/wallet.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'package:iot_wallet/widgets/back_button.dart';
import 'package:iot_wallet/widgets/copy_icon.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  bool copied = false;
  Wallet? _activeWallet;

  @override
  void initState() {
    super.initState();
    _loadActiveWallet();
  }

  Future<void> _loadActiveWallet() async {
    final wallet = await WalletService.getActiveWallet();
    setState(() => _activeWallet = wallet);
  }

  Future<void> _copy() async {
    if (_activeWallet == null) return;
    await Clipboard.setData(ClipboardData(text: _activeWallet!.address));
    setState(() => copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232439),
      body: SafeArea(
        child: Stack(
          children: [
            /// GLOW
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
                hoverColor: Color(0xFF3A6DF7),
                tapColor: Color(0xFF3A6DF7),
                onTap: () {
                  navigatorKey.currentState?.pop();
                },
              ),
            ),

            /// TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "Receive coins",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// CARD WITH QR
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF373959),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFFFFFFF).withOpacity(0.06),
                          width: 1.07,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Scan the QR",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),

                        /// QR BLOCK
                        Container(
                          width: 202,
                          height: 202,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            "assets/ic_qr.png",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              // якщо нема картинки — покажемо placeholder
                              return const Center(
                                child: Icon(Icons.qr_code_2, size: 72),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          "Please scan the QR code or copy the\ngenerated address to deposit funds\nto your cryptocurrency address.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFAAAAAA),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ADDRESS PILL (copy)
                  GestureDetector(
                    onTap: _copy,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF373959),
                        borderRadius: BorderRadius.circular(22),
                        border: Border(
                        top: BorderSide(
                          color: const Color(0xFFFFFFFF).withOpacity(0.06),
                          width: 1.07,
                        ),
                      ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _activeWallet?.address ?? "No wallet",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          /// copy icon (changes when copied)
                          CopyIcon(
                            onTap: _copy,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              top: 12,
              child: AnimatedOpacity(
                opacity: copied ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
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


          ],
        ),
      ),
    );
  }
}