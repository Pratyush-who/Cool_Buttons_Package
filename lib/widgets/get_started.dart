library explore_button;

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ExploreButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Duration animationDuration;
  final bool isEnabled;
  final Color initialBackgroundColor;
  final Color hoverBackgroundColor;
  final Color initialTextColor;
  final Color hoverTextColor;
  final Color initialBorderColor;
  final Color hoverBorderColor;
  final Color initialArrowCircleColor;
  final Color hoverArrowCircleColor;

  const ExploreButton({
    Key? key,
    this.text = 'Explore',
    this.onPressed,
    this.width = 180,
    this.height = 46,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isEnabled = true,
    this.initialBackgroundColor = Colors.white,
    this.hoverBackgroundColor = const Color(0xFF00BCD4),
    this.initialTextColor = Colors.black,
    this.hoverTextColor = Colors.white,
    this.initialBorderColor = Colors.black,
    this.hoverBorderColor = Colors.white,
    this.initialArrowCircleColor = Colors.black,
    this.hoverArrowCircleColor = Colors.white,
  }) : super(key: key);

  @override
  State<ExploreButton> createState() => _ExploreButtonState();
}

class _ExploreButtonState extends State<ExploreButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fillAnimation;
  late Animation<Color?> _textColorAnimation;
  late Animation<Color?> _arrowColorAnimation;
  late Animation<Color?> _arrowCircleColorAnimation;
  late Animation<Color?> _borderColorAnimation;

  bool _isHovering = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: -math.pi / 4, end: 0.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    
    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    
    _textColorAnimation = ColorTween(
      begin: widget.initialTextColor,
      end: widget.hoverTextColor,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
    
    _arrowColorAnimation = ColorTween(
      begin: widget.hoverTextColor,
      end: widget.initialTextColor,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
    
    _arrowCircleColorAnimation = ColorTween(
      begin: widget.initialArrowCircleColor,
      end: widget.hoverArrowCircleColor,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
    
    _borderColorAnimation = ColorTween(
      begin: widget.initialBorderColor,
      end: widget.hoverBorderColor,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
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

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onPressed : null,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _hoverController,
            _pressController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pressAnimation.value,
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: Stack(
                  children: [
                    // Base container with animated border color
                    Container(
                      width: widget.width,
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: widget.initialBackgroundColor,
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        border: Border.all(
                          color: _borderColorAnimation.value ?? widget.initialBorderColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    
                    // Soft fill animation with gradient edge
                    ClipRRect(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      child: Stack(
                        children: [
                          // Background color fill
                          Container(
                            width: widget.width * _fillAnimation.value,
                            height: widget.height,
                            color: widget.hoverBackgroundColor,
                          ),
                          // Gradient fade at the edge (20px wide soft transition)
                          Positioned(
                            right: 0,
                            child: Container(
                              width: 20,
                              height: widget.height,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.hoverBackgroundColor.withOpacity(1),
                                    widget.hoverBackgroundColor.withOpacity(0),
                                  ],
                                  stops: const [0.0, 1.0],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Thin white border overlay that appears on hover
                    // (This creates the secondary border effect when hovered)
                    Container(
                      width: widget.width,
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        border: Border.all(
                          color: widget.hoverBorderColor.withOpacity(_fillAnimation.value * 0.3),
                          width: 1.0,
                        ),
                      ),
                    ),
                    
                    // Content container
                    Container(
                      width: widget.width,
                      height: widget.height,
                      padding: const EdgeInsets.only(left: 20, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: _textColorAnimation.value,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _arrowCircleColorAnimation.value,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: _arrowColorAnimation.value,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}