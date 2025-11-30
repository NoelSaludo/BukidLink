import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/account/EditableTextField.dart';
import 'package:bukidlink/utils/FormValidator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSecurityPage extends StatefulWidget {
  final String? currentPassword;

  const AccountSecurityPage({super.key, this.currentPassword});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    // TODO: Verify with actual current password
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('No authenticated user found.'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    // Reauthenticate user using current password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: _currentPasswordController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Updating password...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    user
        .reauthenticateWithCredential(credential)
        .then((_) async {
          try {
            await user.updatePassword(_newPasswordController.text.trim());

            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Password updated successfully!'),
                  ],
                ),
                backgroundColor: AppColors.SUCCESS_GREEN,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );

            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();

            Navigator.pop(context);
          } on FirebaseAuthException catch (e) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            String message = 'Failed to update password.';
            if (e.code == 'weak-password') {
              message = 'The new password is too weak.';
            } else if (e.code == 'requires-recent-login') {
              message = 'Please re-login and try again.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          String message = 'Reauthentication failed.';
          if (error is FirebaseAuthException &&
              error.code == 'wrong-password') {
            message = 'Current password is incorrect.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.HEADER_GRADIENT_START,
                      AppColors.HEADER_GRADIENT_END,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Account Security',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: AppTextStyles.SECTION_TITLE.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your password must be at least 10 characters long',
                            style: AppTextStyles.CAPTION.copyWith(
                              fontSize: 13,
                              color: AppColors.TEXT_SECONDARY,
                            ),
                          ),
                          const SizedBox(height: 20),
                          EditableTextField(
                            label: 'Current Password',
                            controller: _currentPasswordController,
                            obscureText: !_isCurrentPasswordVisible,
                            validator: _validateCurrentPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isCurrentPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.TEXT_SECONDARY,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isCurrentPasswordVisible =
                                      !_isCurrentPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          EditableTextField(
                            label: 'New Password',
                            controller: _newPasswordController,
                            obscureText: !_isNewPasswordVisible,
                            validator: FormValidator().signupPasswordValidator,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isNewPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.TEXT_SECONDARY,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isNewPasswordVisible =
                                      !_isNewPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          EditableTextField(
                            label: 'Confirm New Password',
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            validator: _validateConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.TEXT_SECONDARY,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Security Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.ACCENT_LIME.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.ACCENT_LIME.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Password Security Tips',
                                style: AppTextStyles.BODY_MEDIUM.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSecurityTip('Use at least 10 characters'),
                          _buildSecurityTip(
                            'Include uppercase and lowercase letters',
                          ),
                          _buildSecurityTip(
                            'Add numbers and special characters',
                          ),
                          _buildSecurityTip('Avoid personal information'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Update Password',
                            style: AppTextStyles.BUTTON_TEXT.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.DARK_TEXT,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: AppColors.BORDER_GREY.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.CAPTION.copyWith(
                fontSize: 13,
                color: AppColors.DARK_TEXT,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
