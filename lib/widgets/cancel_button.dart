import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF4A4D6E),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            "Cancel",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}