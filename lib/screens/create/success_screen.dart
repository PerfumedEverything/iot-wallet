import 'package:flutter/material.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/widgets/universal_button.dart';

class SuccessCreateScreen extends StatefulWidget {
  const SuccessCreateScreen({super.key});

  @override
  State<SuccessCreateScreen> createState() => _SuccessCreateScreenState();
}

class _SuccessCreateScreenState extends State<SuccessCreateScreen> {

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
            
                
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Transform.translate(
                          offset: const Offset(0, 0),
                            child:ShaderMask(
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
                                  "Welcome",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                            ),),
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "to your wallet",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ]
                          ), 
                    
                          
                      ),
                    ]
                  ),
                ),

                    
                const SizedBox(height: 0),
                    
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Text(
                      "Your wallet is now active. Time to send, receive, and explore new opportunities",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0xFF666BA5),
                      ),
                    ),
                  ),
                ),
                    
                Spacer(flex: 1),

                Center(
                  child: Image.asset(
                    'assets/ic_rocket.png',
                    width: 200,
                  ),
                ),
                         
                  Spacer(flex: 2),
                    
                /// CONTINUE BUTTON
                UniversalButton(
                    label: 'Get started',
                    onPressed: () {
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    },
                    width: double.infinity,
                  ),
                  SizedBox(height: 42,)
              ],
            ),
                      ),
          
          ]
            
        
        ),
      ),
    );
  }
}