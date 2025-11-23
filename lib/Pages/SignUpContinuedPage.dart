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
import 'package:bukidlink/models/Farm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    required this.accountType,
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
    accountType.value =
        widget.accountType; // <-- set the value from the previous page
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
        // Plain password - Firebase handles hashing
        firstName: widget.firstName,
        lastName: widget.lastName,
        emailAddress: widget.emailAddress,
        address: widget.address,
        contactNumber: widget.contactNumber,
        profilePic: '/images/default_profile.png',
        // Default empty, can be set later
        type: accountType
            .value, // Use the selected account type (Consumer or Farmer)
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Use UserService to create account and sign in. If registering a Farmer,
      // create a Farm object from the controllers and call registerFarm.
      final userCredential = accountType.value == 'Farmer'
          ? await UserService().registerFarm(
              user,
              Farm(
                id: '',
                name: farmNameController.text,
                address: farmAddressController.text,
                ownerId: FirebaseFirestore.instance.doc('users/placeholder'),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
          : await UserService().registerUser(user);

      if (context.mounted) {
        setState(() => isLoading = false);

        if (userCredential != null) {
          // Successfully signed up and signed in
          PageNavigator().goTo(
            context,
            LoadingPage(userType: widget.accountType),
          );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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

            // Form container (extracted to helper)
            _buildFormCard(width, height),
          ],
        ),
      ),
    );
  }

  // --- Private builders ---

  Widget _buildFormCard(double width, double height) {
    return Center(
      child: Container(
        width: width * 0.90,
        height: height * 0.70,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 160, 190, 92),
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
            builder: (context, constraints) => _buildFormLayout(constraints),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: IntrinsicHeight(child: _buildForm()),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: ValueListenableBuilder<String>(
        valueListenable: accountType,
        builder: (context, tab, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50.0),
              _buildFields(tab),
              const SizedBox(height: 16.0),
              const Spacer(),
              _buildSubmitButton(tab),
              const SizedBox(height: 16.0),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFields(String tab) {
    return Column(
      children: [
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
          FarmNameField(controller: farmNameController, onChanged: onChanged),
          FarmAddressField(
            controller: farmAddressController,
            onChanged: onChanged,
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(String tab) {
    return LoginorSigninButton(
      onPressed: () => handleSignUp(context),
      mode: tab,
    );
  }

  void goBack(BuildContext context) {
    PageNavigator().goBack(context);
  }
}
