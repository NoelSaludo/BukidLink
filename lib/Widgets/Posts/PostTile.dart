import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Posts/PostIcon.dart';
import 'package:bukidlink/Widgets/Posts/PostContent.dart';
import 'package:bukidlink/Widgets/Posts/PostUsername.dart';
import 'package:bukidlink/Widgets/Posts/PostTimestamp.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Widgets/Profile/FollowButton.dart';
import 'package:intl/intl.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({super.key, required this.post});

  // Cache the Future to prevent refetching on rebuilds
  Future<Map<String, dynamic>>? _posterAndFarmFuture;

  Future<Map<String, dynamic>> _getPosterAndFarm() {
    _posterAndFarmFuture ??= _fetchPosterAndFarm();
    return _posterAndFarmFuture!;
  }

  Future<Map<String, dynamic>> _fetchPosterAndFarm() async {
    final user = await UserService().getUserById(post.posterID);
    Farm? farm;
    if (user != null && user.farmId != null) {
      farm = await UserService().getFarmByReference(user.farmId);
    }
    return {'user': user, 'farm': farm};
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('MMM d, yyyy · H:mm a');

    return FutureBuilder<Map<String, dynamic>>(
      future: _getPosterAndFarm(),
      builder: (context, snapshot) {
        // Show a small placeholder while loading instead of full spinner
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          );
        }

        final poster = snapshot.data!['user'] as User?;
        final farm = snapshot.data!['farm'] as Farm?;

        if (poster == null) return const SizedBox();

        final imageUrl = (poster.profilePic.isEmpty) ? 'default_profile.png' : poster.profilePic;
        final farmName = farm?.name ?? '';

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
                    onTapped: () {
                      if (poster.farmId != null) {
                        Navigator.pushNamed(
                          context,
                          '/farmerProfile',
                          arguments: poster.id,
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          '/profile',
                          arguments: poster.id,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostUsername(username: poster.username, farmName: farmName),
                        const SizedBox(height: 2),
                        PostTimestamp(timestamp: formatter.format(post.createdAt)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              PostContent(textContent: post.textContent, imageUrl: post.imageContent),
            ],
          ),
        );
      },
    );
  }
}
