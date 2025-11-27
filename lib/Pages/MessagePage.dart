import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Profile/ProfileInfo.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/data/PostData.dart';
import 'package:bukidlink/Widgets/Posts/PostTile.dart';


class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Post> posts = PostData.getAllPosts();
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: CustomScrollView(
        slivers: [
          // Sliver for user info section
          SliverToBoxAdapter(
            child: ProfileInfo(profileID: ''),
          ),

          // Divider or spacing
          const SliverToBoxAdapter(
            child: Divider(thickness: 1),
          ),

          // Sliver list for user posts
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = posts[index];
                return PostTile(post: post);
              },
              childCount: posts.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}
