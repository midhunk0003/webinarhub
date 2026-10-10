import 'package:flutter/material.dart';

class WebinarStaggerAnimation extends StatefulWidget {
  final Widget child;
  final int index;

  const WebinarStaggerAnimation({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<WebinarStaggerAnimation> createState() =>
      _WebinarStaggerAnimationState();
}

class _WebinarStaggerAnimationState extends State<WebinarStaggerAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = curvedAnimation;

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(curvedAnimation);

    // Stagger cards without creating delayed callbacks.
    final delay = Duration(milliseconds: widget.index.clamp(0, 6) * 75);

    Future<void>.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
