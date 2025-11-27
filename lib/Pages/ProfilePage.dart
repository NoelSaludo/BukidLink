import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Profile/ProfileInfo.dart';
import 'package:bukidlink/Widgets/Profile/StorePreview.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/Widgets/Posts/PostTile.dart';
import 'package:bukidlink/services/PostService.dart';

class ProfilePage extends StatefulWidget {
  final String profileID;

  const ProfilePage({super.key, required this.profileID});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserPosts();
  }

  Future<void> loadUserPosts() async {
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
          // Profile header aligned with StorePreview padding
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: ProfileInfo(profileID: widget.profileID)),
          ),

          // Store preview section (already has its own padding internally)
          SliverToBoxAdapter(child: StorePreview(profileID: widget.profileID)),

          // Title section styled like store preview
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Divider(thickness: 1),
                  SizedBox(height: 6),
                  Text('Posts History', style: AppTextStyles.PRODUCT_NAME_HEADER),
                ],
              ),
            ),
          ),

          // Loading indicator / posts list (pad to align with store preview)
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (posts.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: Text('No posts yet', style: AppTextStyles.sectionTitle),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PostTile(post: post),
                  );
                }, childCount: posts.length),
              ),
            ),
          // Add some bottom padding so content isn't clipped by nav bars
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}