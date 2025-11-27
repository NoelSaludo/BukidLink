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
      backgroundColor: AppColors.backgroundYellow,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverToBoxAdapter(child: ProfileInfo(profileID: widget.profileID)),

          // Store preview section
          SliverToBoxAdapter(child: StorePreview(profileID: widget.profileID)),

          // Title section
          const SliverToBoxAdapter(
            child: Column(
              children: [
                Divider(thickness: 1),
                Text(
                  'Posts History',
                  style: AppTextStyles.PRODUCT_NAME_HEADER,
                ),
              ],
            ),
          ),

          // Loading indicator / posts list
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
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No posts yet',
                    style: AppTextStyles.sectionTitle,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final post = posts[index];
                return PostTile(post: post);
              }, childCount: posts.length),
            ),
        ],
      ),
    );
  }
}