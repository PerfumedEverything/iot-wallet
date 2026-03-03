import 'package:flutter/material.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkWalletAndNavigate();
  }

  Future<void> _checkWalletAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final hasWallets = await WalletService.hasWallets();
    
    if (mounted) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        hasWallets ? '/home' : '/welcome',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232439), Color(0xFF232439)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Stack(
              children: [
                Positioned(
                  bottom: 250,
                  left: -100,
                  child: Container(
                    width: 450,
                    height: 450,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color.fromARGB(23, 27, 89, 234), // центр glow
                          Color.fromARGB(17, 35, 36, 57), // прозорий край
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: -100,
                  child: Container(
                    width: 600,
                    height: 400,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color.fromARGB(16, 27, 89, 234), // центр glow
                          Color.fromARGB(69, 35, 36, 57), // прозорий край
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 1,),
                    // Logo and text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(  
                        'assets/ic_app.png',
                        width: 185,
                        height: 185,
                      ),
                      const SizedBox(height: 32),
                     Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                              "IOT ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Text(
                            "Wallet",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Spacer(flex: 1,)
                ],
              ),]
            ),
          ),
        ),
      ),
    );
  }
}

