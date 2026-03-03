import 'package:flutter/material.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/widgets/transperent_button.dart';
import '../widgets/universal_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                  top: 200,
                  right: 21,
                  child: Image.asset( 
                    'assets/ic_line.png',
                    width: 170,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  const SizedBox(height: 50),
                  // Logo and text
                  Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                               const Text(
                                "Access",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -12),
                                  child:const Text(
                                    "Your",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                  ),
                              )),
                               Transform.translate(
                                offset: const Offset(0, -24),
                                child: ShaderMask(
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
                                        "Crypto",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 40,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )),
                                Transform.translate(
                                  offset: const Offset(0, -36),
                                  child:const Text(
                                  "Universe",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                )),
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        ]
                      ),
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  UniversalButton(
                    label: 'Create wallet',
                    onPressed: () {
                      navigatorKey.currentState?.pushNamed('/create');
                    },
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  TransparentTextButton(title: "Log in", onTap: () {
                    navigatorKey.currentState?.pushNamed('/restore');
                  }),
                  const SizedBox(height: 6),
                ],
              ),
            ),]
          ),
        ),
      ),
    );
  }
}

