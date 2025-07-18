import 'dart:ui';
import 'package:flutter/material.dart';

class DarkButton extends StatefulWidget {
  final String text;

  final VoidCallback? onPressed;

  final double width;

  final double height;

  final Color backgroundColor;

  final Color textColor;

  final Color normalBorderColor;

  final Color hoverBorderColor;

  final double borderWidth;

  final double borderRadius;

  final TextStyle? textStyle;

  final Duration animationDuration;

  final Duration hoverTransitionDuration;

  final bool isEnabled;

  final double glowRadius;

  final double lightSegmentLength;

  const DarkButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.width = 200,
    this.height = 50,
    this.backgroundColor = const Color(0xFF0A0A0A),
    this.textColor = Colors.white,
    this.normalBorderColor = const Color(0xFF404040),
    this.hoverBorderColor = const Color(0xFF3B82F6),
    this.borderWidth = 1.0,
    this.borderRadius = 25.0,
    this.textStyle,
    this.animationDuration = const Duration(seconds: 3),
    this.hoverTransitionDuration = const Duration(milliseconds: 300),
    this.isEnabled = true,
    this.glowRadius = 2.0,
    this.lightSegmentLength = 0.15,
  }) : assert(
         lightSegmentLength >= 0.0 && lightSegmentLength <= 1.0,
         'lightSegmentLength must be between 0.0 and 1.0',
       ),
       super(key: key);

  @override
  State<DarkButton> createState() => _AceternityButtonState();
}

class _AceternityButtonState extends State<DarkButton>
    with TickerProviderStateMixin {
  late AnimationController _revolvingController;
  late AnimationController _hoverController;
  late Animation<double> _revolvingAnimation;
  late Animation<double> _hoverAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    _revolvingController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _revolvingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revolvingController, curve: Curves.linear),
    );

    _hoverController = AnimationController(
      duration: widget.hoverTransitionDuration,
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    if (widget.isEnabled) {
      _revolvingController.repeat();
    }
  }

  @override
  void didUpdateWidget(DarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _revolvingController.dispose();
      _revolvingController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
      _revolvingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _revolvingController, curve: Curves.linear),
      );
      if (widget.isEnabled) {
        _revolvingController.repeat();
      }
    }
    if (oldWidget.hoverTransitionDuration != widget.hoverTransitionDuration) {
      _hoverController.dispose();
      _hoverController = AnimationController(
        duration: widget.hoverTransitionDuration,
        vsync: this,
      );
      _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
      );
    }
    if (oldWidget.isEnabled != widget.isEnabled) {
      if (widget.isEnabled) {
        _revolvingController.repeat();
      } else {
        _revolvingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _revolvingController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    if (_isHovering == isHovering || !widget.isEnabled) return;
    setState(() => _isHovering = isHovering);
    if (isHovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_revolvingAnimation, _hoverAnimation]),
          builder: (context, child) {
            final currentBorderColor = Color.lerp(
              widget.normalBorderColor.withOpacity(0.3),
              widget.hoverBorderColor.withOpacity(0.9),
              _hoverAnimation.value,
            )!;
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: currentBorderColor,
                  width: widget.borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _RevolvingLightPainter(
                  progress: _revolvingAnimation.value,
                  hoverProgress: _hoverAnimation.value,
                  normalBorderColor: widget.normalBorderColor,
                  hoverBorderColor: widget.hoverBorderColor,
                  borderWidth: widget.borderWidth,
                  borderRadius: widget.borderRadius,
                  isEnabled: widget.isEnabled,
                  glowRadius: widget.glowRadius,
                  lightSegmentLength: widget.lightSegmentLength,
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
                      style:
                          widget.textStyle ??
                          TextStyle(
                            color: widget.isEnabled
                                ? widget.textColor
                                : widget.textColor.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
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

class _RevolvingLightPainter extends CustomPainter {
  final double progress;
  final double hoverProgress;
  final Color normalBorderColor;
  final Color hoverBorderColor;
  final double borderWidth;
  final double borderRadius;
  final bool isEnabled;
  final double glowRadius;
  final double lightSegmentLength;

  _RevolvingLightPainter({
    required this.progress,
    required this.hoverProgress,
    required this.normalBorderColor,
    required this.hoverBorderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.isEnabled,
    required this.glowRadius,
    required this.lightSegmentLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isEnabled) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final currentBorderColor = Color.lerp(
      normalBorderColor,
      hoverBorderColor,
      hoverProgress,
    )!;

    final path = Path();
    path.addRRect(rrect);

    final pathMetrics = path.computeMetrics().first;
    final totalLength = pathMetrics.length;

    if (hoverProgress > 0.5) {
      _drawFullBorderGlow(canvas, path, currentBorderColor, hoverProgress);
    } else {
      _drawRotatingLight(canvas, pathMetrics, totalLength, currentBorderColor);
    }
  }

  void _drawFullBorderGlow(
    Canvas canvas,
    Path path,
    Color color,
    double intensity,
  ) {
    final glowLayers = [
      _GlowLayer(
        strokeWidth: borderWidth + glowRadius * 1.5,
        opacity: 0.15 * intensity,
        blurRadius: glowRadius * 0.8,
      ),
      _GlowLayer(
        strokeWidth: borderWidth + glowRadius,
        opacity: 0.25 * intensity,
        blurRadius: glowRadius * 0.5,
      ),
      _GlowLayer(
        strokeWidth: borderWidth,
        opacity: 0.9 * intensity,
        blurRadius: 0,
      ),
    ];

    for (final layer in glowLayers) {
      final paint = Paint()
        ..color = color.withOpacity(layer.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = layer.strokeWidth
        ..strokeCap = StrokeCap.round;
      if (layer.blurRadius > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blurRadius);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawRotatingLight(
    Canvas canvas,
    PathMetric pathMetrics,
    double totalLength,
    Color color,
  ) {
    final segmentLength = totalLength * lightSegmentLength;
    final currentPosition = (progress * totalLength) % totalLength;
    final startDistance = currentPosition;
    final endDistance = (currentPosition + segmentLength) % totalLength;

    Path lightPath = endDistance > startDistance
        ? pathMetrics.extractPath(startDistance, endDistance)
        : (Path()
            ..addPath(
              pathMetrics.extractPath(startDistance, totalLength),
              Offset.zero,
            )
            ..addPath(pathMetrics.extractPath(0, endDistance), Offset.zero));

    final Rect bounds = lightPath.getBounds();
    final gradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.9),
        Colors.white.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: [0.0, 0.4, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final paint = Paint()
      ..shader = gradient.createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + glowRadius
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(lightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GlowLayer {
  final double strokeWidth;
  final double opacity;
  final double blurRadius;

  const _GlowLayer({
    required this.strokeWidth,
    required this.opacity,
    required this.blurRadius,
  });
}
