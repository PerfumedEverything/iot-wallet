import 'package:flutter/material.dart';

class UniversalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const UniversalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 52,
  });

  @override
  State<UniversalButton> createState() => _UniversalButtonState();
}

class _UniversalButtonState extends State<UniversalButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: _isEnabled ? widget.onPressed : null,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(107),
          gradient: _getGradient(),
          boxShadow: _isPressed
              ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 6)]
              : [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10)],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: _isEnabled ? Colors.white : Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    if (!_isEnabled) {
      return const LinearGradient(
        colors: [Color(0xFF8DABFF), Color(0xFF8DABFF)],
      );
    } else if (_isPressed) {
      return const LinearGradient(
        colors: [Color(0xFF103497), Color(0xFF103497)],
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF3A6DF7), Color(0xFF3A6DF7)],
      );
    }
  }
}
