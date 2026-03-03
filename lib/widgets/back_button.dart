import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BackSvgButton extends StatefulWidget {
  final String asset;
  final double size;
  final Color color;
  final Color hoverColor;
  final Color tapColor;
  final VoidCallback? onTap;

  const BackSvgButton({
    super.key,
    required this.asset,
    this.size = 24,
    this.color = Colors.green,
    this.hoverColor = Colors.green,
    this.tapColor = Colors.green,
    this.onTap,
  });

  @override
  State<BackSvgButton> createState() => _BackSvgButtonState();
}

class _BackSvgButtonState extends State<BackSvgButton> {
  bool isHovered = false;
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => isTapped = true),
        onTapUp: (_) => setState(() => isTapped = false),
        onTapCancel: () => setState(() => isTapped = false),
        child: SvgPicture.asset(
          widget.asset,
          width: widget.size,
          height: widget.size,
          colorFilter: ColorFilter.mode(
            isTapped
                ? widget.tapColor
                : isHovered
                    ? widget.hoverColor
                    : widget.color,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}