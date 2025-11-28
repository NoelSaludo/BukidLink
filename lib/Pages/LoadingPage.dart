import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:bukidlink/Utils/PageNavigator.dart';
import 'package:bukidlink/Pages/HomePage.dart';
import 'package:bukidlink/Pages/farmer/FarmerStorePage.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

// TODO: @joelaguzar dito nagrouroute ang app pag naglaunch
class LoadingPage extends StatefulWidget {
  final String userType;
  const LoadingPage({super.key, required this.userType});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class RippleBackground extends StatefulWidget {
  final double size;
  final Widget child;
  final Color rippleColor;
  final int rippleCount;
  final Duration duration;
  final bool animate;

  const RippleBackground({
    Key? key,
    required this.size,
    required this.child,
    this.rippleColor = AppColors.LOGIN_LOGO_BACKGROUND,
    this.rippleCount = 4,
    this.duration = const Duration(milliseconds: 1600),
    this.animate = true,
  }) : super(key: key);

  @override
  _RippleBackgroundState createState() => _RippleBackgroundState();
}

class _RippleBackgroundState extends State<RippleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _scaleAnims;
  late final List<Animation<double>> _opacityAnims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.animate) {
      _controller.repeat();
    } else {
      // keep static initial values when animations are disabled
      _controller.value = 0.0;
    }

    _scaleAnims = List.generate(widget.rippleCount, (i) {
      final start = i / widget.rippleCount;
      final end = 1.0;
      return Tween<double>(begin: 0.25, end: 2.6).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _opacityAnims = List.generate(widget.rippleCount, (i) {
      final start = i / widget.rippleCount;
      final end = 1.0;
      return Tween<double>(begin: 0.85, end: 0.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < widget.rippleCount; i++)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = _scaleAnims[i].value;
                final opacity = _opacityAnims[i].value;
                final rippleSize = widget.size * scale;
                return Center(
                  child: Container(
                    width: rippleSize,
                    height: rippleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: widget.rippleColor.withOpacity(opacity),
                        width: 10.0 * (1.0 - (i / (widget.rippleCount + 1))),
                      ),
                    ),
                  ),
                );
              },
            ),

          // The main inner circle that contains the logo
          Center(
            child: Container(
              width: widget.size * 0.9,
              height: widget.size * 0.9,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.LOGIN_LOGO_BACKGROUND,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.rippleColor.withOpacity(0.12),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class OrbitingIcons extends StatefulWidget {
  final double size;
  final double radius;
  final List<IconData> icons;
  final Color color;
  final Duration duration;
  final bool animate;

  const OrbitingIcons({
    Key? key,
    required this.size,
    required this.radius,
    required this.icons,
    this.color = Colors.white,
    this.duration = const Duration(seconds: 3),
    this.animate = true,
  }) : super(key: key);

  @override
  _OrbitingIconsState createState() => _OrbitingIconsState();
}

class _OrbitingIconsState extends State<OrbitingIcons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    if (!widget.animate) {
      _controller.value = 0.0;
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.icons.length;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: List.generate(n, (i) {
              final angle = t + (2 * math.pi * i / n);
              final x = math.cos(angle) * widget.radius;
              final y = math.sin(angle) * widget.radius;
              final scale = 0.75 + 0.4 * (0.5 + 0.5 * math.sin(angle * 2));
              final opacity = 0.5 + 0.5 * (0.5 + 0.5 * math.cos(angle));

              return Transform.translate(
                offset: Offset(x, y),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icons[i],
                        size: 18,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class AnimatedLoadingText extends StatefulWidget {
  final List<String> phrases;
  final TextStyle? style;
  final Duration period;

  const AnimatedLoadingText({
    Key? key,
    required this.phrases,
    this.style,
    this.period = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  _AnimatedLoadingTextState createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.period, (_) {
      setState(() {
        _index = (_index + 1) % widget.phrases.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        widget.phrases[_index],
        key: ValueKey<int>(_index),
        style: widget.style,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    // Drive the loading progress for a predictable, intuitive experience.
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });

    _progressController.forward();
  }

  void _navigateToNext() {
    if (widget.userType == "Farmer") {
      PageNavigator().goTo(context, const FarmerStorePage());
    } else {
      PageNavigator().goTo(context, HomePage());
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.LOGIN_BACKGROUND_START,
              AppColors.LOGIN_BACKGROUND_END,
            ],
          ),
        ),
        // Use a Stack so the circular logo sits exactly at the center of the screen
        // and the spinner/loading text can be positioned independently below it.
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: RippleBackground(
                size: 380.0,
                rippleColor: AppColors.LOGIN_LOGO_BACKGROUND,
                rippleCount: 4,
                duration: const Duration(milliseconds: 1600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/bukidlink-main-logo.png',
                      width: 146.79,
                      height: 109.18,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'BukidLink',
                      style: AppTextStyles.BUKIDLINK_LOGO,
                    ),
                  ],
                ),
              ),
            ),

            // Orbiting icons add a playful farm vibe around the logo
            Center(
              child: OrbitingIcons(
                size: 420,
                radius: 150,
                icons: const [Icons.local_florist, Icons.store, Icons.agriculture],
                color: Colors.white,
                duration: const Duration(seconds: 4),
                animate: !MediaQuery.of(context).disableAnimations,
              ),
            ),

            Align(
              alignment: const Alignment(0, 0.9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _progressController.value,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                          strokeWidth: 3.5,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      final pct = (_progressController.value * 100).toInt();
                      return Column(
                        children: [
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedLoadingText(
                            phrases: const [
                              'Starting up...',
                              'Cultivating connections...',
                              'Fetching fresh produce...',
                              'Preparing your marketplace...',
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            period: const Duration(milliseconds: 1400),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
