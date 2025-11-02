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

  const ProfileInfo({
    super.key,
    required this.profileID,
  });

  void onMessagePress(BuildContext context) {
    PageNavigator().goToAndKeep(context, MessagePage());
  }

  @override
  Widget build(BuildContext context) {
    final User profile = UserData.getUserInfoById(profileID);

    final String coverImage = 'assets/images/default_cover_photo.png';
    final String profileImage = 'assets/images/${profile.profilePic}';
    final String username = profile.username;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // --- Cover photo with back button overlay ---
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Stack(
                children: [
                  ProfileCoverPicture(imageUrl: coverImage),
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

            // --- Profile picture (overlapping cover) ---
            // Positioned(
            //   bottom: -50,
            //   left: 0,
            //   right: 0,
            //   child: Center(
            //     child: ProfileIcon(imageUrl: profileImage),
            //   ),
            // ),
          ],
        ),

        const SizedBox(height: 20), // space for profile overlap

        // --- Username ---
        ProfileUsername(username: username),

        const SizedBox(height: 10),

        // --- Action buttons (Follow + Message) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FollowButton(),
            const SizedBox(width: 12),
            MessageButton(onPressed: () => onMessagePress(context)),
          ],
        ),

        const SizedBox(height: 15),
        //const Divider(thickness: 1, color: Colors.grey, indent: 30, endIndent: 30),
      ],
    );
  }
}
