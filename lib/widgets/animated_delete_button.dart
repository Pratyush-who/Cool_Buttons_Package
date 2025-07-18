import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedDeleteButton extends StatefulWidget {
  final VoidCallback onDelete;
  final double? size;
  final Color? backgroundColor;
  final Color? deleteColor;
  final Color? dustColor;
  final Duration animationDuration;
  final bool enabled;

  const AnimatedDeleteButton({
    super.key,
    required this.onDelete,
    this.size,
    this.backgroundColor,
    this.deleteColor,
    this.dustColor,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.enabled = true,
  });

  @override
  State<AnimatedDeleteButton> createState() => _AnimatedDeleteButtonState();
}

class _AnimatedDeleteButtonState extends State<AnimatedDeleteButton>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _dustController;
  late AnimationController _lidController;
  late AnimationController _shakeController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _lidAnimation;
  late Animation<double> _dustAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isPressed = false;
  bool _isDeleting = false;
  bool _showDust = false;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _dustController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _lidController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.1, curve: Curves.easeInOut),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.4, curve: Curves.easeInOut),
    ));
    
    _lidAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _lidController,
      curve: Curves.elasticOut,
    ));
    
    _dustAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dustController,
      curve: Curves.easeOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? const Color.fromARGB(255, 250, 51, 67),
      end: const Color(0xFFFF3838),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _mainController.dispose();
    _dustController.dispose();
    _lidController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (!widget.enabled || _isDeleting) return;
    
    setState(() {
      _isPressed = true;
      _isDeleting = true;
    });
    
    await _mainController.forward();
    await _shakeController.forward();
    await _lidController.forward();
    
    setState(() {
      _showDust = true;
    });
    
    await _dustController.forward();
    widget.onDelete();
    await Future.delayed(const Duration(milliseconds: 500));
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() {
      _isPressed = false;
      _isDeleting = false;
      _showDust = false;
    });
    
    _mainController.reset();
    _dustController.reset();
    _lidController.reset();
    _shakeController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 56.0;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _dustController,
        _lidController,
        _shakeController,
      ]),
      builder: (context, child) {
        return GestureDetector(
          onTap: _handlePress,
          child: Transform.scale(
            scale: _isDeleting ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: _shakeAnimation.value * 0.3 * math.sin(_shakeController.value * 10 * math.pi),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(size / 4),
                  boxShadow: [
                    BoxShadow(
                      color: (_colorAnimation.value ?? Colors.red).withOpacity(0.4),
                      blurRadius: _isDeleting ? 20 : 8,
                      spreadRadius: _isDeleting ? 4 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: CustomPaint(
                        size: Size(size * 0.6, size * 0.6),
                        painter: _DustbinPainter(
                          lidProgress: _lidAnimation.value,
                          rotationProgress: _rotationAnimation.value,
                          color: widget.deleteColor ?? Colors.white,
                          isPressed: _isPressed,
                        ),
                      ),
                    ),
                    
                    if (_showDust)
                      ...List.generate(12, (index) {
                        final angle = (index * 30.0) * math.pi / 180;
                        final radius = _dustAnimation.value * (size * 0.8);
                        final x = size / 2 + radius * math.cos(angle);
                        final y = size / 2 + radius * math.sin(angle);
                        
                        return Positioned(
                          left: x - 2,
                          top: y - 2,
                          child: Opacity(
                            opacity: (1 - _dustAnimation.value).clamp(0.0, 1.0),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: widget.dustColor ?? Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DustbinPainter extends CustomPainter {
  final double lidProgress;
  final double rotationProgress;
  final Color color;
  final bool isPressed;

  const _DustbinPainter({
    required this.lidProgress,
    required this.rotationProgress,
    required this.color,
    required this.isPressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final binWidth = size.width * 0.6;
    final binHeight = size.height * 0.5;

    canvas.save();
    
    if (isPressed) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotationProgress);
      canvas.translate(-center.dx, -center.dy);
    }

    final binRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.1),
        width: binWidth,
        height: binHeight,
      ),
      const Radius.circular(4),
    );
    
    canvas.drawRRect(binRect, paint);

    final lineSpacing = binHeight / 4;
    for (int i = 0; i < 3; i++) {
      final y = center.dy - binHeight / 4 + (i * lineSpacing);
      canvas.drawLine(
        Offset(center.dx - binWidth / 4, y),
        Offset(center.dx + binWidth / 4, y),
        paint,
      );
    }

    final lidY = center.dy - binHeight / 2 - (lidProgress * 8);
    final lidWidth = binWidth * 1.1;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, lidY),
          width: lidWidth,
          height: size.height * 0.1,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    final handleHeight = size.height * 0.15;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, lidY - handleHeight / 2),
          width: lidWidth * 0.3,
          height: handleHeight,
        ),
        const Radius.circular(6),
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DustbinPainter oldDelegate) => 
      lidProgress != oldDelegate.lidProgress ||
      rotationProgress != oldDelegate.rotationProgress ||
      color != oldDelegate.color ||
      isPressed != oldDelegate.isPressed;
}