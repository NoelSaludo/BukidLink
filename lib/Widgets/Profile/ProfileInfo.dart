// Using Flutter's default BackButton in place of the custom one
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/services/follow_service.dart';
import 'package:bukidlink/Widgets/Profile/ProfileCoverPicture.dart';
import 'package:bukidlink/Widgets/Profile/ProfileIcon.dart';
import 'package:bukidlink/Widgets/Profile/MessageButton.dart';
import 'package:bukidlink/Widgets/Profile/FollowButton.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';
import 'package:bukidlink/services/ChatService.dart';
import 'package:bukidlink/Pages/ChatPage.dart';
import 'package:bukidlink/Widgets/Profile/ProfileUsername.dart';
import 'package:bukidlink/Widgets/Posts/AddPost.dart';
// PageNavigator and MessagePage were used previously for navigation to a
// legacy message page; we now navigate directly to `ChatPage`.

class ProfileInfo extends StatefulWidget {
  final String profileID;

  const ProfileInfo({super.key, required this.profileID});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  final UserService _userService = UserService();
  final currentUserID = UserService().getCurrentUser()?.id;
  User? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    debugPrint("Loading profile for ID: ${widget.profileID}");
    try {
      // Try to fetch a user directly by the passed id
      User? u = await _userService.getUserById(widget.profileID);

      // If no user found, the passed id might be a farm id — resolve farm -> owner user
      if (u == null) {
        debugPrint(
          'No user found for id ${widget.profileID}, attempting to treat as farm id',
        );
        final farmDoc = await FirebaseFirestore.instance
            .collection('farms')
            .doc(widget.profileID)
            .get();
        if (farmDoc.exists) {
          final data = farmDoc.data();
          final ownerRef = data != null ? data['ownerId'] : null;
          if (ownerRef != null && ownerRef is DocumentReference) {
            final ownerId = ownerRef.id;
            debugPrint('Resolved farm owner id: $ownerId — loading user');
            u = await _userService.getUserById(ownerId);
          } else {
            debugPrint('Farm document missing ownerId or ownerId is invalid');
          }
        } else {
          debugPrint('No farm found with id ${widget.profileID}');
        }
      }

      setState(() {
        _profile = u;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> onMessagePress(BuildContext context) async {
    final currentUid = UserService.currentUser?.id;
    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send messages')),
      );
      return;
    }

    final targetId = _profile?.id;
    if (targetId == null || targetId.isEmpty) return;

    if (currentUid == targetId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot message yourself')),
      );
      return;
    }

    final chatService = ChatService();
    await chatService.createConversation(currentUid, targetId);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage(sender: targetId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String coverImage = 'assets/images/profileCover1.png';
    if (_isLoading) {
      return SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // If no profile found, show a simple empty state
    if (_profile == null) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Center(child: Text('Profile not found')),
        ],
      );
    }

    final profile = _profile!;
    final String profileImage = '{profile.profilePic}';
    final String username = profile.username;
    final String? currentUid = UserService.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Cover Section ---
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover photo
            Container(
              height: 180,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProfileCoverPicture(imageUrl: coverImage),
                    Container(color: Colors.black.withOpacity(0.2)),
                    Positioned(
                      top: 30,
                      left: 10,
                      child: BackButton(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Profile picture (left-aligned, overlapping)
            Positioned(
              bottom: -40,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ProfileIcon(imageUrl: profileImage, size: 85),
              ),
            ),
          ],
        ),

        const SizedBox(height: 55),

        // --- Name and Info aligned with profile ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileUsername(username: username),
              const SizedBox(height: 4),
              Text(
                "Farmer • Local Producer",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              // Followers count
              if (profile.farmId != null)
                StreamBuilder<int>(
                  stream: FollowService().followerCountStream(
                    farmId: profile.farmId!.id,
                  ),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Text(
                      '$count followers'.replaceAll('\u0000', ''),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    );
                  },
                ),
              const SizedBox(height: 20),

              // --- Buttons Row ---
              if (currentUid == profile.id) ...[
                // --- Add Post Button ---
                SizedBox(width: double.infinity, child: AddPost()),
              ] else ...[
                // --- Follow + Message Buttons ---
                Row(
                  children: [
                    Expanded(
                      child: FollowButton(farmId: profile.farmId?.id ?? ''),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => onMessagePress(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                          ),
                          child: Text(
                            "Message",
                            style: AppTextStyles.BUTTON_TEXT.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- Divider ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Colors.grey[300], thickness: 1),
        ),
      ],
    );
  }
}
