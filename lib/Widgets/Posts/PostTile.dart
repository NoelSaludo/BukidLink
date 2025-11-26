import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Posts/PostIcon.dart';
import 'package:bukidlink/Widgets/Posts/PostContent.dart';
import 'package:bukidlink/Widgets/Posts/PostUsername.dart';
import 'package:bukidlink/Widgets/Posts/PostTimestamp.dart';
import 'package:bukidlink/Utils/PageNavigator.dart';
import 'package:bukidlink/data/UserData.dart';
import 'package:bukidlink/data/PostData.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Widgets/Profile/FollowButton.dart';
import 'package:intl/intl.dart';

class PostTile extends StatelessWidget {
  final Post post;
  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    //notification icon
    User poster;
    poster = UserData.getUserInfoById(post.posterID);
    String imageUrl = poster.profilePic;
    DateFormat formatter = DateFormat('MMM d, yyyy · H:mm a');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Profile icon + Username + Timestamp
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PostIcon(
                imageUrl: imageUrl,
                onTapped: () => Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: post.posterID,
                ),
              ),
              const SizedBox(width: 10),

              // Username + Timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Farm?>(
                      future: UserService().getFarmByReference(poster.farmId),
                      builder: (context, snap) {
                        final farmName =
                            (snap.hasData &&
                                snap.data != null &&
                                snap.data!.name.trim().isNotEmpty)
                            ? snap.data!.name.trim()
                            : 'unset value';
                        final farmId = (snap.hasData && snap.data != null)
                            ? snap.data!.id
                            : null;

                        return Row(
                          children: [
                            Expanded(
                              child: PostUsername(
                                username: poster.username,
                                farmName: farmName,
                              ),
                            ),
                            if (farmId != null) ...[
                              const SizedBox(width: 8),
                              FollowButton(farmId: farmId, width: 90),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    PostTimestamp(timestamp: formatter.format(post.timestamp)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(thickness: 1),

          PostContent(
            textContent: post.textContent,
            imageContent: post.imageContent,
          ),
        ],
      ),
    );
  }
}
