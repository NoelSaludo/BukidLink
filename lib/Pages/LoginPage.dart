import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LoginorSigninButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/UsernameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/PasswordField.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/Pages/SignUpPage.dart';
import 'package:bukidlink/Widgets/ForgotPassword.dart';
import 'package:bukidlink/Widgets/SignUpAndLogin/LoginLogo.dart';
import 'package:bukidlink/Widgets/SignUpAndLogin/GoToSignUp.dart';
import 'package:bukidlink/services/google_auth.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Controller and focus nodes for auto-scrolling when inputs gain focus
  final ScrollController _scrollController = ScrollController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  // Keys to locate fields in the scroll view
  final GlobalKey _emailFieldKey = GlobalKey();
  final GlobalKey _passwordFieldKey = GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listeners that will only trigger auto-scroll when the keyboard is visible.
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
          if (keyboardVisible) _scrollToField(_emailFieldKey);
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
          if (keyboardVisible) _scrollToField(_passwordFieldKey);
        });
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _scrollToField(GlobalKey key) async {
    // Small delay to allow layout/keyboard animation to settle
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted || !_scrollController.hasClients) return;

    final BuildContext? fieldContext = key.currentContext;
    if (fieldContext == null) return;

    try {
      final RenderBox fieldBox = fieldContext.findRenderObject() as RenderBox;
      final scrollBox = _scrollController.position.context.storageContext.findRenderObject() as RenderBox;
      final fieldOffset = fieldBox.localToGlobal(Offset.zero, ancestor: scrollBox);
      final target = _scrollController.offset + fieldOffset.dy - 20.0;

      final clamped = target.clamp(0.0, _scrollController.position.maxScrollExtent);
      await _scrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } catch (_) {
      // ignore measurement/animation errors
    }
  }

  // Handler for signing in with Google using the existing FirebaseService
  void handleGoogleSignIn(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (context.mounted) {
        setState(() => isLoading = false);
        if (userCredential != null) {
          // Proceed to loading / main flow on successful Google sign-in
          PageNavigator().goTo(
              context,
              LoadingPage(
                userType: UserService().getCurrentUser()!.type ?? "Consumer",
              ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in failed')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in error: $e')),
        );
      }
    }
  }

  void handleLogin(BuildContext context) async {
    final bool isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);

    try {
      // Use UserService to login with username (it will look up the email)
      await UserService().loginUser(
        emailController.text.trim(),
        passwordController.text,
      );

      if (context.mounted) {
        setState(() => isLoading = false);
        PageNavigator().goTo(
          context,
          LoadingPage(
            userType: UserService().getCurrentUser()!.type ?? "Consumer",
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => isLoading = false);

        // Extract the error message from the exception
        String errorMessage = 'Login failed. Please try again.';
        if (e is Exception) {
          // Get the message after "Exception: "
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow the scaffold to resize when the keyboard appears so focused fields
      // can be scrolled into view.
      resizeToAvoidBottomInset: true,
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
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Positioned(bottom: height * 0.55 - 140, child: const LoginLogo()),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: height * 0.55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    physics: keyboardVisible ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                    keyboardDismissBehavior: keyboardVisible
                        ? ScrollViewKeyboardDismissBehavior.onDrag
                        : ScrollViewKeyboardDismissBehavior.manual,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 20.0),
                        Container(
                          key: _emailFieldKey,
                          child: EmailField(
                            controller: emailController,
                            mode: 'Login',
                            forceErrorText: null,
                            onChanged: (_) {},
                            focusNode: _emailFocusNode,
                          ),
                        ),
                        Container(
                          key: _passwordFieldKey,
                          child: PasswordField(
                            controller: passwordController,
                            mode: 'Login',
                            forceErrorText: null,
                            onChanged: (_) {},
                            focusNode: _passwordFocusNode,
                          ),
                        ),
                        ForgotPassword(onPressed: () => handleLogin(context)),
                        const SizedBox(height: 12.0),
                        LoginorSigninButton(
                          onPressed: () => handleLogin(context),
                          mode: 'Login',
                        ),
                        const SizedBox(height: 10.0),
                        // Google Sign-In button
                        Container(
                          width: 260,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.08),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => handleGoogleSignIn(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(260, 55),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/google-logo.png',
                                  height: 24.0,
                                  width: 24.0,
                                ),
                                const SizedBox(width: 12.0),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GoToSignUp(onPressed: () => goToSignUp(context)),
                        const SizedBox(height: 17.0),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void goToSignUp(BuildContext context) {
    PageNavigator().goToAndKeep(context, SignUpPage());
  }

  void goBack(BuildContext context) {
    PageNavigator().goBack(context);
  }
}
