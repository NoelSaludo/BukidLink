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
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
      resizeToAvoidBottomInset: false,
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
      children: [
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
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20.0),
                  EmailField(
                    controller: emailController,
                    mode: 'Login',
                    forceErrorText: null,
                    onChanged: (_) {},
                  ),
                  PasswordField(
                    controller: passwordController,
                    mode: 'Login',
                    forceErrorText: null,
                    onChanged: (_) {},
                  ),
                  ForgotPassword(onPressed: () => handleLogin(context)),
                  const Spacer(),
                  LoginorSigninButton(
                    onPressed: () => handleLogin(context),
                    mode: 'Login',
                  ),
                  const SizedBox(height: 10.0),
                  // Google Sign-In button
                  SizedBox(
                    width: 260,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                      ),
                      onPressed: () => handleGoogleSignIn(context),
                    ),
                  ),
                  GoToSignUp(onPressed: () => goToSignUp(context)),
                  const SizedBox(height: 17.0),
                ],
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
