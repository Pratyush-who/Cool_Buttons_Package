import 'package:flutter/material.dart';

class SleekOutlinedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final Color? borderColor;
  final Color? textColor;

  const SleekOutlinedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.borderColor,
    this.textColor,
  });

  @override
  State<SleekOutlinedButton> createState() => _SleekOutlinedButtonState();
}

class _SleekOutlinedButtonState extends State<SleekOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? 150,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isPressed ? Colors.black87 : Colors.black,
                border: Border.all(
                  color: widget.borderColor ?? Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
