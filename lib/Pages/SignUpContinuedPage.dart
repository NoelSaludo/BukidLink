import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/SignupandLogin/SignUpHeader.dart';
import 'package:bukidlink/widgets/auth/AuthTextField.dart';
import 'package:bukidlink/widgets/auth/AuthButton.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/Pages/EmailVerificationPage.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Utils/FormValidator.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Use an instance of FormValidator and call its instance methods
  final FormValidator formValidator = FormValidator();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    farmAddressController.dispose();
    farmNameController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = User(
        id: '',
        username: usernameController.text,
        password: passwordController.text,
        firstName: widget.firstName,
        lastName: widget.lastName,
        emailAddress: widget.emailAddress,
        address: widget.address,
        contactNumber: widget.contactNumber,
        profilePic: '/images/default_profile.png',
        type: widget.accountType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // First create the Firebase Auth user (send verification). Firestore
      // documents will be created after the user verifies their email.
      final farmObj = widget.accountType == 'Farmer'
          ? Farm(
              id: '',
              name: farmNameController.text,
              address: farmAddressController.text,
              ownerId: FirebaseFirestore.instance.doc('users/placeholder'),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : null;

      // Use explicit if/else to call the appropriate registration method
      // and capture the returned UserCredential (or null on failure).
      var userCredential;
      if (widget.accountType == 'Farmer') {
        userCredential = await UserService().registerFarm(user, farmObj!);
      } else {
        userCredential = await UserService().registerUser(user);
      }

      if (mounted) {
        if (userCredential != null) {
          // On successful auth creation, show email verification flow and
          // pass the user/farm objects so they can be saved after verification.
          PageNavigator().goTo(
            context,
            EmailVerificationPage(
              userType: widget.accountType,
              emailAddress: widget.emailAddress,
              pendingUser: user,
              pendingFarm: farmObj,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mirror the layout used in SignUpPage: gradient background + SignUpHeader
    final height = MediaQuery.of(context).size.height;

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
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: height * 0.10),
                    child: const SignUpHeader(),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: height * 0.60,
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
                    child: _buildForm(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          // match SignUpPage padding inside the white sheet
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),

              // Added descriptive heading for this step (avoid numeric "Step 2")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    Text(
                      'Create your account credentials',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.DARK_TEXT,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'Pick a username and secure password to sign in later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.DARK_TEXT.withAlpha(180),
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                ),
              ),

              AuthTextField(
                controller: usernameController,
                hintText: 'Username',
                validator: formValidator.signupUsernameValidator,
              ),
              const SizedBox(height: 8.0),
              AuthTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                validator: formValidator.signupPasswordValidator,
              ),
              const SizedBox(height: 8.0),
              AuthTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
                validator: (value) {
                  final baseValidation = formValidator.confirmPasswordValidator(
                    value,
                  );
                  if (baseValidation != null) return baseValidation;
                  if (value != passwordController.text) {
                    return 'Value must be the same as Password field';
                  }
                  return null;
                },
              ),
              if (widget.accountType == 'Farmer') ...[
                const SizedBox(height: 8.0),
                AuthTextField(
                  controller: farmNameController,
                  hintText: 'Farm Name',
                  validator: formValidator.farmNameValidator,
                ),
                const SizedBox(height: 8.0),
                AuthTextField(
                  controller: farmAddressController,
                  hintText: 'Farm Address',
                  validator: formValidator.farmAddressValidator,
                ),
              ],
              const SizedBox(height: 16.0),

              // use the same gradient-styled button as SignUpPage
              AuthButton(
                onPressed: () {
                  if (isLoading) return;
                  _handleSignUp();
                },
                text: isLoading ? 'Creating Account...' : 'Sign Up',
                useLoginGradient: true,
              ),

              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
