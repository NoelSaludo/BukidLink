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
import 'package:bukidlink/services/UserService.dart';
class ProfileInfo extends StatelessWidget {
  final String profileID;

  const ProfileInfo({
    super.key,
    required this.profileID,
  });

  void onMessagePress(BuildContext context, String profileID) {
    PageNavigator().goToAndKeep(context, MessagePage(profileID: profileID));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: UserService().getUserWithFallback(profileID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final User profile = snapshot.data!;

        final String coverImage = 'assets/images/profileCover1.png';
        final String profileImage = 'assets${profile.profilePic}';
        final String username = profile.username;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Cover Section ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Photo
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

                // Profile Picture
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
                    child: ProfileIcon(
                      imageUrl: profileImage,
                      size: 85,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 55),

            // --- Username / Info ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileUsername(username: username),
                  const SizedBox(height: 4),
                  Text(
                    "Farmer • Local Producer",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Follow",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              onMessagePress(context, profile.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD5FF6B),
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

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
