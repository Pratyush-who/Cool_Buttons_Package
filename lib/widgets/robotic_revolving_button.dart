import 'package:flutter/material.dart';
import 'dart:math' as math;

class RoboticRevolvingButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final Color? lineColor;
  final Color? textColor;
  final Color? backgroundColor;

  const RoboticRevolvingButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.lineColor,
    this.textColor,
    this.backgroundColor,
  });

  @override
  State<RoboticRevolvingButton> createState() => _RoboticRevolvingButtonState();
}

class _RoboticRevolvingButtonState extends State<RoboticRevolvingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.2, 0.05, 0.2, 1.0),
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool hovering) {
    setState(() {
      _isHovered = hovering;
    });

    if (hovering) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  width: (widget.width ?? 230) + 8,
                  height: 72,
                  margin: const EdgeInsets.only(
                    left: 4,
                    top: 4,
                    right: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                Container(
                  width: (widget.width ?? 230) + 8,
                  height: 72,
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? const Color(0xFFBE1F41),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.textColor ?? Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                if (!_isHovered)
                  CustomPaint(
                    painter: RevolvingLinePainter(
                      angle: _rotationAnimation.value,
                      lineColor: widget.lineColor ?? const Color(0xFFFFD700),
                    ),
                    child: Container(
                      width: (widget.width ?? 230) + 8,
                      height: 72,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RevolvingLinePainter extends CustomPainter {
  final double angle;
  final Color lineColor;

  RevolvingLinePainter({required this.angle, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(16),
    );

    final path = Path()..addRRect(rect);
    final pathMetrics = path.computeMetrics().toList();

    if (pathMetrics.isNotEmpty) {
      final pathMetric = pathMetrics.first;
      final totalLength = pathMetric.length;

      if (totalLength > 0) {
        final sizeProgress = math.sin(angle * 2);
        final normalizedSize = (sizeProgress + 1) / 2;
        final easedSize =
            normalizedSize * normalizedSize * (3.0 - 2.0 * normalizedSize);
        final minSegmentRatio = 0.05;
        final maxSegmentRatio = 0.4;
        final segmentRatio =
            minSegmentRatio + (maxSegmentRatio - minSegmentRatio) * easedSize;
        final segmentLength = totalLength * segmentRatio;

        final adjustedAngle = angle + (math.pi * 1.25);
        final currentPosition = ((adjustedAngle) / (2 * math.pi)) * totalLength;

        final startPos = currentPosition % totalLength;
        final endPos = (currentPosition + segmentLength) % totalLength;

        Path segment;
        if (startPos < endPos) {
          segment = pathMetric.extractPath(startPos, endPos);
        } else {
          final segment1 = pathMetric.extractPath(startPos, totalLength);
          final segment2 = pathMetric.extractPath(0, endPos);
          segment = Path()
            ..addPath(segment1, Offset.zero)
            ..addPath(segment2, Offset.zero);
        }

        canvas.drawPath(segment, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
