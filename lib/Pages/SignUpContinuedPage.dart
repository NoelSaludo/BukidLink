import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/SignupandLogin/WelcomeText.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LoginorSigninButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/UsernameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/PasswordField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/ConfirmPasswordField.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Widgets/CustomBackButton.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/services/UserService.dart';


class SignUpContinuedPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String emailAddress;
  final String address;
  final String contactNumber;
  const SignUpContinuedPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.address,
    required this.contactNumber,
    });

  @override
  State<SignUpContinuedPage> createState() => _SignUpContinuedPageState();
}

class _SignUpContinuedPageState extends State<SignUpContinuedPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ValueNotifier<String> accountType = ValueNotifier<String>('Sign Up');
  String? forceErrorText;
  bool isLoading = false;

  void dispose() {
    usernameController.dispose();
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

  void handleSignUp(BuildContext context) async {
    final bool isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create User model with all collected data
      final user = User(
        id: '',
        // Firebase will generate the UID, we'll use empty string for now
        username: usernameController.text,
        password: passwordController.text,
        // Plain password - Firebase handles hashing
        firstName: widget.firstName,
        lastName: widget.lastName,
        emailAddress: widget.emailAddress,
        address: widget.address,
        contactNumber: widget.contactNumber,
        profilePic: '',
        // Default empty, can be set later
        type: accountType
            .value, // Use the selected account type (Consumer or Farmer)
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Use UserService to create account and sign in
      final userCredential = await UserService().register(
          user);

      if (context.mounted) {
        setState(() => isLoading = false);

        if (userCredential != null) {
          // Successfully signed up and signed in
          PageNavigator().goTo(context, LoadingPage());
        } else {
          // Sign-up failed
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
    final height = MediaQuery
        .of(context)
        .size
        .height;
    final width = MediaQuery
        .of(context)
        .size
        .width;
    accountType.value = 'Consumer';

    return Stack(
      children: [
        const SizedBox(height: 150.0),
        Positioned(
          top: 20,
          left: 10,
          child: CustomBackButton(
            onPressed: () => PageNavigator().goBack(context),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const SizedBox(height: 150.0),
              const WelcomeText(text: 'Almost Done!'),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: width * 0.90,
            height: height * 0.70,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 160, 190, 92),
              borderRadius: BorderRadius.only(
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
              child: ValueListenableBuilder<String>(
                valueListenable: accountType,
                builder: (context, tab, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- Input fields ---
                      const SizedBox(height: 50.0),
                      EmailField(
                        controller: usernameController,
                        mode: 'SignUp',
                        forceErrorText: forceErrorText,
                        onChanged: onChanged,
                      ),
                      PasswordField(
                        controller: passwordController,
                        mode: 'SignUp',
                        forceErrorText: null,
                        onChanged: onChanged,
                      ),
                      ConfirmPasswordField(
                        controller: confirmPasswordController,

                      ),
                      const SizedBox(height: 16.0),
                      // --- Action button ---
                      const Spacer(),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: LoginorSigninButton(
                          onPressed: () {
                            if (tab == 'Consumer') {
                              handleSignUp(context);
                            } else if (tab == 'Farmer') {
                              handleSignUp(context);
                            }
                          },
                          mode: tab,
                        ),
                      ),

                      const SizedBox(height: 50.0),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
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

}
