import 'package:flutter/material.dart';
import 'package:bukidlink/Pages/LoginPage.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
    void _goToLogin() {
      if (_skipped) return;
      _skipped = true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1200),
        ),
      );
    }
  late AnimationController _progressController;
  late Animation<double> _progressAnim;
  late AnimationController _mainController;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoOpacityAnim;
  late AnimationController _sunriseController;

  Timer? _timer;
  bool _skipped = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), // 4 seconds for the progress bar
    );
    // stops: 0-0.33, pause, 0.33-0.66, pause, 0.66-1.0, pause
    _progressAnim = TweenSequence<double>([
      // 0.0 to 0.03
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.03).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.03), // Pause at 3%
        weight: 2,
      ),
      // 0.03 to 0.33
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.03, end: 0.33).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.33), // Pause at 33%
        weight: 2,
      ),
      // 0.33 to 0.66
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.33, end: 0.66).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.66), // Pause at 66%
        weight: 2,
      ),
      // 0.66 to 1.0
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.66, end: 1.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0), // Pause at 100%
        weight: 1,
      ),
    ]).animate(_progressController);

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _logoScaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOutBack),
    );
    _logoOpacityAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    );

    _sunriseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _mainController.forward();
    _progressController.forward();
    _timer = Timer(const Duration(seconds: 4), _goToLogin);
  }

  void _onLogoTap() {
    if (_skipped) return;
    _skipped = true;
    _mainController.reverse().then((_) => _goToLogin());
    _timer?.cancel();
  }

  @override
  void dispose() {
      _progressController.dispose();
    _mainController.dispose();
    _sunriseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF438E48); // Leaf Green
    const Color brandGold = Color(0xFFC79E58); // Map Pin Gold
    const Color bgDark = Colors.white; // Set to pure white
    const String outfitFont = 'Outfit';

    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          // Solid white background
          Container(color: bgDark),
          // Animated grid overlay
          const Positioned.fill(
            child: AnimatedBackgroundGrid(color: Colors.black12),
          ),
          // Centered logo and content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _onLogoTap,
                  child: AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacityAnim.value,
                        child: Transform.scale(
                          scale: _logoScaleAnim.value,
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        'assets/icons/bukidlink-main-logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Bukid',
                        style: const TextStyle(
                          fontFamily: outfitFont,
                          color: brandGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'Link',
                        style: const TextStyle(
                          fontFamily: outfitFont,
                          color: brandGold,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Bridging the gap from farm to map.",
                  style: TextStyle(
                    fontFamily: outfitFont,
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, child) {
                    return SizedBox(
                      width: 220,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _progressAnim.value,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: brandGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 220 * _progressAnim.value - 18,
                            child: Icon(Icons.agriculture_rounded, color: brandGold, size: 32),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, child) {
                    String phrase;
                    double v = _progressAnim.value;
                    if (v < 0.33) {
                      phrase = "Preparing your field...";
                    } else if (v < 0.66) {
                      phrase = "Planting the seeds...";
                    } else if (v < 0.95) {
                      phrase = "Growing your crops...";
                    } else {
                      phrase = "Harvesting and linking...";
                    }
                    return Text(
                      phrase,
                      style: const TextStyle(
                        fontFamily: outfitFont,
                        color: Colors.grey,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackgroundGrid extends StatefulWidget {
  final Color color;
  const AnimatedBackgroundGrid({super.key, required this.color});

  @override
  State<AnimatedBackgroundGrid> createState() => _AnimatedBackgroundGridState();
}

class _AnimatedBackgroundGridState extends State<AnimatedBackgroundGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5)
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: GridPainter(
              offset: _controller.value,
              color: widget.color
          ),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final double offset;
  final Color color;

  GridPainter({required this.offset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double spacing = 40.0;

    // Draw vertical lines with scrolling effect
    double yOff = offset * spacing;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = -spacing; i < size.height; i += spacing) {
      // Move lines downwards to simulate "Flow" or "Traffic"
      double y = i + yOff;
      if (y > size.height) y -= (size.height + spacing);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => true;
}