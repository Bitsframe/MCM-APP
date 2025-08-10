import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter
import 'package:medicineapp/main.dart'; // Assuming MyHomePage is defined in main.dart

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    // The duration here is for the animation itself, before navigation.
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Animation completes in 2 seconds
      vsync: this,
    );

    // Blur Animation: Animates from a strong blur to no blur.
    // It completes in the first 70% of the total animation duration.
    _blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // Opacity Animation: Animates from fully transparent to fully opaque.
    // It fades in during the first 80% of the total animation duration.
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    // Scale Animation: Animates from a slightly smaller size to its original size.
    // This gives a subtle "zoom in" effect.
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // A nice, smooth and slightly bouncy curve
      ),
    );

    // Start the animation forward.
    _controller.forward();

    // Listen for the animation status to navigate once it's completed.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // After the animation completes, add a small delay before navigating.
        // This ensures the user sees the final state of the animation.
        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources when the widget is removed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: Center(
        // AnimatedBuilder rebuilds its child whenever the animation value changes.
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value, // Apply scaling animation
              child: Opacity(
                opacity: _opacityAnimation.value, // Apply opacity animation
                child: ImageFiltered(
                  // Apply blur animation using ImageFilter
                  imageFilter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: Image.asset(
                    'assets/images/medicineicon1.png', // Your image asset
                    height: 300,
                    width: 300,
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
