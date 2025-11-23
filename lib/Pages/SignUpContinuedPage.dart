import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/SignupandLogin/WelcomeText.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LoginorSigninButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/UsernameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/PasswordField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/ConfirmPasswordField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/FarmAddress.dart';
import 'package:bukidlink/Widgets/SignupandLogin/FarmName.dart';
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
  final String accountType;
  const SignUpContinuedPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.address,
    required this.contactNumber,
    required this.accountType
    });

  @override
  State<SignUpContinuedPage> createState() => _SignUpContinuedPageState();
}

class _SignUpContinuedPageState extends State<SignUpContinuedPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController farmAddressController = TextEditingController();
  final TextEditingController farmNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ValueNotifier<String> accountType = ValueNotifier<String>('Sign Up');
  String? forceErrorText;
  bool isLoading = false;

@override
  void initState() {
    super.initState();
    accountType.value = widget.accountType; // <-- set the value from the previous page
  }
  
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
        farmName: farmNameController.text,
        farmAddress: farmAddressController.text,
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
  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;

  return SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          // Top-left back button
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: CustomBackButton(
                onPressed: () => PageNavigator().goBack(context),
              ),
            ),
          ),

          // Greeting text
          const SizedBox(height: 30.0),
          const WelcomeText(text: 'Almost Done!'),
          const SizedBox(height: 20.0),

          // Form container
          Center(
            child: Container(
              width: width * 0.90,
              height: height * 0.70, // fixed container height
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 160, 190, 92),
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0)
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 200, 230, 108),
                    Color.fromARGB(255, 52, 82, 52),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Form(
                            key: formKey,
                            child: ValueListenableBuilder<String>(
                              valueListenable: accountType,
                              builder: (context, tab, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
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
                                    ConfirmPasswordField(controller: confirmPasswordController),
                                    if (tab == 'Farmer') ...[
                                      FarmNameField(
                                        controller: farmNameController,
                                        onChanged: onChanged,
                                      ),
                                      FarmAddressField(
                                        controller: farmAddressController,
                                        onChanged: onChanged,
                                      ),
                                    ],
                                    const SizedBox(height: 16.0),
                                    const Spacer(), // pushes button to bottom if content is short
                                    LoginorSigninButton(
                                      onPressed: () => handleSignUp(context),
                                      mode: tab,
                                    ),
                                    const SizedBox(height: 16.0),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ),
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
