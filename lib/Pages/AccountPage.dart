import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/account/EditableTextField.dart';
import 'package:bukidlink/utils/FormValidator.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/widgets/CustomBackButton.dart';

class AccountPage extends StatefulWidget {
  final User? currentUser;

  const AccountPage({
    super.key,
    this.currentUser,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for editable fields
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _passwordController;
  late TextEditingController _addressController;
  late TextEditingController _contactNumberController;
  
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = widget.currentUser;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _contactNumberController = TextEditingController(text: user?.contactNumber ?? '');
    _profilePicUrl = user?.profilePic;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  void _handleImagePicker() {
    // TODO: Implement image picker functionality
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Profile Picture'),
        content: const Text('Image picker will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      // TODO: Save changes to backend/database
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile updated successfully!'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: CustomScrollView(
        slivers: [
          _buildProfileHeader(user),
          SliverToBoxAdapter(child: _buildAccountContent()),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    final String profileImage = user?.profilePic != null 
        ? 'assets/images/${user!.profilePic}'
        : '';
    
    return SliverToBoxAdapter(
      child: Container(
        height: 280,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Stack(
          children: [
            // Gradient Background
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.HEADER_GRADIENT_START,
                    AppColors.HEADER_GRADIENT_END,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
            
            // Back Button
            Positioned(
              top: 40,
              left: 8,
              child: CustomBackButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),
            
            // Profile Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: _handleImagePicker,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipOval(
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Colors.white,
                              child: profileImage.isNotEmpty
                                  ? Image.asset(
                                      profileImage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDefaultAvatar();
                                      },
                                    )
                                  : _buildDefaultAvatar(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.ACCENT_LIME,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: AppColors.DARK_TEXT,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Username
                  Text(
                    '@${user?.username ?? 'User'}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Email
                  Text(
                    user?.emailAddress ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.ACCENT_LIME.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 50,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildAccountContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSection(
            title: 'My Account',
            children: [
              _buildMenuItem(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => _navigateToEditProfile(),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'My Address',
                subtitle: widget.currentUser?.address ?? 'Not set',
                onTap: () => _showInfoDialog('My Address', 'Address management coming soon'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.security_outlined,
                title: 'Account Security',
                onTap: () => _showInfoDialog('Account Security', 'Security settings coming soon'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSection(
            title: 'Settings',
            children: [
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => _showInfoDialog('Notifications', 'Notification settings coming soon'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Settings',
                onTap: () => _showInfoDialog('Privacy', 'Privacy settings coming soon'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Settings',
                onTap: () => _showInfoDialog('Payment', 'Payment settings coming soon'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSection(
            title: 'Support',
            children: [
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => _showInfoDialog('Help', 'Help center coming soon'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () => _showAboutDialog(),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                titleColor: AppColors.ERROR_RED,
                onTap: () => _showLogoutDialog(),
                showArrow: false,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: AppTextStyles.SECTION_TITLE.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.ACCENT_LIME.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: titleColor ?? AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.BODY_MEDIUM.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppColors.DARK_TEXT,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.CAPTION.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.TEXT_SECONDARY,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  void _navigateToEditProfile() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _EditProfilePage(
          usernameController: _usernameController,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          passwordController: _passwordController,
          addressController: _addressController,
          contactNumberController: _contactNumberController,
          profilePicUrl: _profilePicUrl,
          onImagePick: _handleImagePicker,
          onSave: _saveChanges,
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.ACCENT_LIME.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.eco, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('About BukidLink'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BukidLink',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connecting farmers and consumers for fresh, local produce.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2025 BukidLink. All rights reserved.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.ERROR_RED),
            const SizedBox(width: 8),
            const Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.TEXT_SECONDARY,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Logged out successfully'),
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
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: AppColors.ERROR_RED,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Edit Profile Page as a separate widget
class _EditProfilePage extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController passwordController;
  final TextEditingController addressController;
  final TextEditingController contactNumberController;
  final String? profilePicUrl;
  final VoidCallback onImagePick;
  final VoidCallback onSave;

  const _EditProfilePage({
    required this.usernameController,
    required this.firstNameController,
    required this.lastNameController,
    required this.passwordController,
    required this.addressController,
    required this.contactNumberController,
    this.profilePicUrl,
    required this.onImagePick,
    required this.onSave,
  });

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.contains(' ')) {
      return 'Username cannot contain spaces';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validateContactNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid contact number';
    }
    return null;
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      widget.onSave();
      Navigator.pop(context);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String profileImage = widget.profilePicUrl != null 
        ? 'assets/images/${widget.profilePicUrl}'
        : '';
        
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // Profile Picture Header
            SliverToBoxAdapter(
              child: Container(
                height: 240,
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
                      child: CustomBackButton(
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
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: widget.onImagePick,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  ClipOval(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.white,
                                      child: profileImage.isNotEmpty
                                          ? Image.asset(
                                              profileImage,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return _buildDefaultAvatar();
                                              },
                                            )
                                          : _buildDefaultAvatar(),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.ACCENT_LIME,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: AppColors.DARK_TEXT,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to change photo',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
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
            
            // Form Fields
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFormSection(
                      title: 'Account Information',
                      children: [
                        EditableTextField(
                          label: 'Username (no spaces allowed)',
                          controller: widget.usernameController,
                          validator: _validateUsername,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: EditableTextField(
                                label: 'First Name',
                                controller: widget.firstNameController,
                                validator: FormValidator().nameValidator,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: EditableTextField(
                                label: 'Last Name',
                                controller: widget.lastNameController,
                                validator: FormValidator().nameValidator,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFormSection(
                      title: 'Security',
                      children: [
                        EditableTextField(
                          label: 'Password',
                          controller: widget.passwordController,
                          obscureText: !_isPasswordVisible,
                          validator: FormValidator().signupPasswordValidator,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.TEXT_SECONDARY,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFormSection(
                      title: 'Contact Information',
                      children: [
                        EditableTextField(
                          label: 'Address',
                          controller: widget.addressController,
                          validator: FormValidator().nameValidator,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        EditableTextField(
                          label: 'Contact Number',
                          controller: widget.contactNumberController,
                          validator: _validateContactNumber,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
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
                            'Save Changes',
                            style: AppTextStyles.BUTTON_TEXT.copyWith(fontSize: 16),
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

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.ACCENT_LIME.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 50,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
            title,
            style: AppTextStyles.SECTION_TITLE.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
