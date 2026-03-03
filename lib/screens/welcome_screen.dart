import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/universal_button.dart';
import 'login_screen.dart';
import 'package:flutter/gestures.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                  top: -100,
                  left: -250,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color.fromARGB(37, 27, 89, 234),
                          Color.fromARGB(17, 35, 36, 57),
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Spacer(flex: 1,),
                  // Logo and text
                  Column(
                    children: [
                      Image.asset(  
                        'assets/ic_app.png',
                        width: 150,
                        height: 150,
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
                              "Welcome Back!",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "To ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 28,
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
                                "IOT ",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Text(
                              "Wallet",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 21),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Control ",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
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
                              "your cryptocurrency ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(flex: 2,),
                  // Button
                  UniversalButton(
                    label: 'Get started',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    width: double.infinity,
                  ),
                  const SizedBox(height: 50),
                  PrivacyText(
                    onPrivacyTap: () {
                      try {
                        launchUrl(Uri.parse('https://telegra.ph/Privacy-Policy-02-28-101'));
                      } catch (e) {
                        print("Could not launch URL: $e");
                      }
                    },
                  ),
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

class PrivacyText extends StatelessWidget {
  final VoidCallback onPrivacyTap;

  const PrivacyText({super.key, required this.onPrivacyTap});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
          color: Color(0xFF696B82),
          fontSize: 12,
        ),
        children: [
          const TextSpan(text: 'I accept '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              decoration: TextDecoration.underline,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Color(0xFF696B82),
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
          ),
        ],
      ),
    );
  }
}
