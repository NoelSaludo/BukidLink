import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:bukidlink/Widgets/SignupandLogin/WelcomeText.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LoginorSigninButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/UsernameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/PasswordField.dart';
import 'package:bukidlink/Utils/FormValidator.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/Pages/SignUpPage.dart';
import 'package:bukidlink/Widgets/ForgotPassword.dart';
import 'package:bukidlink/Widgets/SignUpAndLogin/LoginLogo.dart';
import 'package:bukidlink/Widgets/SignUpAndLogin/GoToSignUp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? forceErrorText;
  bool isLoading = false;

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    if (forceErrorText != null) {
      setState(() {
        forceErrorText = null;
      });
    }
  }

  void handleLogin(BuildContext context) {
    final bool isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);
    // final String? errorText = await validateInputFromDatabase({
    // });

    // if(context.mounted) {
    //   setState(() => isLoading = false);
    //   if(errorText != null) {
    //     setState(() {
    //       forceErrorText = errorText;
    //     });
    //   }
    // }
    PageNavigator().goTo(context, LoadingPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 73, 47),
      resizeToAvoidBottomInset: false,
      body: _buildContent(context),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20.0),
                  UsernameField(controller: usernameController, mode: 'Login'),
                  PasswordField(controller: passwordController, mode: 'Login'),
                  ForgotPassword(onPressed: () => handleLogin(context)),
                  const Spacer(),
                  LoginorSigninButton(
                    onPressed: () => handleLogin(context),
                    mode: 'Login',
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

  Widget _buildTabButton(String label, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green : Colors.white,
        foregroundColor: isActive ? Colors.white : Colors.green[800],
        minimumSize: const Size(100, 35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  void goBack(BuildContext context) {
    PageNavigator().goBack(context);
  }

  Future<String?> validateInputFromServer(
    String emailAddress,
    String address,
    String contactNumber,
  ) async {}
}
