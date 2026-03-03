import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iot_wallet/main.dart';
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
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232439),
      body: SafeArea(
        child: Stack(
          children: [
            /// BACKGROUND GLOW
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 12),

                  /// TOP BAR
                  SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "Send coins",
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

                  const SizedBox(height: 14),

                  /// BALANCE
                  const Center(
                    child: Text(
                      "Current Balance",
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
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "0 ",
                            style: TextStyle(
                              fontSize: 38,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: "TON",
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Center(
                    child: Text(
                      "\$0.00 USD",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF696B82),
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 21),

                  /// RECEIVING ADDRESS
                  const Text(
                    "Receiving address",
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
                      error: false,
                      child: TextField(
                        controller: addressController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                          ),
                        decoration: const InputDecoration(
                          hintText: "Enter the recipient's address here",
                          hintStyle: TextStyle(
                             fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF888992)
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TRANSFER AMOUNT
                  const Text(
                    "Transfer amount",
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
                      error: hasError,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              onChanged: (_) {
                                setState(() => hasError = false);
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                                LengthLimitingTextInputFormatter(15),
                              ],
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,                              
                              ),
                              decoration: const InputDecoration(
                                hintText: "Amount",
                                hintStyle:
                                    TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF888992)
                                    ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Text(
                            "TON",
                            style: TextStyle(
                             fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF888992)
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 1.1,
                            height: 21,
                            color: const Color(0xFF888992),
                          ),

                          const SizedBox(width: 12),
                          Image.asset(
                            "assets/ic_app.png",
                            width: 17,
                            height: 17,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (hasError) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SvgPicture.asset(
                            "assets/ic_error_red.svg",
                            width: 16,
                            height: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            "Insufficient balance to complete the transaction. Add funds to your balance and try again.",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    )
                  ],

                  const Spacer(),

                  // /// SEND BUTTON
                  // GestureDetector(
                  //   onTap: () {
                  //     if (amountController.text.isNotEmpty) {
                  //       setState(() => hasError = true);
                  //     }
                  //   },
                  //   child: Container(
                  //     width: double.infinity,
                  //     padding: const EdgeInsets.symmetric(vertical: 16),
                  //     decoration: BoxDecoration(
                  //       gradient: const LinearGradient(
                  //         colors: [Color(0xFF6D8BFF), Color(0xFF2D5BFF)],
                  //       ),
                  //       borderRadius: BorderRadius.circular(30),
                  //     ),
                  //     child: const Center(
                  //       child: Text(
                  //         "Send",
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontFamily: 'Poppins',
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  //  UniversalButton(
                  //   label: 'Send',
                  //   onPressed: () {
                  //     if (amountController.text.isNotEmpty) {
                  //       setState(() => hasError = true);
                  //     }
                  //   },
                  //   width: double.infinity,
                  // ),

                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 42,
                    ),
                    child: UniversalButton(
                      label: "Send",
                      onPressed: () {
                        if (amountController.text.isNotEmpty) {
                          setState(() => hasError = true);
                        }
                      },
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 16,)
                ],
              ),
            ),
          ],
        ),
      ),
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