import 'package:flutter/material.dart';

class TransparentTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const TransparentTextButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}