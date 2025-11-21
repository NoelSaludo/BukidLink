import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/SignupandLogin/WelcomeText.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LoginorSigninButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/FirstNameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LastNameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/EmailAddressField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/AddressField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/ContactNumberField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/CustomUsernameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/CustomPasswordField.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Widgets/CustomBackButton.dart';
import 'package:bukidlink/services/google_auth.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/models/User.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? forceErrorText;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    contactNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    if (forceErrorText != null) {
      setState(() {
        forceErrorText = null;
      });
    }
  }

  void onUsernameChanged(String value) {
    // Handle username changes if needed
    onChanged(value);
  }

  void onPasswordChanged(String value) {
    // Handle password changes if needed
    onChanged(value);
  }

  void onConfirmPasswordChanged(String value) {
    // Handle confirm password changes if needed
    onChanged(value);
  }

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      obscureConfirmPassword = !obscureConfirmPassword;
    });
  }

  // Handler for Google Sign-In using existing FirebaseService
  void handleGoogleSignIn(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (context.mounted) {
        setState(() => isLoading = false);
        if (userCredential != null) {
          // Navigate to loading/main flow on successful sign-in
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

  User _buildUserFromForm(String accountType) {
    return User(
      id: '',
      username: usernameController.text.trim(),
      password: passwordController.text,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      emailAddress: emailAddressController.text.trim(),
      address: addressController.text.trim(),
      contactNumber: contactNumberController.text.trim(),
      profilePic: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void handleSignUp(BuildContext context, String accountType) async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => isLoading = true);
    try {
      final user = _buildUserFromForm(accountType);
      final credential = await UserService().signInWithEmailAndPassword(user);

      if (context.mounted) {
        setState(() => isLoading = false);
        if (credential != null) {
          PageNavigator().goTo(context, LoadingPage());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
     final width = MediaQuery.of(context).size.width;

     final ValueNotifier<String> activeTab = ValueNotifier<String>('Sign Up');
     activeTab.value = 'Consumer';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          children: [
            // Top-left back button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                child: CustomBackButton(
                  onPressed: () => PageNavigator().goBack(context),
                ),
              ),
            ),

            // Greeting area
            const SizedBox(height: 20.0),
            const WelcomeText(text: 'Hello There!'),
            const SizedBox(height: 20.0),

            // The rounded form container. Removed fixed height so it can size naturally
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: Center(
                child: Container(
                  width: width * 0.90,
                  // No fixed height to allow the container to grow and the SingleChildScrollView to scroll
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, // Starting point of the gradient
                      end: Alignment.bottomCenter, // Ending point of the gradient
                      colors: [
                        const Color.fromARGB(
                          255,
                          200,
                          230,
                          108,
                        ), // First color in the gradient
                        const Color.fromARGB(
                          255,
                          52,
                          82,
                          52,
                        ), // Second color in the gradient
                      ],
                      stops: [0.0, 1.0], // Optional: Define color distribution
                    ),
                  ),
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: ValueListenableBuilder<String>(
                        valueListenable: activeTab,
                        builder: (context, tab, _) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10.0),

                              // --- Input fields ---
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: FirstNameField(controller: firstNameController),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    flex: 1,
                                    child: LastNameField(controller: lastNameController),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              EmailAddressField(controller: emailAddressController),
                              const SizedBox(height: 8.0),
                              AddressField(
                                controller: addressController,
                                onChanged: onChanged,
                              ),
                              const SizedBox(height: 8.0),
                              ContactNumberField(controller: contactNumberController),
                              const SizedBox(height: 8.0),
                              CustomUsernameField(
                                controller: usernameController,
                                onChanged: onUsernameChanged,
                              ),
                              const SizedBox(height: 8.0),
                              CustomPasswordField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                onChanged: onPasswordChanged,
                                toggleObscureText: togglePasswordVisibility,
                                label: 'Password',
                              ),
                              const SizedBox(height: 8.0),
                              CustomPasswordField(
                                controller: confirmPasswordController,
                                obscureText: obscureConfirmPassword,
                                onChanged: onConfirmPasswordChanged,
                                toggleObscureText: toggleConfirmPasswordVisibility,
                                label: 'Confirm Password',
                              ),
                              const SizedBox(height: 20.0),
                              // Google Sign-In button
                              SizedBox(
                                width: 220,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.login),
                                  label: const Text('Continue with Google'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                  ),
                                  onPressed: () => handleGoogleSignIn(context),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              // --- Action button ---
                              LoginorSigninButton(
                                onPressed: () {
                                  handleSignUp(context, tab);
                                },
                                mode: 'SignUp',
                              ),

                              const SizedBox(height: 30.0),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

   void goBack(BuildContext context) {
     PageNavigator().goBack(context);
   }

   Future<String?> validateInputFromServer(
     String emailAddress,
     String address,
     String contactNumber,
   ) async {
     // Not implemented yet — return null to indicate "no error" by default.
     return null;
   }
 }
