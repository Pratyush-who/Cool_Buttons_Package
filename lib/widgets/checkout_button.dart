import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final String text;
  final String? amount;
  final EdgeInsets? padding;
  final double? width;
  final double height;
  final List<Color>? beforeColors;
  final List<Color>? afterColors;

  const CheckoutButton({
    Key? key,
    this.onPressed,
    this.isEnabled = true,
    this.text = 'Pay Now',
    this.amount,
    this.padding,
    this.width,
    this.height = 56,
    this.beforeColors,
    this.afterColors,
  }) : super(key: key);

  @override
  State<CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton>
    with TickerProviderStateMixin {
  late AnimationController _paymentController;
  late AnimationController _scaleController;
  late AnimationController _moneyController;
  late AnimationController _successController;
  late AnimationController _glowController;
  
  late Animation<double> _paymentAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _moneyFallAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _glowAnimation;

  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    
    _paymentController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _moneyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _paymentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _paymentController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _moneyFallAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _moneyController,
      curve: Curves.bounceOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    // Start subtle glow animation
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _paymentController.dispose();
    _scaleController.dispose();
    _moneyController.dispose();
    _successController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    if (!widget.isEnabled || _isProcessing || _isSuccess) return;

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    _paymentController.forward();
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _moneyController.forward();
    });

    await Future.delayed(const Duration(milliseconds: 3000));

    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });

    _successController.forward();
    HapticFeedback.heavyImpact();
    widget.onPressed?.call();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() => _isSuccess = false);
      _paymentController.reset();
      _moneyController.reset();
      _successController.reset();
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
                  color: _isSuccess 
                      ? (widget.afterColors?.first ?? Colors.green).withOpacity(0.4)
                      : (widget.beforeColors?.first ?? const Color(0xFFEF4444)).withOpacity(0.3),
                  blurRadius: 12 + (4 * _glowAnimation.value),
                  offset: const Offset(0, 4),
                ),
                if (_isSuccess)
                  BoxShadow(
                    color: (widget.afterColors?.first ?? Colors.green).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
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
                      colors: _isSuccess
                          ? widget.afterColors ?? [
                              const Color(0xFF10B981),
                              const Color(0xFF059669),
                            ]
                          : widget.isEnabled
                              ? widget.beforeColors ?? [
                                  const Color(0xFFEF4444),
                                  const Color(0xFFDC2626),
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
                      if (_isProcessing)
                        ...List.generate(5, (index) {
                          return AnimatedBuilder(
                            animation: _moneyFallAnimation,
                            builder: (context, child) {
                              return Positioned(
                                left: 20.0 + (index * 40.0),
                                top: -20 + (100 * _moneyFallAnimation.value),
                                child: Opacity(
                                  opacity: 1.0 - _moneyFallAnimation.value,
                                  child: Transform.rotate(
                                    angle: _moneyFallAnimation.value * 2 * 3.14159,
                                    child: const Icon(
                                      Icons.attach_money,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      
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
    if (_isSuccess) {
      return AnimatedBuilder(
        animation: _successAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _successAnimation.value,
            child: const Row(
              key: ValueKey('success'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (_isProcessing) {
      return Row(
        key: const ValueKey('processing'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _paymentAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Credit card outline
                  Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Processing bar
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      width: 20 * _paymentAnimation.value,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  // Card chip
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'Processing Payment...',
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
          Icons.credit_card,
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
        if (widget.amount != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.amount!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}