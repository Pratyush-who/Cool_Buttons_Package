import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class EpicCreatePostButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const EpicCreatePostButton({
    Key? key,
    this.onPressed,
    this.width = 200,
    this.height = 60,
  }) : super(key: key);

  @override
  State<EpicCreatePostButton> createState() => _EpicCreatePostButtonState();
}

class _EpicCreatePostButtonState extends State<EpicCreatePostButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _loadingController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _hoverAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  bool _isHovered = false;
  bool _isPressed = false;
  bool _isLoading = false;
  bool _isCompleted = false;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
  }

  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
    
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _particleController.repeat();
    _shimmerController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _generateParticles() {
    _particles = List.generate(8, (index) {
      return Particle(
        x: math.Random().nextDouble() * widget.width,
        y: math.Random().nextDouble() * widget.height,
        size: math.Random().nextDouble() * 3 + 1,
        color: _getRandomColor(),
        speed: math.Random().nextDouble() * 2 + 1,
        angle: math.Random().nextDouble() * 2 * math.pi,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.purple.shade300,
      Colors.pink.shade300,
      Colors.blue.shade300,
      Colors.cyan.shade300,
      Colors.yellow.shade300,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _handleTap() async {
    if (_isLoading || _isCompleted) return;

    HapticFeedback.mediumImpact();
    _rotationController.forward();
    
    setState(() {
      _isPressed = true;
      _isLoading = true;
    });

    _loadingController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _isLoading = false;
      _isCompleted = true;
    });

    HapticFeedback.heavyImpact();
    widget.onPressed?.call();

    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      setState(() {
        _isCompleted = false;
        _isPressed = false;
      });
      _loadingController.reset();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _loadingController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _hoverAnimation,
        _pressAnimation,
        _particleAnimation,
        _shimmerAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value * _pressAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: GestureDetector(
              onTapDown: (_) => _pressController.forward(),
              onTapUp: (_) => _pressController.reverse(),
              onTapCancel: () => _pressController.reverse(),
              onTap: _handleTap,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _isCompleted
                          ? Colors.green.withOpacity(0.6)
                          : Colors.purple.withOpacity(0.4),
                      blurRadius: _isHovered ? 20 : 15,
                      spreadRadius: _isHovered ? 5 : 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isCompleted
                              ? [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ]
                              : [
                                  Colors.purple.shade400,
                                  Colors.pink.shade500,
                                  Colors.blue.shade500,
                                ],
                        ),
                      ),
                    ),
                    
                    // Particles
                    ..._particles.map((particle) => _buildParticle(particle)),
                    
                    // Shimmer effect
                    _buildShimmer(),
                    
                    // Pulse effect
                    if (_isHovered)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: _pulseAnimation.value,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    
                    // Main content
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(Particle particle) {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final progress = _particleAnimation.value;
        final x = particle.x + math.cos(particle.angle + progress * 2 * math.pi) * 10;
        final y = particle.y + math.sin(particle.angle + progress * 2 * math.pi) * 10;
        
        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: particle.color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: [
                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isCompleted) {
      return const Row(
        key: ValueKey('completed'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Post Created!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
    }

    if (_isLoading) {
      return Row(
        key: const ValueKey('loading'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _loadingAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _loadingAnimation.value,
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'Creating Magic...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
    }

    return Row(
      key: const ValueKey('default'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _isHovered ? _rotationAnimation.value * 0.1 : 0,
              child: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 24,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovered ? _pulseAnimation.value : 1.0,
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.yellow,
                size: 20,
              ),
            );
          },
        ),
      ],
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double angle;

  const Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.angle,
  });
}