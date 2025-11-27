import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/data/PostData.dart';
import 'package:bukidlink/Widgets/Posts/PostTile.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Post> posts = PostData.getAllPosts();
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.HEADER_GRADIENT_START,
        elevation: 0,
        title: Text(
          'News Feed',
          style: AppTextStyles.PRODUCT_INFO_TITLE,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.HEADER_GRADIENT_START,
                AppColors.HEADER_GRADIENT_END,
              ],
            ),
          ),
        ),
      ),
      body: posts.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                // ✅ Use your existing tile widget
                return PostTile(post: post);
              },
            )
          : Center(
              child: Text(
                'No Posts yet',
                style: AppTextStyles.sectionTitle,
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}
