import 'package:flutter/material.dart';

class FuturisticButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final bool isEnabled;

  const FuturisticButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.width = 200,
    this.height = 50,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.textColor = Colors.white,
    this.borderColor = const Color(0xFF00FFAA),
    this.borderWidth = 2.0,
    this.borderRadius = 8.0,
    this.textStyle,
    this.animationDuration = const Duration(seconds: 2),
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<FuturisticButton> createState() => _FuturisticButtonState();
}

class _FuturisticButtonState extends State<FuturisticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: LightningBorderPainter(
                progress: _animation.value,
                borderColor: widget.borderColor,
                borderWidth: widget.borderWidth,
                borderRadius: widget.borderRadius,
                isEnabled: widget.isEnabled,
              ),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Center(
                  child: Text(
                    widget.text,
                    style: widget.textStyle ??
                        TextStyle(
                          color: widget.isEnabled 
                              ? widget.textColor 
                              : widget.textColor.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LightningBorderPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool isEnabled;

  LightningBorderPainter({
    required this.progress,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.isEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isEnabled) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);

    // Create path for the border
    final path = Path();
    path.addRRect(rrect);
    
    final pathMetrics = path.computeMetrics().first;
    final totalLength = pathMetrics.length;
    
    // Lightning segment length (20% of total perimeter)
    final segmentLength = totalLength * 0.2;
    
    // Current position based on progress
    final currentPosition = (progress * totalLength) % totalLength;
    
    // Extract the lightning segment
    final startDistance = currentPosition;
    final endDistance = (currentPosition + segmentLength) % totalLength;
    
    Path lightningPath;
    
    if (endDistance > startDistance) {
      // Normal case - segment doesn't wrap around
      lightningPath = pathMetrics.extractPath(startDistance, endDistance);
    } else {
      // Wrap around case - segment crosses the start/end point
      lightningPath = pathMetrics.extractPath(startDistance, totalLength);
      lightningPath.addPath(pathMetrics.extractPath(0, endDistance), Offset.zero);
    }
    
    // Draw glow effect
    canvas.drawPath(lightningPath, glowPaint);
    
    // Draw main lightning line
    canvas.drawPath(lightningPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Usage example:
// FuturisticButton(
//   text: "Click Me",
//   onPressed: () {
//     print("Button pressed!");
//   },
//   width: 200,
//   height: 50,
//   backgroundColor: Color(0xFF1A1A1A),
//   borderColor: Color(0xFF00FFAA),
//   borderWidth: 2.0,
//   borderRadius: 8.0,
//   animationDuration: Duration(seconds: 2),
// )