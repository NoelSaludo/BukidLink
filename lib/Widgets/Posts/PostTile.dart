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
import 'package:intl/intl.dart';


class PostTile extends StatelessWidget {
  final Post post;

  late final User poster = UserData.getUserInfoById(post.posterID);
  late final String imageUrl = poster.profilePic;
  late final String timestamp = _formatter.format(post.timestamp);
  late final String farmName = 
      (poster.farm?.trim().isNotEmpty ?? false) ? poster.farm!.trim() : 'unset value';

  static final DateFormat _formatter = DateFormat('MMM d, yyyy · H:mm a');

  PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PostIcon(
                imageUrl: imageUrl,
                onTapped: () {
                  Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: post.posterID,
                  );
                },
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostUsername(
                      username: poster.username,
                      farmName: farmName,
                    ),
                    const SizedBox(height: 2),
                    PostTimestamp(timestamp: timestamp),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(thickness: 1),

          PostContent(
            textContent: post.textContent,
            imageContent: post.imageContent,
          ),
        ],
      ),
    );
  }
}
