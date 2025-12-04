import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Pages/LoadingPage.dart';
import 'package:bukidlink/utils/PageNavigator.dart';

class GoogleSignUpPage extends StatefulWidget {
  const GoogleSignUpPage({super.key});

  @override
  State<GoogleSignUpPage> createState() => _GoogleSignUpPageState();
}

class _GoogleSignUpPageState extends State<GoogleSignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController farmAddressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<String> activeTab = ValueNotifier<String>('Consumer');
  final FormValidator validator = FormValidator();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = UserService().getCurrentUser();
    if (user != null) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      // username left empty for user to choose
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    contactController.dispose();
    farmNameController.dispose();
    farmAddressController.dispose();
    activeTab.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      if (activeTab.value == 'Consumer') {
        await UserService().createConsumerAccount(
          username: usernameController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          address: addressController.text.trim(),
          contactNumber: contactController.text.trim(),
        );
      } else {
        await UserService().createFarmerAccount(
          username: usernameController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          address: addressController.text.trim(),
          contactNumber: contactController.text.trim(),
          farmName: farmNameController.text.trim(),
          farmAddress: farmAddressController.text.trim(),
        );
      }

      if (context.mounted) {
        final type = UserService().getCurrentUser()?.type ?? 'Consumer';
        PageNavigator().goTo(context, LoadingPage(userType: type));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating account: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete account')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                ValueListenableBuilder<String>(
                  valueListenable: activeTab,
                  builder: (context, value, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Consumer'),
                          selected: value == 'Consumer',
                          onSelected: (_) => activeTab.value = 'Consumer',
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Farmer'),
                          selected: value == 'Farmer',
                          onSelected: (_) => activeTab.value = 'Farmer',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator: validator.nameValidator,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  validator: validator.nameValidator,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a username'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: validator.tempAddressValidator,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact number',
                  ),
                  validator: validator.tempContactNumberValidator,
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: activeTab,
                  builder: (context, value, child) {
                    if (value != 'Farmer') return const SizedBox.shrink();
                    return Column(
                      children: [
                        TextFormField(
                          controller: farmNameController,
                          decoration: const InputDecoration(
                            labelText: 'Farm name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter farm name'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: farmAddressController,
                          decoration: const InputDecoration(
                            labelText: 'Farm address',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter farm address'
                              : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: Text(
                      isLoading ? 'Please wait...' : 'Create Account',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
