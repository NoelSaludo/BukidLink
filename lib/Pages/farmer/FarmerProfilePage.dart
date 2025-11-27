import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Profile/ProfileInfo.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/Widgets/Posts/PostTile.dart';
import 'package:bukidlink/services/PostService.dart';
import 'package:bukidlink/Widgets/farmer/FarmerBottomNavBar.dart';

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
      backgroundColor: AppColors.backgroundYellow,
      body: CustomScrollView(
        slivers: [
          // --- Profile Info ---
          SliverToBoxAdapter(
            child: ProfileInfo(profileID: widget.profileID),
          ),

          // --- Header ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Divider(thickness: 1),
                  SizedBox(height: 5),
                  Text(
                    'Posts History',
                    style: AppTextStyles.PRODUCT_NAME_HEADER,
                  ),
                ],
              ),
            ),
          ),

          // --- Posts Section ---
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
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
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 2),
    );
  }
}