import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/SignupandLogin/WelcomeText.dart';
import 'package:bukidlink/Widgets/SignupandLogin/LoginorSigninButton.dart';
import 'package:bukidlink/Widgets/SignupandLogin/UsernameField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/PasswordField.dart';
import 'package:bukidlink/Widgets/SignupandLogin/ConfirmPasswordField.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/Widgets/CustomBackButton.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/data/UserData.dart';


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

  void handleSignUp(BuildContext context) async{
    final bool isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);
    final String? errorText = await validateInputFromServer(usernameController.text);

    if(context.mounted) {
      setState(() => isLoading = false);
      if(errorText != null) {
        setState(() {
          forceErrorText = errorText;
        });
      }
    }
    insertNewUser(
      usernameController.text, 
      passwordController.text, 
      widget.firstName, 
      widget.lastName, 
      widget.emailAddress, 
      widget.address, 
      widget.contactNumber,
      'input not set yet');
    PageNavigator().goTo(context, LoadingPage());
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
                      UsernameField(
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
                      Text(
                        'Account Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                                onTap: () => accountType.value = 'Consumer',
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: tab == 'Consumer'
                                        ? const Color.fromARGB(
                                            255,
                                            202,
                                            232,
                                            109,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Consumer',
                                    style: TextStyle(
                                      color: tab == 'Consumer'
                                          ? Colors.black
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => accountType.value = 'Farmer',
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: tab == 'Farmer'
                                        ? const Color.fromARGB(
                                            255,
                                            202,
                                            232,
                                            109,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Farmer',
                                    style: TextStyle(
                                      color: tab == 'Farmer'
                                          ? Colors.black
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  String hashPassword(String password){
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  Future<void> insertNewUser(
    String username, 
    String password, 
    String firstName, 
    String lastName, 
    String emailAddress, 
    String address, 
    String contactNumber,
    String farm,) async{
      // final db = await;//access database
      // if(accountType.value == 'Consumer'){
      //   await db.insert(
      //     'Consumer',
      //     {
      //       'username': username,
      //       'password': hashedPassword,
      //       'firstName': firstName,
      //       'lastName': lastName,
      //       'emailAddress': emailAddress,
      //       'address': address,
      //       'contactNumber': contactNumber
      //     }
      //   );
      // }
      
      //adds consumer object to consumerData
      switch(accountType){
        case 'consumer': UserData.addConsumer(
        username, 
        hashPassword(password), 
        firstName, 
        lastName, 
        emailAddress, 
        address, 
        contactNumber,);
        break;
        case 'farmer': UserData.addFarmer(
        username, 
        hashPassword(password), 
        firstName, 
        lastName, 
        emailAddress, 
        address, 
        contactNumber,
        farm,);
        break;
      }
      
  }

  Future<String?> validateInputFromServer(
    String username,
  ) async {
    List<User> takenUsernames = [];
    takenUsernames = UserData.getAllUsers();
    for(var i = 0; i < takenUsernames.length; i++){
      if((takenUsernames[i].username).contains(username)){
        return 'Username \'$username\' is already taken';
      }
    }
    return null;
  }
}
