import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedGetStartedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;

  const AnimatedGetStartedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.height,
    this.icon = Icons.rocket_launch,
    this.isLoading = false,
  });

  @override
  State<AnimatedGetStartedButton> createState() => _AnimatedGetStartedButtonState();
}

class _AnimatedGetStartedButtonState extends State<AnimatedGetStartedButton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pressController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _iconController;
  late AnimationController _rippleController;
  
  late Animation<double> _pressAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Shimmer animation - continuous flowing effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    // Icon animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));
    
    // Ripple animation
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    // Start icon animation
    _iconController.forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pressController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _iconController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    _rippleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _rippleController.reset();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _rippleController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = widget.width ?? 220;
    final double buttonHeight = widget.height ?? 64;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _shimmerController,
          _pressAnimation,
          _glowAnimation,
          _particleController,
          _iconAnimation,
          _rippleAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: Container(
              width: buttonWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(buttonHeight / 2),
                boxShadow: [
                  // Animated outer glow
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.5 * _glowAnimation.value),
                    blurRadius: 30 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                  ),
                  // Secondary glow
                  BoxShadow(
                    color: const Color(0xFFE73C7E).withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 15 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  // Base shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: widget.isLoading ? null : widget.onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                  child: Stack(
                    children: [
                      // Base gradient background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF667EEA),
                              Color(0xFF764BA2),
                              Color(0xFFE73C7E),
                              Color(0xFFFF6B6B),
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                      
                      // Animated particles background
                      CustomPaint(
                        painter: ParticlePainter(_particleController.value),
                        child: Container(),
                      ),
                      
                      // Shimmer overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-2.0 + 4.0 * _shimmerController.value, -1.0),
                            end: Alignment(-1.0 + 4.0 * _shimmerController.value, 1.0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0],
                          ),
                        ),
                      ),
                      
                      // Ripple effect
                      if (_rippleAnimation.value > 0)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(buttonHeight / 2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5 * (1 - _rippleAnimation.value)),
                                width: 2 * _rippleAnimation.value,
                              ),
                            ),
                          ),
                        ),
                      
                      // Pressed overlay
                      if (_isPressed)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(buttonHeight / 2),
                            ),
                          ),
                        ),
                      
                      // Hover effect
                      if (_isHovered)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(buttonHeight / 2),
                            ),
                          ),
                        ),
                      
                      // Button content
                      Center(
                        child: widget.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.icon != null)
                                    Transform.rotate(
                                      angle: _iconAnimation.value * 0.2,
                                      child: Transform.scale(
                                        scale: _iconAnimation.value,
                                        child: Icon(
                                          widget.icon,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.text,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
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

class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Draw floating particles
    for (int i = 0; i < 8; i++) {
      final double progress = (animationValue + i * 0.1) % 1.0;
      final double x = (i * 30.0 + progress * size.width) % size.width;
      final double y = size.height * 0.3 + (i % 2 == 0 ? 10 : -10) * progress;
      final double radius = 2.0 + progress * 3.0;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.white.withOpacity(0.4 * (1 - progress)),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Demo widget
class AnimatedGetStartedButtonDemo extends StatefulWidget {
  @override
  _AnimatedGetStartedButtonDemoState createState() => _AnimatedGetStartedButtonDemoState();
}

class _AnimatedGetStartedButtonDemoState extends State<AnimatedGetStartedButtonDemo> {
  bool _isLoading = false;

  void _handleGetStarted() {
    setState(() => _isLoading = true);
    
    // Simulate async operation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 Welcome! Let\'s get started!'),
            backgroundColor: Color(0xFF667EEA),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF24243e),
              Color(0xFF302B63),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ready to begin?',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Experience the magic of our platform',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),
              AnimatedGetStartedButton(
                text: 'GET STARTED',
                onTap: _handleGetStarted,
                isLoading: _isLoading,
                width: 240,
                height: 68,
              ),
              const SizedBox(height: 24),
              Text(
                'Join thousands of satisfied users',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}