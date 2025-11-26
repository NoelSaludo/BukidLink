import 'package:bukidlink/Widgets/CustomBackButton.dart';
import 'package:flutter/material.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/data/UserData.dart';
import 'package:bukidlink/Widgets/Profile/ProfileCoverPicture.dart';
import 'package:bukidlink/Widgets/Profile/ProfileIcon.dart';
import 'package:bukidlink/Widgets/Profile/MessageButton.dart';
import 'package:bukidlink/Widgets/Profile/FollowButton.dart';
import 'package:bukidlink/Pages/MessagePage.dart';
import 'package:bukidlink/Widgets/Profile/ProfileUsername.dart';
import 'package:bukidlink/Utils/PageNavigator.dart';

class ProfileInfo extends StatelessWidget {
  final String profileID;

  const ProfileInfo({super.key, required this.profileID});

  void onMessagePress(BuildContext context) {
    PageNavigator().goToAndKeep(context, MessagePage());
  }

  @override
  Widget build(BuildContext context) {
    final User profile = UserData.getUserInfoById(profileID);
    final String coverImage = 'assets/images/profileCover1.png';
    final String profileImage = 'assets/images/${profile.profilePic}';
    final String username = profile.username;

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
                      child: CustomBackButton(
                        onPressed: () => Navigator.pop(context),
                      ),
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
              const SizedBox(height: 20),

              // --- Buttons Row ---
              Row(
                children: [
                  Expanded(child: FollowButton(farmId: profile.id)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onMessagePress(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFD5FF6B,
                        ), // your green theme
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Message",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
