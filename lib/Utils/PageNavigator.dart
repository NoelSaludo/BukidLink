import 'package:flutter/material.dart';

enum PageTransitionType {
  slideFromTop,      // Default: slide from top
  slideFromRight,    // Smooth slide from right (for category pages)
  fadeIn,            // Fade transition (for modals/dialogs)
  scaleAndFade,      // Scale and fade (for detail pages)
  slideFromBottom,   // Slide from bottom (for sheets)
}

class PageNavigator {
  // Default navigation with slide from top (original behavior)
  void goTo(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(CreateRoute(page));
  }

  void goToAndKeep(BuildContext context, Widget page) {
    Navigator.of(context).push(CreateRoute(page));
  }

  // Navigation with custom transition
  void goToWithTransition(
    BuildContext context,
    Widget page,
    PageTransitionType transitionType,
  ) {
    Navigator.of(context).pushReplacement(
      CreateRouteWithTransition(page, transitionType),
    );
  }

  void goToAndKeepWithTransition(
    BuildContext context,
    Widget page,
    PageTransitionType transitionType,
  ) {
    Navigator.of(context).push(
      CreateRouteWithTransition(page, transitionType),
    );
  }

  // Sleek fade and slide for category/product pages (most common for homepage navigation)
  void goToSleek(BuildContext context, Widget page) {
    Navigator.of(context).push(
      CreateRouteWithTransition(page, PageTransitionType.slideFromRight),
    );
  }

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Default route (slide from top - original)
  Route CreateRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeInSine;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  // Custom route with different transition types
  Route CreateRouteWithTransition(Widget page, PageTransitionType type) {
    switch (type) {
      case PageTransitionType.slideFromTop:
        return _createSlideFromTopRoute(page);
      
      case PageTransitionType.slideFromRight:
        return _createSlideFromRightRoute(page);
      
      case PageTransitionType.fadeIn:
        return _createFadeRoute(page);
      
      case PageTransitionType.scaleAndFade:
        return _createScaleAndFadeRoute(page);
      
      case PageTransitionType.slideFromBottom:
        return _createSlideFromBottomRoute(page);
    }
  }

  // Slide from top (original)
  Route _createSlideFromTopRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeInSine;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  // Sleek slide from right with fade (perfect for category/product pages)
  Route _createSlideFromRightRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final slideTween = Tween(begin: begin, end: end);
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
        
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: slideTween.animate(curvedAnimation),
          child: FadeTransition(
            opacity: fadeTween.animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // Simple fade (for overlays/modals)
  Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }

  // Scale and fade (for detail pages with emphasis)
  Route _createScaleAndFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubicEmphasized;
        
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        final scaleTween = Tween<double>(begin: 0.92, end: 1.0);
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

        return ScaleTransition(
          scale: scaleTween.animate(curvedAnimation),
          child: FadeTransition(
            opacity: fadeTween.animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // Slide from bottom (for bottom sheets or upward navigation)
  Route _createSlideFromBottomRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}

