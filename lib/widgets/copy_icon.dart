import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CopyIcon extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final Color defaultColor;
  final Color highlightColor;

  const CopyIcon({
    super.key,
    required this.onTap,
    this.size = 20,
    this.defaultColor = Colors.white,
    this.highlightColor = const Color(0xFF7084FF),
  });

  @override
  State<CopyIcon> createState() => _CopyIconState();
}

class _CopyIconState extends State<CopyIcon> {
  bool isHovering = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool highlight = isHovering || isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          child: SvgPicture.asset(
            "assets/ic_copy.svg",
            width: widget.size,
            height: widget.size,
            colorFilter: ColorFilter.mode(
              highlight ? widget.highlightColor : widget.defaultColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}