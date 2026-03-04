import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'package:iot_wallet/widgets/back_button.dart';
import 'package:iot_wallet/widgets/universal_button.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {

  final List<String> words = [
    "vacuum","you","close",
    "velvet","remember","gesture",
    "donkey","damage","antique",
    "cigar","cream","friend"
  ];

  bool isHidden = true;
  bool isCopied = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2235),
      body: SafeArea(
        child: Stack(
          children: [
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
                          stops: [0.0, 1.0],
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
            
                
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Transform.translate(
                          offset: const Offset(0, 0),
                            child:const Text(
                              "Creating",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                            ),
                        )),
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "a new ",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
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
                                  "wallet",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                            ),
                            ]
                          ), 
                    
                          
                      ),
                    ]
                  ),
                ),
                    
                Center(
                  child: const Text(
                    "Your secret phrase",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                    
                const SizedBox(height: 6),
                    
                const Text(
                  "This 12-word phrase is the only way to restore your wallet if access is lost. Write it down in order and keep it safe. Anyone with this phrase can use your funds. Keep it private.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666BA5),
                  ),
                ),
                    
                const SizedBox(height: 4),
                    
                /// ACTION ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        isHidden ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF7084FF),
                        size: 17,
                      ),
                      onPressed: () {
                        setState(() {
                          isHidden = !isHidden;
                        });
                      },
                    ),
                    const SizedBox(width: 0),
                    GestureDetector(
                      onTap: isCopied
                          ? null 
                          : () async {
                             
                              await Clipboard.setData(
                                ClipboardData(text: words.join(' ')),
                              );
                              setState(() {
                                isCopied = true;
                              });
                              await Future.delayed(const Duration(seconds: 3));
                              setState(() {
                                isCopied = false;
                              });
                            },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isCopied
                            ? SvgPicture.asset(
                                'assets/ic_cp_success.svg',
                                key: const ValueKey('check'),
                                width: 17,
                                height: 17,
                                colorFilter: const ColorFilter.mode(
                                  Colors.green,
                                  BlendMode.srcIn,
                                ),
                              )
                            : SvgPicture.asset(
                                'assets/ic_copy.svg',
                                key: const ValueKey('copy'),
                                width: 17,
                                height: 17,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF7084FF),
                                  BlendMode.srcIn,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),      
                    
                Expanded(
                  child: GridView.builder(
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
                ),
                    
                /// CONTINUE BUTTON
                UniversalButton(
                    label: 'Continue',
                    onPressed: () async {
                      final seedPhrase = words.join(' ');

                      
                      await WalletService.createWallet(seed: seedPhrase);
                      
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        '/success_create',
                        (route) => false,
                      );
                    },
                    width: double.infinity,
                  ),
                  SizedBox(height: 42,)
              ],
            ),
                      ),
          
          
         Positioned(
              left: 0,
              right: 0,
              top: 12,
              child: AnimatedOpacity(
                opacity: isCopied ? 1.0 : 0.0,
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
                          'Secret phrase copied',
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
          
          ]
            
        
        ),
      ),
    );
  }
}

class WordTile extends StatelessWidget {
  final String word;
  final int index;

  const WordTile({
    required this.word,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2F47),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              word,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Poppins",
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$index",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 11,
          ),
        )
      ],
    );
  }
}