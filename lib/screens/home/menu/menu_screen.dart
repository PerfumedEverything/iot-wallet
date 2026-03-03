import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/models/wallet.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'package:iot_wallet/widgets/back_button.dart';
import 'package:iot_wallet/widgets/copy_icon.dart';
import 'package:iot_wallet/widgets/universal_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int selectedIndex = 0;
  bool _copied = false;
  List<Wallet> _wallets = [];
  Wallet? _activeWallet;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final wallets = await WalletService.getAllWallets();
    final active = await WalletService.getActiveWallet();

    if (wallets.isEmpty) {
      if (mounted) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/welcome',
          (route) => false,
        );
      }
      return;
    }

    final activeWallet = active ?? wallets.first;

    final reordered = List.of(wallets);

    reordered.removeWhere((w) => w.id == activeWallet.id);
    reordered.add(activeWallet); 

    setState(() {
      _wallets = reordered;
      _activeWallet = activeWallet;
      selectedIndex = 0; 
    });
  }

  Future<void> _copy(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  Future<void> _selectWallet(Wallet wallet) async {
    await WalletService.setActiveWallet(wallet.id);
    setState(() {
      _activeWallet = wallet;
      selectedIndex = _wallets.indexOf(wallet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
        /// glow
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
                  bottomTabIndex.value = 0;
                  //navigatorKey.currentState?.pop();
                },
              ),
            ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),

                /// Top bar
                SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: Text(
                          "My wallets",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(context, "/edit_wallet");
                            // Перезавантажуємо список після повернення з EditWalletScreen
                            _loadWallets();
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit,
                                  size: 16, color: Color(0xFF7084FF)),
                              SizedBox(width: 6),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7084FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: Builder(
                    builder: (context) => ListView.separated(
                      padding: EdgeInsets.only(
                        bottom: 12,
                      ),
                      itemCount: _wallets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final wallet = _wallets[_wallets.length - 1 - i];
                        final selected = wallet.id == _activeWallet?.id;
                        return GestureDetector(
                          onTap: () => _selectWallet(wallet),
                          child: _WalletTile(
                            wallet: wallet,
                            selected: selected,
                            onCopy: () => _copy(wallet.address),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                /// Add wallet button
                UniversalButton(
                  label: 'Add a wallet',
                  onPressed: () {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      '/welcome',
                      (route) => true,
                    );
                  },
                  width: double.infinity,
                ),

                SizedBox(height: 120 + MediaQuery.of(context).viewPadding.bottom),
              ],
            ),
          ),

          Positioned(
              left: 0,
              right: 0,
              top: 12,
              child: AnimatedOpacity(
                opacity: _copied ? 1.0 : 0.0,
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
    );
  }
}

class _WalletTile extends StatelessWidget {
  final Wallet wallet;
  final bool selected;
  final VoidCallback onCopy;

  const _WalletTile({required this.wallet, required this.selected, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF373959),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xFF3A6DF7).withOpacity(0.5) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "TON 0",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB5B8D6),
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: onCopy,
                      child: Text(
                        wallet.address.length > 12 
                          ? '${wallet.address.substring(0, 6)}...${wallet.address.substring(wallet.address.length - 6)}'
                          : wallet.address,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB5B8D6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    CopyIcon(
                      size: 14,
                      onTap: onCopy,
                      defaultColor: Color(0xFFB5B8D6),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            selected ? Icons.check_rounded : Icons.check_rounded,
            size: 22,
            color: selected ? const Color(0xFF3A6DF7) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}