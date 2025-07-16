import 'package:flutter/material.dart';

class ShimmerButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? accentColor;

  const ShimmerButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
  });

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Scale animation for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = widget.width ?? 200;
    final double buttonHeight = widget.height ?? 56;
    
    // Custom colors with fallback
    final Color primaryColor = widget.primaryColor ?? const Color(0xFF667EEA);
    final Color secondaryColor = widget.secondaryColor ?? const Color(0xFF764BA2);
    final Color accentColor = widget.accentColor ?? const Color(0xFFE73C7E);

    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.isLoading ? null : widget.onTap,
            child: Container(
              width: buttonWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(buttonHeight / 2),
                boxShadow: [
                  // Animated glow effect
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  // Static shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(buttonHeight / 2),
                child: Stack(
                  children: [
                    // Base gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor,
                            secondaryColor,
                            accentColor,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    
                    // Shimmer overlay
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-2.0 + 4.0 * _shimmerController.value, -0.5),
                                end: Alignment(-1.0 + 4.0 * _shimmerController.value, 0.5),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                              ),
                            ),
                          );
                        },
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
                    
                    // Button content
                    Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
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
    );
  }
}

// Example usage widget
class ShimmerButtonExample extends StatefulWidget {
  @override
  _ShimmerButtonExampleState createState() => _ShimmerButtonExampleState();
}

class _ShimmerButtonExampleState extends State<ShimmerButtonExample> {
  bool _isLoading = false;

  void _handleTap() {
    setState(() => _isLoading = true);
    
    // Simulate async operation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Default shimmer button
            ShimmerButton(
              text: "Get Started",
              onTap: _handleTap,
              isLoading: _isLoading,
              icon: Icons.rocket_launch,
            ),
            
            const SizedBox(height: 24),
            
            // Custom colored shimmer button
            ShimmerButton(
              text: "Download Now",
              onTap: () => print("Download tapped"),
              width: 250,
              primaryColor: const Color(0xFF00F260),
              secondaryColor: const Color(0xFF0575E6),
              accentColor: const Color(0xFF00F260),
              icon: Icons.download,
            ),
            
            const SizedBox(height: 24),
            
            // Purple theme shimmer button
            ShimmerButton(
              text: "Subscribe",
              onTap: () => print("Subscribe tapped"),
              width: 180,
              primaryColor: const Color(0xFF8B5CF6),
              secondaryColor: const Color(0xFFA855F7),
              accentColor: const Color(0xFFEC4899),
              icon: Icons.star,
            ),
          ],
        ),
      ),
    );
  }
}