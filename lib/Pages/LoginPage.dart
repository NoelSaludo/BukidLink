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
import 'package:bukidlink/data/UserData.dart';
import 'package:bukidlink/models/User.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:bukidlink/services/google_auth.dart';

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

  // Handler for signing in with Google using the existing FirebaseService
  void handleGoogleSignIn(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (context.mounted) {
        setState(() => isLoading = false);
        if (userCredential != null) {
          // Proceed to loading / main flow on successful Google sign-in
          PageNavigator().goTo(context, LoadingPage());
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

  void handleLogin(BuildContext context) async{
    final bool isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);
    final String? errorText = await validateInputFromServer(
    usernameController.text,
    passwordController.text);

    if(context.mounted) {
      setState(() => isLoading = false);
      if(errorText != null) {
        setState(() {
          forceErrorText = errorText;
        });
      }
      else{
      PageNavigator().goTo(context, LoadingPage());
    }
    }
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
                  UsernameField(
                    controller: usernameController,
                    mode: 'Login',
                    forceErrorText: forceErrorText,
                    onChanged: onChanged,),
                  PasswordField(
                    controller: passwordController,
                    mode: 'Login',
                    forceErrorText: forceErrorText,
                    onChanged: onChanged,),
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

String hashPassword(String password){
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  Future<String?> validateInputFromServer(
    String username,
    String password
  ) async {
    final String hashedPassword = hashPassword(password);
    List<User> existingUser = [];
    existingUser = UserData.getAllUsers();
    for(var i = 0; i < existingUser.length; i++){
      if((existingUser[i].username).contains(username)){
        if((existingUser[i].password).contains(hashedPassword)){
          return null;
        }
        else{
          return 'Incorrect Username or Password';
        }
      }
    }
    return 'Username does not exist!';
  }
}
