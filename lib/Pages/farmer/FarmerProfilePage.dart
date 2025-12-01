import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Profile/ProfileInfo.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/Widgets/Posts/PostTile.dart';
import 'package:bukidlink/services/PostService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/Widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/models/User.dart';

class FarmerProfilePage extends StatefulWidget {
  final String profileID;

  const FarmerProfilePage({
    super.key,
    required this.profileID,
  });

  @override
  _FarmerProfilePageState createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  List<Post> posts = [];
  bool isLoading = true;
  final user = UserService().getCurrentUser();

  @override
  void initState() {
    super.initState();
    loadUserPosts();
  }

  Future<void> loadUserPosts() async {
    setState(() {
      isLoading = true;
    });

    final fetchedPosts = await PostService().fetchPostsByUser(widget.profileID);

    setState(() {
      posts = fetchedPosts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      body: CustomScrollView(
        slivers: [
          // --- Profile Info ---
          SliverToBoxAdapter(
            child: ProfileInfo(profileID: widget.profileID),
          ),

          // --- Header ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    'Posts & Activity',
                    style: AppTextStyles.PRODUCT_NAME_HEADER.copyWith(
                      color: AppColors.HEADER_GRADIENT_START,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Posts Section ---
          if (isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            )
          else if (posts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No posts yet — check back later.',
                    style: AppTextStyles.EMPTY_STATE_TITLE.copyWith(
                      color: AppColors.TEXT_SECONDARY,
                    ),
                  ),
                ),
              ),
            )
          else
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
    );
  }
}