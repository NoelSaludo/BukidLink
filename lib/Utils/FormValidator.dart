import 'package:email_validator/email_validator.dart';
import 'package:bukidlink/Pages/SignUpContinuedPage.dart';

class FormValidator {
  String? signupUsernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length){
      return 'Username must not contain spaces';
    }
    if (int.tryParse(value[0]) != null) {
      return 'Username must not start with a number';
    }
    if (value.length <= 2) {
      return 'Username should be at least 3 characters long';
    }
    return null;
  }

  String? loginUsernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? signupPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length){
      return 'Password must not contain spaces';
    }
    if (value.length <= 9) {
      return 'Password should be at least 10 characters long';
    }
    return null;
  }

  String? loginPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length){
      return 'Username must not contain spaces';
    }
    if (int.tryParse(value[0]) != null) {
      return 'Username must not start with a number';
    }
    if (value.length <= 2) {
      return 'Username should be at least 3 characters long';
    }
    return null;
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    // String password = SignUpContinuedPage().passwordController.text.trim();
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    // if (value != password) {
    //   return 'Value must be the same as Password field';
    // }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!EmailValidator.validate(value.trim())){
      return 'Incorrect Email Address format';
    }
    return null;
  }
  
  String? tempAddressValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length){
      return 'Address must not contain spaces';
    }
    if (int.tryParse(value[0]) != null) {
      return 'Address must not start with a number';
    }
    if (value.length <= 2) {
      return 'Address should be at least 3 characters long';
    }
    return null;
  }

  String? tempContactNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length){
      return 'Address must not contain spaces';
    }
    if (int.tryParse(value[0]) != null) {
      return 'Address must not start with a number';
    }
    if (value.length <= 2) {
      return 'Address should be at least 3 characters long';
    }
    return null;
  }
}