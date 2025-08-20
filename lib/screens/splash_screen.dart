import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _gradientController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _gradientRotation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    ));

    _gradientRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.linear,
    ));

    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/language-selection');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          final rotation = _gradientRotation.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  math.cos(rotation),
                  math.sin(rotation),
                ),
                end: Alignment(
                  -math.cos(rotation),
                  -math.sin(rotation),
                ),
                colors: const [
                  Color(0xFF1E90FF), // Dodger Blue
                  Color(0xFF87CEEB), // Sky Blue
                  Color(0xFFB0E0E6), // Powder Blue
                  Color(0xFFE0F6FF), // Light Cyan
                  Color(0xFFF0F8FF), // Alice Blue
                  Color(0xFFFFFFFF), // White
                  Color(0xFFF0F8FF), // Alice Blue
                  Color(0xFFE0F6FF), // Light Cyan
                ],
                stops: const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Overlay gradient for depth
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        math.cos(rotation * 0.5) * 0.5,
                        math.sin(rotation * 0.5) * 0.5,
                      ),
                      radius: 1.5,
                      colors: [
                        const Color(0xFF1E90FF).withValues(alpha: 0.1),
                        const Color(0xFF87CEEB).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.95),
                                  Colors.white.withValues(alpha: 0.85),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E90FF).withValues(alpha: 0.15),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 180,
                                height: 180,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.child_care,
                                    size: 100,
                                    color: Color(0xFF1E90FF),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}