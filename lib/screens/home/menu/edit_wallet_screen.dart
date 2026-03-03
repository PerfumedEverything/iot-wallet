import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/models/wallet.dart';
import 'package:iot_wallet/screens/create/create_screen.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'package:iot_wallet/widgets/back_button.dart';
import 'package:iot_wallet/widgets/cancel_button.dart';
import 'package:iot_wallet/widgets/copy_icon.dart';
import 'package:iot_wallet/widgets/delete_wallet_button.dart';
import 'package:iot_wallet/widgets/universal_button.dart';

class EditWalletScreen extends StatefulWidget {
  const EditWalletScreen({super.key});

  @override
  State<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends State<EditWalletScreen> {
  bool copied = false;
  bool _isHovered = false;
  bool _isTapped = false;
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
      backgroundColor: const Color(0xFF1E2235),
      body: Stack(
        
        children: [
          Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0xFF232439)
                  ),
                ),
              ),
          SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -150,
                left: -150,
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
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: 170,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0xFF282B46)
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
        
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
        
                    /// top bar: Edit wallet + Done
                    SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Center(
                            child: Text(
                              "Edit wallet",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        
                    const SizedBox(height: 18),
        
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                _activeWallet?.name ?? "No wallet",
                                maxLines: 1,
                                minFontSize: 14,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    _activeWallet != null && _activeWallet!.address.length > 12
                                      ? '${_activeWallet!.address.substring(0, 6)}...${_activeWallet!.address.substring(_activeWallet!.address.length - 6)}'
                                      : (_activeWallet?.address ?? "No wallet"),
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFAAAAAA),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CopyIcon(onTap: _copy, size: 17, defaultColor: Color(0xFFAAAAAA),)
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Права іконка — автоматично по центру завдяки crossAxisAlignment.center
                        StatefulBuilder(
                          builder: (context, setState) {
                            return MouseRegion(
                              onEnter: (_) => setState(() => _isHovered = true),
                              onExit: (_) => setState(() => _isHovered = false),
                              child: GestureDetector(
                                onTapDown: (_) => setState(() => _isTapped = true),
                                onTapUp: (_) => setState(() => _isTapped = false),
                                onTapCancel: () => setState(() => _isTapped = false),
                                onTap: () {
                                  _showRenameDialog();
                                },
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: (_isHovered || _isTapped)
                                      ? const Color(0xFF7B7FDB)
                                      : Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
        
                    const SizedBox(height: 40),
        
                    /// option row
                    GestureDetector(
                      onTap: () {
                        _showSeedPhraseSheet();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 21),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              "View seed phrase",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.chevron_right,
                                color: Color(0xFFB5B8D6)),
                          ],
                        ),
                      ),
                    ),
        
                    const SizedBox(height: 22),
        
                    /// delete button (outline red)
                    DeleteWalletButton(onTap: () {
                      _showDeleteBottomSheet();
                    }),
        
                    const Spacer(),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
        
              /// toast copied
              Positioned(
                left: 0,
                right: 0,
                top: 12,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: copied ? 1 : 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Address wallet copied",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.check,
                                size: 18, color: Color(0xFF0D1B2A)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ]
      ),
    );
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _activeWallet?.name ?? "");

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _RenameWalletSheet(
            controller: controller,
            onCancel: () {
              Navigator.pop(context);
            },
            onConfirm: () async {
              if (_activeWallet != null) {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await WalletService.updateWalletName(_activeWallet!.id, newName);
                  setState(() {
                    _activeWallet = _activeWallet!.copyWith(name: newName);
                  });
                }
              }
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDeleteBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _DeleteWalletSheet(
          onDelete: () async {
            if (_activeWallet != null) {
              await WalletService.deleteWallet(_activeWallet!.id);
              Navigator.pop(context);
              navigatorKey.currentState?.pop();
            }
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showSeedPhraseSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SeedPhraseBottomSheet(seed: _activeWallet?.seed ?? "");
      },
    );
  }

}

class _SeedPhraseBottomSheet extends StatefulWidget {
  final String seed;

  const _SeedPhraseBottomSheet({
    this.seed = "",
  });

  @override
  State<_SeedPhraseBottomSheet> createState() => _SeedPhraseBottomSheetState();
}

class _SeedPhraseBottomSheetState extends State<_SeedPhraseBottomSheet> {
  late final List<String> words;
  bool isHidden = true;
  OverlayEntry? _toastEntry;

  @override
  void initState() {
    super.initState();
    // Разбиваем seed фразу на слова
    words = widget.seed.split(' ');
    // Если слов меньше 12,填充 пустыми
    while (words.length < 12) {
      words.add('');
    }
  }

  void _showToast() {
    _toastEntry?.remove();

    _toastEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 80,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Secret phrase copied",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.check, size: 18, color: Color(0xFF0D1B2A)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_toastEntry!);

    Future.delayed(const Duration(seconds: 2), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  Future<void> _copyPhrase() async {
    final phrase = words.join(" ");
    await Clipboard.setData(ClipboardData(text: phrase));
    _showToast();
  }

  @override
  void dispose() {
    _toastEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
        decoration: const BoxDecoration(
          color: Color(0xFF20233B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
      
            /// Top bar
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const Spacer(),
                const Text(
                  "View seed phrase",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 24),
              ],
            ),
      
            const SizedBox(height: 18),
      
            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isHidden ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF7084FF),
                    size: 18,
                  ),
                  onPressed: () => setState(() => isHidden = !isHidden),
                ),
              ],
            ),
      
            const SizedBox(height: 8),
      
            /// Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.96,
              ),
              itemBuilder: (context, index) {
                return WordTile(
                  word: isHidden ? "******" : words[index],
                  index: index + 1,
                );
              },
            ),
      
            const SizedBox(height: 24),
      
            UniversalButton(
              label: "Backup phrase",
              onPressed: _copyPhrase,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteWalletSheet extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const _DeleteWalletSheet({
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 34),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2D4A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
      
            /// Icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Text(
                  "!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2235),
                  ),
                ),
              ),
            ),
      
            const SizedBox(height: 22),
      
            /// Title
            const Text(
              "Are you sure want to delete your wallet?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
      
            const SizedBox(height: 16),
      
            /// Description
            const Text(
              "Make sure to back up your wallet before deleting it. If you lose your recovery phrase, your assets cannot be recovered.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB5B8D6),
                height: 1.5,
              ),
            ),
      
            const SizedBox(height: 28),
      
            /// Delete button
            DeleteWalletButton(
              onTap: onDelete,
            ),
      
            const SizedBox(height: 20),
      
            /// Cancel
            GestureDetector(
              onTap: onCancel,
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RenameWalletSheet extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _RenameWalletSheet({
    required this.controller,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_RenameWalletSheet> createState() => _RenameWalletSheetState();
}

class _RenameWalletSheetState extends State<_RenameWalletSheet> {
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _isValid = _controller.text.trim().isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
        decoration: const BoxDecoration(
          color: Color(0xFF20233B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter a new wallet name",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
      
            const SizedBox(height: 24),
      
            const Text(
              "New wallet name",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB5B8D6),
              ),
            ),
      
            const SizedBox(height: 10),
      
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3D5E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                style: const TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Wallet 1",
                  hintStyle: TextStyle(
                    color: Color(0xFF888AAA),
                  ),
                ),
              ),
            ),
      
            const SizedBox(height: 28),
      
            Row(
              children: [
                Expanded(
                  child: CancelButton(onTap: widget.onCancel),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: UniversalButton(
                    label: "Confirm",
                    onPressed: _isValid ? widget.onConfirm : null,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}