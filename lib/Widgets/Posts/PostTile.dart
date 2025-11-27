import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Widgets/Posts/PostIcon.dart';
import 'package:bukidlink/Widgets/Posts/PostContent.dart';
import 'package:bukidlink/Widgets/Posts/PostUsername.dart';
import 'package:bukidlink/Widgets/Posts/PostTimestamp.dart';
import 'package:bukidlink/Pages/ProfilePage.dart';
import 'package:bukidlink/Pages/farmer/FarmerProfilePage.dart'; // <-- Only if needed
import 'package:bukidlink/utils/constants/AppColors.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile({super.key, required this.post});

  Future<Map<String, dynamic>> _fetchData() async {
    final poster = await UserService().getUserById(post.posterID);
    Farm? farm;

    if (poster != null && poster.farmId != null) {
      farm = await UserService().getFarmByReference(poster.farmId);
    }

    final currentUser = await UserService().getCurrentUser();

    return {
      'poster': poster,
      'farm': farm,
      'currentUser': currentUser,
    };
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM d, yyyy · h:mm a');

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          );
        }

        final poster = snapshot.data!['poster'] as User?;
        final farm = snapshot.data!['farm'] as Farm?;
        final currentUser = snapshot.data!['currentUser'] as User?;

        if (poster == null) return const SizedBox();

        final imageUrl = poster.profilePic.isEmpty
            ? 'assets/images/default_profile.png'
            : poster.profilePic;

        final farmName = farm?.name ?? '';
        final currentType = currentUser?.type?.trim().toLowerCase() ?? 'user';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Use Navigator.push instead of pushNamed
                  PostIcon(
                    imageUrl: imageUrl,
                    onTapped: () {
                      if (currentType == 'farmer') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FarmerProfilePage(profileID: poster.id),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(profileID: poster.id),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostUsername(
                          username: poster.username,
                          farmName: farmName,
                        ),
                        const SizedBox(height: 2),
                        PostTimestamp(
                          timestamp: formatter.format(post.createdAt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 8),

              PostContent(
                textContent: post.textContent,
                imageUrl: post.imageContent,
              ),
            ],
          ),
        );
      },
    );
  }
}
