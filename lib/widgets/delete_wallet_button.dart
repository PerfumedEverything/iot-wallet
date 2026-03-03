import 'package:flutter/material.dart';

class DeleteWalletButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final double height;

  const DeleteWalletButton({
    super.key,
    required this.onTap,
    this.label = "Delete wallet",
    this.height = 52,
  });

  @override
  State<DeleteWalletButton> createState() => _DeleteWalletButtonState();
}

class _DeleteWalletButtonState extends State<DeleteWalletButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _pressed ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.97 : 1,
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _pressed ? Colors.white : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}