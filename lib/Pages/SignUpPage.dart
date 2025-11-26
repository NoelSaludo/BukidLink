import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/auth/AuthTextField.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/SignupandLogin/SignUpHeader.dart';
import 'package:bukidlink/widgets/SignupandLogin/GoToLogin.dart';
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
  void initState() {
    super.initState();
    // No progress listeners needed anymore
  }

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
      setState(() => isLoading = true);

      // Navigate to continued signup page (no progress animation)
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

      // restore loading state (page will stay underneath continued page)
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: height * 0.60, // lowered sheet so header/logo can be fully visible
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
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10.0),

              // Added descriptive heading for this step (avoid numeric "Step 1")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.DARK_TEXT,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'Provide a few personal details so we can create your account.',
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

              const SizedBox(height: 16.0),
              AuthTextField(
                controller: firstNameController,
                hintText: 'First Name',
                validator: formValidator.nameValidator,
              ),
              const SizedBox(height: 8.0),
              AuthTextField(
                controller: lastNameController,
                hintText: 'Last Name',
                validator: formValidator.nameValidator,
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Account Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 8.0),
              _buildAccountTypeSelector(),
              const SizedBox(height: 18.0),
              // Inline gradient-styled Continue button (matches Login button appearance)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5C8D43),
                        Color(0xFF9BCF6F),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      isLoading ? 'Please wait...' : 'Continue',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              _buildGoogleSignInButton(),
              const SizedBox(height: 12.0),
              _buildLoginLink(),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeSelector() {
    return ValueListenableBuilder<String>(
      valueListenable: activeTab,
      builder: (context, value, child) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: 'Consumer — buy products',
                  child: Semantics(
                    selected: value == 'Consumer',
                    label: 'Consumer account type',
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag, size: 18, color: value == 'Consumer' ? Colors.white : AppColors.DARK_TEXT),
                          const SizedBox(width: 6),
                          const Text('Consumer'),
                        ],
                      ),
                      selected: value == 'Consumer',
                      onSelected: (_) => activeTab.value = 'Consumer',
                      selectedColor: AppColors.HEADER_GRADIENT_START,
                      backgroundColor: AppColors.INACTIVE_GREY,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      labelStyle: TextStyle(color: value == 'Consumer' ? Colors.white : AppColors.DARK_TEXT),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Tooltip(
                  message: 'Farmer — sell products',
                  child: Semantics(
                    selected: value == 'Farmer',
                    label: 'Farmer account type',
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.agriculture, size: 18, color: value == 'Farmer' ? Colors.white : AppColors.DARK_TEXT),
                          const SizedBox(width: 6),
                          const Text('Farmer'),
                        ],
                      ),
                      selected: value == 'Farmer',
                      onSelected: (_) => activeTab.value = 'Farmer',
                      selectedColor: AppColors.HEADER_GRADIENT_START,
                      backgroundColor: AppColors.INACTIVE_GREY,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      labelStyle: TextStyle(color: value == 'Farmer' ? Colors.white : AppColors.DARK_TEXT),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                value == 'Consumer'
                    ? 'Choose Consumer if you want to browse and buy local products.'
                    : 'Choose Farmer to list products and manage orders.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.DARK_TEXT.withAlpha(179), fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : handleGoogleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/google-logo.png',
                height: 20.0,
                width: 20.0,
              ),
              const SizedBox(width: 10),
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.HEADER_GRADIENT_START,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return GoToLogin(
      onPressed: () => PageNavigator().goToAndKeep(context, const LoginPage()),
    );
  }
}