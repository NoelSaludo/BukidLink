import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/auth/AuthLayout.dart';
import 'package:bukidlink/widgets/auth/AuthTextField.dart';
import 'package:bukidlink/widgets/auth/AuthButton.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Utils/FormValidator.dart';

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
  final TextEditingController confirmPasswordController = TextEditingController();
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

      final userCredential = widget.accountType == 'Farmer'
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

      if (mounted) {
        if (userCredential != null) {
          PageNavigator().goTo(context, LoadingPage(userType: widget.accountType));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Almost Done!',
      subtitle: 'Complete your profile',
      form: _buildForm(),
      showBackButton: true,
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            AuthTextField(
              controller: usernameController,
              hintText: 'Username',
              validator: formValidator.signupUsernameValidator,
            ),
            AuthTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
              validator: formValidator.signupPasswordValidator,
            ),
            AuthTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: true,
              validator: (value) {
                final baseValidation = formValidator.confirmPasswordValidator(value);
                if (baseValidation != null) return baseValidation;
                if (value != passwordController.text) {
                  return 'Value must be the same as Password field';
                }
                return null;
              },
            ),
            if (widget.accountType == 'Farmer') ...[
              AuthTextField(
                controller: farmNameController,
                hintText: 'Farm Name',
                validator: formValidator.farmNameValidator,
              ),
              AuthTextField(
                controller: farmAddressController,
                hintText: 'Farm Address',
                validator: formValidator.farmAddressValidator,
              ),
            ],
            AuthButton(
              onPressed: () {
                if (isLoading) return;
                _handleSignUp();
              },
              text: isLoading ? 'Creating Account...' : 'Sign Up',
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}