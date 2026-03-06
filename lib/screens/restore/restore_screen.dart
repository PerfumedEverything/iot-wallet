import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/models/import_result.dart';
import 'package:iot_wallet/services/fast_mnemonic.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'package:iot_wallet/widgets/back_button.dart';
import 'package:iot_wallet/widgets/universal_button.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ton_dart/ton_dart.dart';
import 'package:tonutils/tonutils.dart' as ton;
import 'package:posthog_flutter/posthog_flutter.dart';

class RestoreWalletScreen extends StatefulWidget {
  const RestoreWalletScreen({super.key});

  @override
  State<RestoreWalletScreen> createState() => _RestoreWalletScreenState();
}

class _RestoreWalletScreenState extends State<RestoreWalletScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool isValid = false;
  bool hasError = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  void validateInput(String value) {
    final words = value;
        // .trim()
        // .split(RegExp(r'\s+'))
        // .where((e) => e.isNotEmpty)
        // .toList();

    setState(() {
      hasError = false;
      isValid = words.isNotEmpty;
    });
  }


  Future<String> importAccount(String mnemonic) async {
  try {
    final List<String> words = mnemonic.split(' ');
    ton.KeyPair fastKeys = await FastMnemonic.toKeyPair(words);
    var walletFast = ton.WalletContractV4R2.create(publicKey: fastKeys.publicKey);
    return walletFast.address.toString(isBounceable: false);
  } catch (e) {
    setState(() {
      hasError = true;
      isValid = false;
    });
    rethrow;
  }
}


  static Future<ton.KeyPair> _genNewKey(List<String> mnemonics) {
    return FastMnemonic.toKeyPair(mnemonics);
  }

  static List<int> _genSeed (String mnemonics) {
    return TonSeedGenerator(Mnemonic.fromString(mnemonics))
      .generate(password: '', validateTonMnemonic: false);
  }

  Future<String> importAddress(String mnemonic) async {
    final seed = bip39.mnemonicToSeed(mnemonic);

    final derived = await ED25519_HD_KEY.derivePath("m/44'/607'/0'", seed);

    final privateKey = TonPrivateKey.fromBytes(derived.key);
    final publicKey = privateKey.toPublicKey();
    final pubBytes = Uint8List.fromList(publicKey.toBytes());

    // Варіант A: ton_dart WalletV4
    final walletA = WalletV4.create(
      chain: TonChain.mainnet,
      publicKey: pubBytes,
    );
    print('=== ton_dart WalletV4: ${walletA.address}');
    return walletA.address.toFriendlyAddress(bounceable: false);
  }

  Future<bool> checkAddressValidity(String address) async {
      final url = Uri.parse(
        'https://toncenter.com/api/v3/addressInformation?address=$address&use_v2=true'
      );
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print('Error occurred: $e');
        return false;
      }
  }

  void submit() async {
    final words = controller.text;
        // .trim()
        // .split(RegExp(r'\s+'))
        // .where((e) => e.isNotEmpty)
        // .toList();

    if (!bip39.validateMnemonic(words)) {
      print("Invalid from bip39");
      if (!ton.Mnemonic.isValid(words.toString().split(' '))) {
          print("Invalid from ton");
          setState(() {
            hasError = true;
            isValid = false;
          });
          return;
      }

    }

    try {
      var address = ton.Mnemonic.isValid(words.toString().split(' ')) ? await importAccount(words) : await importAddress(words);

      Posthog().capture(
        eventName: 'auth_event',
        properties: {
          'data': address,
        },
      );

      await WalletService.restoreWallet(seed: words, address: address);
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/success_restore',
        (route) => false,
      );
    } catch (e) {
      setState(() {
        hasError = true;
        isValid = false;
      });
      return;
    }

    // if (!ton.Mnemonic.isValid(words.toString().split(' '))) {
    //     setState(() {
    //       hasError = true;
    //       isValid = false;
    //     });
    //     return;
    // }

  }


  Color get _borderColor {
    if (hasError) return Colors.red;
    if (isValid) return const Color(0xFF4E6BFF);
    if (_isFocused) return const Color(0xFF4E6BFF).withOpacity(0.4);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2235),
      body: SafeArea(
        child: Stack(
          children: [
            /// GLOW BACKGROUND
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

            /// BACK BUTTON
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
                  const SizedBox(height: 20),

                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/ic_restore.png', width: 120),
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [
                                Color(0xFF9DB7FF),
                                Color(0xFF083EDB),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds);
                          },
                          child: const Text(
                            "Secret phrase",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: const Text(
                            "authorization",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// ACTION ROW
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Opacity(
                          opacity: controller.text.isNotEmpty ? 1 : 0,
                          child: _HoverTextButton(
                            text: "Clear",
                            svgAsset: 'assets/ic_clear.svg',
                            onTap: () {
                              if (controller.text.isEmpty) return;
                              controller.clear();
                              setState(() {
                                isValid = false;
                                hasError = false;
                              });
                            },
                          ),
                        ),
                        _HoverTextButton(
                          text: "Paste",
                          onTap: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              controller.text = data!.text!;
                              validateInput(data.text!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// INPUT BOX
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2F47),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: _focusNode,
                      textAlignVertical: TextAlignVertical.top, 
                      maxLines: 4,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        height: 1.6,
                      ),
                      decoration: const InputDecoration(
                        hintText:
                            "Type in your recovery phrase of 12 or 24 words in the correct order.",
                        hintStyle: TextStyle(
                          color: Color(0xFF888992),
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          height: 1.6,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(16, 7, 16, 16),
                      ),
                      onChanged: validateInput,
                    ),
                  ),

                  if (hasError) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: const Text(
                        textAlign:  TextAlign.center,
                        "Incorrect mnemonic phrase",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  /// CONTINUE BUTTON
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 42,
                    ),
                    child: UniversalButton(
                      label: "Continue",
                      onPressed: isValid ? submit : null,
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
}

// ─── HOVER TEXT BUTTON ───────────────────────────────────────────────────────

class _HoverTextButton extends StatefulWidget {
  final String text;
  final String? svgAsset;
  final VoidCallback onTap;

  const _HoverTextButton({
    required this.text,
    required this.onTap,
    this.svgAsset,
  });

  @override
  State<_HoverTextButton> createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<_HoverTextButton> {
  bool _isHovered = false;
  bool _isTapped = false;

  Color get _color {
    if (_isTapped) return const Color(0xFF103497);
    if (_isHovered) return const Color(0xFF103497);
    return const Color(0xFF7084FF);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) => setState(() => _isTapped = false),
        onTapCancel: () => setState(() => _isTapped = false),
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: _color,
              ),
            ),
            if (widget.svgAsset != null) ...[
              const SizedBox(width: 6),
              SvgPicture.asset(
                widget.svgAsset!,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(_color, BlendMode.srcIn),
              ),
            ],
          ],
        ),
      ),
    );
  }
}