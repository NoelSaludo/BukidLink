import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/ProfileImageWidget.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/services/ImagePickerService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/pages/MyAddressPage.dart';
import 'package:bukidlink/pages/AccountSecurityPage.dart';
import 'package:bukidlink/pages/EditProfilePage.dart';
import 'package:bukidlink/Pages/LoginPage.dart';

class AccountPage extends StatefulWidget {
  final User? currentUser;

  const AccountPage({super.key, this.currentUser});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePickerService _imagePickerService = ImagePickerService();

  // Controllers for editable fields
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _passwordController;
  late TextEditingController _addressController;
  late TextEditingController _contactNumberController;

  String? _profilePicUrl;
  bool _isImageUpdated = false;

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
    _contactNumberController = TextEditingController(
      text: user?.contactNumber ?? '',
    );
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

  Future<void> _handleImagePicker() async {
    HapticFeedback.lightImpact();

    final String? imagePath = await _imagePickerService
        .showImageSourceBottomSheet(context);

    if (imagePath != null) {
      // If the picker returned a remote URL (Cloudinary), don't try to copy it locally.
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // Persist remote URL to user profile and update UI
        try {
          final uid = UserService().getSafeUserId();
          await UserService().updateUserProfile(uid, {'profilePic': imagePath});
          setState(() {
            _profilePicUrl = imagePath;
            _isImageUpdated = true;
          });

          HapticFeedback.mediumImpact();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile picture updated successfully!'),
                backgroundColor: AppColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          debugPrint('Failed to persist remote profile pic: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to update profile picture. Please try again.',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        // Local file path: copy into app directory as before
        final String? savedPath = await _imagePickerService
            .saveImageToAppDirectory(imagePath);

        if (savedPath != null) {
          setState(() {
            _profilePicUrl = savedPath;
            _isImageUpdated = true;
          });

          HapticFeedback.mediumImpact();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile picture updated successfully!'),
                backgroundColor: AppColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save image. Please try again.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    }
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      // TODO: Save changes to backend/database
      // This would include saving the new profile picture path

      if (_isImageUpdated) {
        // Profile picture was updated
        debugPrint('New profile picture path: $_profilePicUrl');
      }

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
    debugPrint('User: $user');

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
    // Determine the correct image source: network URL vs local asset
    String? profileImage;
    if (user != null && user.profilePic.isNotEmpty) {
      final pic = user.profilePic;
      if (pic.startsWith('http://') || pic.startsWith('https://')) {
        profileImage = pic; // remote URL (Cloudinary)
      } else {
        profileImage = 'assets/images/$pic'; // local asset filename
      }
    } else {
      profileImage = null;
    }

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
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  // Profile Image with new ProfileImageWidget
                  ProfileImageWidget(
                    imageUrl: _isImageUpdated
                        ? _profilePicUrl
                        : (profileImage ?? ''),
                    size: 100,
                    showBorder: true,
                    borderColor: Colors.white,
                    borderWidth: 4,
                    showEditBadge: true,
                    onTap: _handleImagePicker,
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
                subtitle: widget.currentUser?.address,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyAddressPage(
                        currentAddress: _addressController.text,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.security,
                title: 'Account Security',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountSecurityPage(
                        currentPassword: _passwordController.text,
                      ),
                    ),
                  );
                },
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
                onTap: () => _showInfoDialog(
                  'Notifications',
                  'Notification settings coming soon',
                ),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Settings',
                onTap: () =>
                    _showInfoDialog('Privacy', 'Privacy settings coming soon'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Settings',
                onTap: () =>
                    _showInfoDialog('Payment', 'Payment settings coming soon'),
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
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                titleColor: AppColors.ERROR_RED,
                onTap: () => _showDeleteAccountDialog(),
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
        builder: (context) => EditProfilePage(
          usernameController: _usernameController,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
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
        content: const Text('Are you sure you want to logout?'),
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserService().signOut();

                if (mounted) {
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

                  // Clear local current user and navigate to the LoginPage,
                  // removing all other routes so the user cannot go back.
                  UserService.currentUser = null;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint('Logout failed: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Logout failed. Please try again.'),
                      backgroundColor: AppColors.ERROR_RED,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
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

  void _showDeleteAccountDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.ERROR_RED),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.ERROR_RED.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.ERROR_RED.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action cannot be undone:',
                    style: TextStyle(
                      color: AppColors.ERROR_RED,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildWarningItem('All your personal data will be deleted'),
                  _buildWarningItem('Your order history will be lost'),
                  _buildWarningItem(
                    'You will lose access to all saved addresses',
                  ),
                  _buildWarningItem('Your account cannot be recovered'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion logic
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Account deletion request submitted'),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.ERROR_RED,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text(
              'Delete Account',
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

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, size: 16, color: AppColors.ERROR_RED),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
