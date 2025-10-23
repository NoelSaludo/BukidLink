import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:bukidlink/Widgets/SignupandLogin/WelcomeText.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LoginorSigninButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/FirstNameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LastNameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/EmailAddressField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/AddressField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/ContactNumberField.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Widgets/CustomBackButton.dart';
import 'package:bukidlink/Pages/SignUpContinuedPage.dart';

class SignUpPage extends StatefulWidget{
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? forceErrorText;
  bool isLoading = false;

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    contactNumberController.dispose();
    super.dispose();
  }

  void onChanged(String value){
  if(forceErrorText != null) {
    setState(() {
      forceErrorText = null;
    });
  }
 }
  void handleSignUp(BuildContext context) {
    final bool isValid = formKey.currentState?.validate() ?? false;

    if(!isValid) {
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
    PageNavigator().goToAndKeep(context, SignUpContinuedPage());
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

  final ValueNotifier<String> activeTab = ValueNotifier<String>('Sign Up');
  activeTab.value = 'Consumer';

  return Stack(
    children: [
      const SizedBox(height:150.0),
      Positioned(
        top: 20,
        left: 10,
        child: CustomBackButton(onPressed: () => PageNavigator().goBack(context)),),
      Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const SizedBox(height:150.0),
            const WelcomeText(
              text: 'Hello There!',
            ),
            const SizedBox(height: 50.0),
            // Text(
            //   "Create Account",
            //   style: TextStyle(
            //     fontSize: 25.0,
            //   )
            // )
          ],
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: width * 0.90,
          height: height * 0.70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        gradient: LinearGradient(
          begin: Alignment.topCenter, // Starting point of the gradient
          end: Alignment.bottomCenter, // Ending point of the gradient
          colors: [
            const Color.fromARGB(255, 200, 230, 108), // First color in the gradient
            const Color.fromARGB(255, 52, 82, 52), // Second color in the gradient
          ],
          stops: [0.0, 1.0], // Optional: Define color distribution
        ),
      ),
          child: Form(
                key: formKey,
          child: ValueListenableBuilder<String>(
            valueListenable: activeTab,
            builder: (context, tab, _) {
                return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50.0),
                  
                  // --- Input fields ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FirstNameField(controller: firstNameController),
                      const SizedBox(width: 5.0),
                      LastNameField(controller: lastNameController),
                    ],
                  ),
                  EmailAddressField(controller: emailAddressController),
                  AddressField(controller: addressController, onChanged: onChanged),
                  ContactNumberField(controller: contactNumberController),
                  const SizedBox(height: 20.0,),
                  Text(
                    'Account Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  Container(
            width: 220,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                  onTap: () => activeTab.value = 'Consumer',
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: tab == 'Consumer'
                      ? const Color.fromARGB(255, 202, 232, 109)
                      : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  alignment: Alignment.center,
                  child: Text(
                    'Consumer',
                    style: TextStyle(
                      color: tab == 'Consumer' ? Colors.black : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => activeTab.value = 'Farmer',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: tab == 'Farmer'
                    ? const Color.fromARGB(255, 202, 232, 109)
                    : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Farmer',
                    style: TextStyle(
                      color: tab == 'Farmer' ? Colors.black : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
       ),
      ),
                  const Spacer(),
                  // --- Action button ---
                  LoginorSigninButton(
                    onPressed: () {
                      if (tab == 'Consumer') {
                        handleSignUp(context);
                      } else if(tab == 'Farmer'){
                        handleSignUp(context); // or go to LoginPage
                      }
                    },
                    mode: 'SignUp',
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: onPressed,
    child: Text(label),
  );
}

  void goBack(BuildContext context){
    PageNavigator().goBack(context);
  }

  Future<String?> validateInputFromServer(String emailAddress, String address, String contactNumber) async {
    
  }
}
