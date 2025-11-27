import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

class BouncingDotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const BouncingDotsLoader({
    super.key,
    this.color = AppColors.primaryGreen,
    this.size = 10.0,
  });

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: -10.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return; // prevent using controllers after dispose
      try {
        _controllers[i].repeat(reverse: true);
      } catch (_) {
        // If the controller was disposed concurrently, just stop starting further animations.
        return;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
