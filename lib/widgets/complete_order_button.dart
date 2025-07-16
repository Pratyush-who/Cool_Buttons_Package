import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompleteOrderButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final String text;
  final EdgeInsets? padding;
  final double? width;
  final double height;
  final List<Color>? beforeColors;
  final List<Color>? afterColors;

  const CompleteOrderButton({
    Key? key,
    this.onPressed,
    this.isEnabled = true,
    this.text = 'Complete Order',
    this.padding,
    this.width,
    this.height = 56,
    this.beforeColors,
    this.afterColors,
  }) : super(key: key);

  @override
  State<CompleteOrderButton> createState() => _CompleteOrderButtonState();
}

class _CompleteOrderButtonState extends State<CompleteOrderButton>
    with TickerProviderStateMixin {
  late AnimationController _packingController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _packingAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    
    _packingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _packingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _packingController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start shimmer animation
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _packingController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    if (!widget.isEnabled || _isLoading || _isCompleted) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    // Start packing animation
    _packingController.forward();

    // Simulate order processing
    await Future.delayed(const Duration(milliseconds: 2500));

    setState(() {
      _isLoading = false;
      _isCompleted = true;
    });

    HapticFeedback.heavyImpact();
    widget.onPressed?.call();

    // Reset after showing completion
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _isCompleted = false);
      _packingController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            margin: widget.padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isCompleted 
                      ? (widget.afterColors?.first ?? Colors.green).withOpacity(0.4)
                      : (widget.beforeColors?.first ?? const Color(0xFF6366F1)).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.isEnabled ? _handlePress : null,
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) => _scaleController.reverse(),
                onTapCancel: () => _scaleController.reverse(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: _isCompleted
                          ? widget.afterColors ?? [
                              const Color(0xFF10B981),
                              const Color(0xFF059669),
                            ]
                          : widget.isEnabled
                              ? widget.beforeColors ?? [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF4F46E5),
                                ]
                              : [
                                  Colors.grey.shade400,
                                  Colors.grey.shade500,
                                ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Shimmer effect
                      if (!_isLoading && !_isCompleted)
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    transform: GradientRotation(
                                      _shimmerAnimation.value * 3.14159,
                                    ),
                                  ).createShader(bounds);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                            );
                          },
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
            Icons.check_circle,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Order Completed!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
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
            animation: _packingAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Box outline
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Filling animation
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 24,
                      height: 24 * _packingAnimation.value,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Items being packed
                  if (_packingAnimation.value > 0.3)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (_packingAnimation.value > 0.6)
                    Positioned(
                      bottom: 10,
                      child: Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'Packing Order...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Row(
      key: const ValueKey('default'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.inventory_2_outlined,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward,
          color: Colors.white,
          size: 16,
        ),
      ],
    );
  }
}