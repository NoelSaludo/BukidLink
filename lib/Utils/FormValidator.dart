import 'package:email_validator/email_validator.dart';
import 'package:bukidlink/Pages/SignUpContinuedPage.dart';

class FormValidator {
  String? signupUsernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length) {
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
    if (value.length != value.replaceAll(' ', '').length) {
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
    if (!EmailValidator.validate(value.trim())) {
      return 'Incorrect Email Address format';
    }
    return null;
  }

  String? tempAddressValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length != value.replaceAll(' ', '').length) {
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

    // Remove spaces for validation
    String cleanedValue = value.replaceAll(' ', '');

    // Check for Philippine mobile number format: +639XXXXXXXXX (13 chars) or 09XXXXXXXXX (11 chars)
    if (cleanedValue.startsWith('+63')) {
      // Format: +639XXXXXXXXX (should be 13 characters total)
      if (cleanedValue.length != 13) {
        return 'Phone number with +63 should be 13 digits (e.g., +639123456789)';
      }
      // Check if it starts with +639 (mobile numbers)
      if (!cleanedValue.startsWith('+639')) {
        return 'Mobile number should start with +639';
      }
      // Check if remaining characters are digits
      String digits = cleanedValue.substring(3); // Remove +63
      if (int.tryParse(digits) == null) {
        return 'Phone number must contain only digits after +63';
      }
    } else if (cleanedValue.startsWith('09')) {
      // Format: 09XXXXXXXXX (should be 11 characters total)
      if (cleanedValue.length != 11) {
        return 'Phone number starting with 09 should be 11 digits (e.g., 09123456789)';
      }
      // Check if all characters are digits
      if (int.tryParse(cleanedValue) == null) {
        return 'Phone number must contain only digits';
      }
    } else {
      return 'Phone number must start with +639 or 09';
    }

    return null;
  }
}
