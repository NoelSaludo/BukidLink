import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/auth/AuthLayout.dart';
import 'package:bukidlink/widgets/auth/AuthTextField.dart';
import 'package:bukidlink/widgets/auth/AuthButton.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Pages/SignUpContinuedPage.dart';
import 'package:bukidlink/services/google_auth.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/Pages/LoginPage.dart';
import 'package:bukidlink/Utils/FormValidator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<String> activeTab = ValueNotifier<String>('Consumer');
  bool isLoading = false;

  final FormValidator formValidator = FormValidator();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    contactNumberController.dispose();
    activeTab.dispose();
    super.dispose();
  }

  void handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (mounted) {
        if (userCredential != null) {
          PageNavigator().goTo(context, LoadingPage(userType: 'Consumer'));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Google sign-in error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      PageNavigator().goToAndKeep(
        context,
        SignUpContinuedPage(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          emailAddress: emailAddressController.text,
          address: addressController.text,
          contactNumber: contactNumberController.text,
          accountType: activeTab.value,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Let\'s get you started!',
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
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: firstNameController,
                    hintText: 'First Name',
                    validator: formValidator.nameValidator,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: AuthTextField(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    validator: formValidator.nameValidator,
                  ),
                ),
              ],
            ),
            AuthTextField(
              controller: emailAddressController,
              hintText: 'Email Address',
              validator: formValidator.emailValidator,
            ),
            AuthTextField(
              controller: addressController,
              hintText: 'Address',
              validator: formValidator.tempAddressValidator,
            ),
            AuthTextField(
              controller: contactNumberController,
              hintText: 'Contact Number',
              validator: formValidator.tempContactNumberValidator,
            ),
            const SizedBox(height: 16.0),
            const Text('Account Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            _buildAccountTypeSelector(),
            const SizedBox(height: 16.0),
            AuthButton(onPressed: _handleSignUp, text: 'Continue'),
            const SizedBox(height: 12.0),
            _buildGoogleSignInButton(),
            const SizedBox(height: 12.0),
            _buildLoginLink(),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeSelector() {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Consumer'),
              selected: value == 'Consumer',
              onSelected: (selected) {
                if (selected) activeTab.value = 'Consumer';
              },
            ),
            const SizedBox(width: 8.0),
            ChoiceChip(
              label: const Text('Farmer'),
              selected: value == 'Farmer',
              onSelected: (selected) {
                if (selected) activeTab.value = 'Farmer';
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: 260,
      child: ElevatedButton.icon(
        icon: Image.asset(
          'assets/icons/google-logo.png',
          height: 24.0,
          width: 24.0,
        ),
        label: const Text('Continue with Google'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
        ),
        onPressed: isLoading ? null : handleGoogleSignIn,
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () => PageNavigator().goToAndKeep(context, const LoginPage()),
      child: const Text.rich(
        TextSpan(
          text: 'Have an account? ',
          children: [
            TextSpan(
              text: 'Log In',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}